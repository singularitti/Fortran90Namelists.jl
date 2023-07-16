export Tokenizer, update_chars!, lex!, lexstring!

const PUNCTUATION = [
    ' ',
    '=',
    '+',
    '-',
    '*',
    '/',
    '\\',
    '(',
    ')',
    '[',
    ']',
    '{',
    '}',
    ',',
    '.',
    ':',
    ';',
    '!',
    '"',
    '%',
    '&',
    '~',
    '<',
    '>',
    '?',
    ''',
    '`',
    '|',
    '$',
    '#',
    '@',
]
const WHITESPACE = [' ', '\t', '\r', '\v', '\f']  # '\v' => '\x0b', '\f' => '\x0c' in Python

mutable struct Tokenizer
    chars::Iterators.Stateful
    index::Int64
    prior_char::Union{Nothing,AbstractChar}
    char::Union{Nothing,AbstractChar}
    prior_delim::Union{Nothing,AbstractChar}
    group_token::Union{Nothing,AbstractChar}  # Set to true if inside a namelist group
end
function Tokenizer(;
    chars=nothing,
    index=0,
    prior_char=nothing,
    char=nothing,
    prior_delim=nothing,
    group_token=nothing,
)
    return Tokenizer(chars, index, prior_char, char, prior_delim, group_token)
end

"""
    update_chars(tk::Tokenizer)

Update the current charters in the tokenizer.
"""
function update_chars!(tk::Tokenizer)
    tk.prior_char, tk.char = tk.char, next(tk.chars, '\n')
    tk.index += 1
    return tk
end

function lex!(tk::Tokenizer, line)
    tokens = String[]
    tk.index = 0   # Bogus value to ensure `index` = 1 after the first iteration
    tk.chars = Iterators.Stateful(line)  # An iterator generated by `line`
    update_chars!(tk)
    while tk.char != '\n'
        # Update namelist group status
        if tk.char in ('&', '$')
            tk.group_token = tk.char
        end
        if tk.group_token !== nothing &&
            ((tk.group_token, tk.char) in (('&', '/'), ('$', '$')))
            # A namelist ends, the value cannot be the default value (`nothing`)
            # Because it is being compared below
            tk.group_token = '\0'
        end
        word = ""  # Create or clear `word`
        if tk.char in WHITESPACE  # Ignore whitespace
            while tk.char in WHITESPACE
                word *= tk.char  # Read one char to `word`
                update_chars!(tk)  # Read the next char until meet a non-whitespace char
            end
        elseif tk.char in ('!', '#') || tk.group_token === nothing  # Ignore comment
            # Abort the iteration and build the comment token
            word = line[(tk.index):end]  # There is no '\n' at line end, no worry! Lines are already separated at line ends
            tk.char = '\n'
        elseif tk.char in ('\'', '"') || tk.prior_delim !== nothing  # Lex a string
            word = lexstring!(tk)
        elseif tk.char in PUNCTUATION
            word = tk.char
            update_chars!(tk)
        else
            while !(isspace(tk.char) || tk.char in PUNCTUATION)
                word *= tk.char
                update_chars!(tk)
            end
        end
        push!(tokens, string(word))
    end
    return tokens
end

"""
    lexstring(tk::Tokenizer)

Tokenize a Fortran string.
"""
function lexstring!(tk::Tokenizer)
    word = ""
    if tk.prior_delim !== nothing  # A previous quotation mark presents
        delim = tk.prior_delim  # Read until `delim`
        tk.prior_delim = nothing
    else
        delim = tk.char  # No previous quotation mark presents
        word *= tk.char  # Read this character
        update_chars!(tk)
    end
    while true
        if tk.char == delim
            # Check for escaped delimiters
            update_chars!(tk)
            if tk.char == delim
                word *= delim^2
                update_chars!(tk)
            else
                word *= delim
                break
            end
        elseif tk.char == '\n'
            tk.prior_delim = delim
            break
        else
            word *= tk.char
            update_chars!(tk)
        end
    end
    return word
end

function next(iterable, default)
    x = iterate(iterable)
    return x === nothing ? default : first(x)
end
