export lex!, lex

@enum Lexeme begin
    BEGIN
    END
    GROUP_NAME
    VARIABLE
    EQUALS
    VALUE
    STRING
    OPERATOR
    COMMA
    SPACE
    COMMENT
end

function lex!(lx::Tokenizer, line)
    lexemes = Tuple{String,Lexeme}[]
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
        elseif lx.char in COMMENT_IDENTIFIERS || lx.group_token === '\0'
            word = line[(lx.index):end]
            lx.char = '\n'
            push!(lexemes, (word, COMMENT))
        elseif lx.char in ('\'', '"') || lx.prior_delim !== '\0'
            word = tokenizestr!(lx, chars)
            push!(lexemes, (word, STRING))
        elseif lx.char in PUNCTUATION
            word *= lx.char
            update!(lx, chars)
            push!(lexemes, (
                word,
                if word == "="
                    EQUALS
                elseif word == ","
                    COMMA
                elseif word in PUNCTUATION
                    OPERATOR
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
                    push!(lexemes, (word, GROUP_NAME))
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
