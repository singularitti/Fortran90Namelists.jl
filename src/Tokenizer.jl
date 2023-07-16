export Tokenizer, update!, tokenize!, tokenizestr!

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

"""
    Tokenizer(index=0, prior_char='\0', char='\0', prior_delim='\0', group_token='\0')

A mutable struct for tokenizing input string.

It maintains state information about the current position in the string, the current
character, the previous character, the previous delimiter, and the group token if inside a
namelist group.
"""
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
    tokenize!(tk::Tokenizer, line)

Tokenize the input `line` using the tokenizer `tk`.

The function updates the state of `tk` to reflect the position within `line` and returns a
list of tokens.
"""
function tokenize!(tk::Tokenizer, line)
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
            word = tokenizestr!(tk, chars)
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
    tokenizestr!(tk::Tokenizer, chars::Iterators.Stateful)

Tokenizes a Fortran string.

This function treats everything between a pair of delimiters (such as quotation marks) as a
string. It respects escaped delimiters and updates the state of the tokenizer `tk` to
reflect the position within the string.
"""
function tokenizestr!(tk::Tokenizer, chars::Iterators.Stateful)
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

"""
    update!(tk::Tokenizer, chars::Iterators.Stateful)

Update the current characters in the tokenizer, `tk`.

This includes updating both the prior and current characters, and incrementing the index.
"""
function update!(tk::Tokenizer, chars::Iterators.Stateful)
    tk.prior_char, tk.char = tk.char, next(chars, '\n')
    tk.index += 1
    return tk
end

"""
    next(chars::Iterators.Stateful, default)

Iterate over `chars`.

If there are no more items, returns `default`.
"""
function next(chars::Iterators.Stateful, default)
    x = iterate(chars)
    return x === nothing ? default : first(x)
end
