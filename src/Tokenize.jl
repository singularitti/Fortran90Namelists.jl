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
            tk.characters, lookahead = itertools.tee(tk.characters)
            ieee_val = join(takewhile(isalpha, lookahead), "")
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
                while tk.char.isalpha()
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
end  # function Base.parse

function parse_name(tk::Tokenizer, line)

end  # function parse_name

function parse_string(tk::Tokenizer)

end  # function parse_string

function parse_numeric(tk::Tokenizer)

end  # function parse_numeric

end
