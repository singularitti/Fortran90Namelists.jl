"""
# module Tokenize



# Examples

```jldoctest
julia>
```
"""
module Tokenize

using IterTools: takewhile
using Parameters: @with_kw

export Tokenizer,
    update_chars,
    parse_name,
    parse_string,
    parse_numeric

const SPECIAL_CHARS = " =+-*/\\()[]{},.:;!\"%&~<>?\'`|$\#@"
const LEXICAL_TOKENS = "=+-*/()[],.:;%&<>"
const PUNCTUATION = "=+-*/\\()[]{},:;%&~<>?`|$\#@"

@with_kw mutable struct Tokenizer
    characters = nothing
    prior_char = nothing
    char = nothing
    idx = nothing
    whitespace = " \t\r\x0b\x0c"
    prior_delim = nothing
    group_token = nothing  # Set to true if inside a namelist group
end  # struct Tokenizer

"""
    update_chars(tk::Tokenizer)

Update the current charters in the tokenizer.
"""
function update_chars(tk::Tokenizer)
    tk.prior_char, tk.char = tk.char, iterate(tk.characters, "\n")  #
    tk.idx += 1
end  # function update_chars

function Base.parse(tk::Tokenizer, line)
    tokens = []
    tk.idx = -1   # Bogus value to ensure idx = 0 after first iteration
    tk.characters, state = iterate(line)  # FIXME:
    update_chars(tk)

    while tk.char != "\n"
        # Update namelist group status
        tk.char in ('&', '$') && tk.group_token = tk.char

        if tk.group_token && ((tk.group_token, tk.char) in (('&', '/'), ('$', '$')))
            tk.group_token = false
        end

        word = ""
        if tk.char in tk.whitespace  # " \t\r\x0b\x0c"
            while tk.char in tk.whitespace
                word *= tk.char
                update_chars(tk)
            end
        elseif tk.char in ('!', '#') || isnothing(tk.group_token)
            word = line[tk.idx:end]
            tk.char = "\n"
        elseif occursin(tk.char, "\"\'") || !isnothing(tk.prior_delim)  # FIXME:
            word = parse_string(tk)
        elseif isletter(tk.char)
            word = parse_name(tk, line)
        elseif tk.char in ('+', '-')
            # Lookahead to check for IEEE value
            tk.characters, lookahead = itertools.tee(tk.characters)  # FIXME:
            ieee_val = join(takewhile(isletter, lookahead), "")
            if lowercase(ieee_val) in ('inf', 'infinity', 'nan')
                word = tk.char * ieee_val
                tk.characters = lookahead
                tk.prior_char = ieee_val[end]
                tk.char = iterate(lookahead, '\n')  # FIXME:
            else
                word = parse_numeric(tk)
            end
        elseif isdigit(tk.char)
            word = parse_numeric(tk)
        elseif tk.char == '.'
            update_chars(tk)
            if isdigit(tk.char)
                frac = parse_numeric(tk)
                word = '.' * frac
            else
                word = '.'
                while isletter(tk.char)
                    word *= tk.char
                    update_chars(tk)
                end
                if tk.char == '.'
                    word *= tk.char
                    update_chars(tk)
                end
            end
        elseif tk.char in PUNCTUATION
            word = tk.char
            update_chars(tk)
        else
            # This should never happen
            error("")
        end
        push!(tokens, word)
    end  # while loop
    return tokens
end  # function Base.parse

function parse_name(tk::Tokenizer, line)
    endindex = tk.idx
    for char in line[tk.idx:end]
        !isalnum(char) && !occursin(char, "\'\"_") && break
        endindex += 1
    end

    word = line[tk.idx:end]

    tk.idx = endindex - 1
    # Update iterator, minus first character which was already read
    tk.characters = itertools.islice(tk.characters, length(word) - 1, nothing)
    update_chars(tk)
    return word
end  # function parse_name

function parse_string(tk::Tokenizer)

end  # function parse_string

"""
    parse_numeric(tk::Tokenizer)

Tokenize a Fortran numerical value.
"""
function parse_numeric(tk::Tokenizer)
    word = ""
    frac = false

    if tk.char == '-'
        word *= tk.char
        update_chars(tk)
    end

    while isdigit(tk.char) || (tk.char == '.' && !frac)
        # Only allow one decimal point
        if tk.char == '.'
            frac = true
        end
        word *= tk.char
        update_chars(tk)
    end

    # Check for float exponent
    if occursin(tk.char, "eEdD")
        word *= tk.char
        update_chars(tk)
    end

    if occursin(tk.char, "+-")
        word *= tk.char
        update_chars(tk)
    end

    while isdigit(self.char)
        word *= tk.char
        update_chars(tk)
    end

    return word
end  # function parse_numeric

isalnum(c) = isletter(c) || isnumeric(c)

end
