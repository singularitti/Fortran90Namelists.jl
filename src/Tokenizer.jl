export Tokenizer, update!, lex!, lexstring!

const PUNCTUATION = (
    '=',
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
    ':',
    ';',
    '%',
    '&',
    '~',
    '<',
    '>',
    '?',
    '`',
    '|',
    '$',
    '#',
    '@',
)
const WHITESPACE = (' ', '\t', '\r', '\v', '\f')  # '\v' => '\x0b', '\f' => '\x0c' in Python

mutable struct Tokenizer
    index::Int64
    prior_char::Char
    char::Char
    prior_delim::Char
    group_token::Char
    Tokenizer(index=0, prior_char='\0', char='\0', prior_delim='\0', group_token='\0') =
        new(index, prior_char, char, prior_delim, group_token)
end

"""
    update_chars(tk::Tokenizer)

Update the current charters in the tokenizer.
"""
function update!(tk::Tokenizer, chars::Iterators.Stateful)
    tk.prior_char, tk.char = tk.char, next(chars, '\n')
    tk.index += 1
    return tk
end

function lex!(tk::Tokenizer, line)
    tokens = String[]
    tk.index = 0   # Bogus value to ensure `index` = 1 after the first iteration
    chars = Iterators.Stateful(line)
    update!(tk, chars)
    while tk.char != '\n'
        # Unlike the Python code, it's crucial to put this part before `tk.char in ('&', '$')`!
        if (tk.group_token == '&' && tk.char == '/') ||
            (tk.group_token == '$' && tk.char == '$')
            # If we are at the end of a group, reset 'group_token'
            tk.group_token = '\0'  # We are now out of the group
        end
        if tk.char in ('&', '$')
            # If the namelist starts with `$`, now both `tk.group_token` and `tk.char` are `$`!
            tk.group_token = tk.char
        end
        word = ""  # Create or clear `word`
        if tk.char in WHITESPACE  # Ignore whitespace
            while tk.char in WHITESPACE
                word *= tk.char  # Read one character to `word`
                update!(tk, chars)  # Read the next character until a non-whitespace character is encountered
            end
        elseif tk.char == '!' || tk.group_token === '\0'  # Ignore comment
            # If we encounter a comment character, or we are not inside a namelist group,
            # we consider everything that follows as part of the comment.
            word = line[(tk.index):end]  # There's no '\n' at line end, no worry! Lines are already separated at line ends
            tk.char = '\n'
        elseif tk.char in ('\'', '"') || tk.prior_delim !== '\0'
            word = lexstring!(tk, chars)
        elseif tk.char in PUNCTUATION
            word = tk.char
            update!(tk, chars)
        else
            while !(isspace(tk.char) || tk.char in PUNCTUATION)
                word *= tk.char
                update!(tk, chars)
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
function lexstring!(tk::Tokenizer, chars::Iterators.Stateful)
    word = ""
    if tk.prior_delim !== '\0'  # A previous quotation mark presents
        delim = tk.prior_delim  # Read until `delim`
        tk.prior_delim = '\0'
    else
        delim = tk.char  # No previous quotation mark presents
        word *= tk.char  # Read this character
        update!(tk, chars)
    end
    while true
        if tk.char == delim
            # Check for escaped delimiters
            update!(tk, chars)
            if tk.char == delim
                word *= delim^2
                update!(tk, chars)
            else
                word *= delim
                break
            end
        elseif tk.char == '\n'
            tk.prior_delim = delim
            break
        else
            word *= tk.char
            update!(tk, chars)
        end
    end
    return word
end

function next(chars::Iterators.Stateful, default)
    x = iterate(chars)
    return x === nothing ? default : first(x)
end
