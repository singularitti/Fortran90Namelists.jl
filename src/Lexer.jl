export lex!

@enum Lexeme begin
    BEGIN
    END
    GROUP_NAME
    VARIABLE
    EQUALS
    ARRAY
    DICT
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
            if word == "%"
                push!(lexemes, (word, DICT))
            else
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
            end
        else
            while !(isspace(lx.char) || lx.char in PUNCTUATION)
                word *= lx.char
                update!(lx, chars)
            end
            if lx.char == '('
                lx.char = '\0'  # Consume the bracket
                while lx.char != ')'
                    word *= lx.char
                    update!(lx, chars)
                end
                word *= lx.char  # Include the closing bracket
                update!(lx, chars)
                push!(lexemes, (word, ARRAY))
            elseif isvalidname(word)
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
