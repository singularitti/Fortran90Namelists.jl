export Lexer, lex!, lex

@enum LexemeType BEGIN END NAME VARIABLE EQUALS VALUE COMMA SPACE COMMENT

mutable struct Lexer
    index::Int64
    prior_char::Char
    char::Char
    prior_delim::Char
    group_token::Char
    Lexer(index=0, prior_char='\0', char='\0', prior_delim='\0', group_token='\0') =
        new(index, prior_char, char, prior_delim, group_token)
end

function lex!(lx::Lexer, line)
    lexemes = Tuple{String,LexemeType}[]
    lx.index = 0
    chars = Iterators.Stateful(line)
    update!(lx, chars)
    while lx.char != '\n'
        word = ""
        if (lx.group_token == '&' && lx.char == '/') ||
            (lx.group_token == '$' && lx.char == '$')
            lx.group_token = '\0'
            word *= lx.char
            update!(lx, chars)
            push!(lexemes, (word, END))
        elseif lx.char in ('&', '$')
            lx.group_token = lx.char
            word *= lx.char
            update!(lx, chars)
            push!(lexemes, (word, BEGIN))
        elseif lx.char in WHITESPACE
            while lx.char in WHITESPACE
                word *= lx.char
                update!(lx, chars)
            end
            push!(lexemes, (word, SPACE))
        elseif lx.char == '!' || lx.group_token === '\0'
            word = line[(lx.index):end]
            lx.char = '\n'
            push!(lexemes, (word, COMMENT))
        elseif lx.char in ('\'', '"') || lx.prior_delim !== '\0'
            word = tokenizestr!(lx, chars)
            push!(lexemes, (word, VALUE))  # String tokens are treated as values
        elseif lx.char in PUNCTUATION
            word *= lx.char
            update!(lx, chars)
            push!(lexemes, (
                word,
                if word == "="
                    EQUALS
                elseif word == ","
                    COMMA
                else
                    error("unsupported punctuation: `$word`!")
                end,
            ))
        else
            while !(isspace(lx.char) || lx.char in PUNCTUATION)
                word *= lx.char
                update!(lx, chars)
            end
            if isvalidname(word)
                if !isempty(lexemes) && last(lexemes)[2] == BEGIN
                    push!(lexemes, (word, NAME))
                else
                    push!(lexemes, (word, VARIABLE))
                end
            else
                push!(lexemes, (word, VALUE))
            end
        end
    end
    return lexemes
end

function lex(tokens)
    lexemes = Tuple{String,LexemeType}[]
    for token in tokens
        if iswhitespace(token)
            push!(lexemes, (token, SPACE))
        elseif startswith(token, "!")
            push!(lexemes, (token, COMMENT))
        elseif token in ("&", raw"$")
            push!(lexemes, (token, BEGIN))
        elseif token in ("/", raw"$")
            push!(lexemes, (token, END))
        elseif token == "="
            push!(lexemes, (token, EQUALS))
        elseif token == ","
            push!(lexemes, (token, COMMA))
        elseif isvalidname(token)
            # If a NAME token follows a BEGIN token, it's a group name.
            # Otherwise, it's a variable name.
            if !isempty(lexemes) && last(lexemes)[2] == BEGIN
                push!(lexemes, (token, NAME))
            else
                push!(lexemes, (token, VARIABLE))
            end
        else
            push!(lexemes, (token, VALUE))
        end
    end
    return lexemes
end

function update!(lx::Lexer, chars::Iterators.Stateful)
    lx.prior_char, lx.char = lx.char, next(chars, '\n')
    lx.index += 1
    return lx
end

function isvalidname(name::AbstractString)
    # Namelist names must start with letter or underscore
    char = first(name)
    if !(isletter(char) || char == '_')
        return false
    end
    # Rest of name can contain letters, numbers and underscores
    for char in name[2:end]
        if !(isletter(char) || isnumeric(char) || char == '_')
            return false
        end
    end
    return true
end

iswhitespace(token) = all(in(WHITESPACE), token)
