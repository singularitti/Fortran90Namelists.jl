export lex

@enum LexemeType BEGIN END NAME VARIABLE EQUALS VALUE COMMA SPACE COMMENT

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
