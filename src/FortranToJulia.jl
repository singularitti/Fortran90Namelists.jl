export fparse

fparse(::Type{T}, str::AbstractString) where {T<:Integer} = parse(T, str.data)
function fparse(::Type{Float32}, str::AbstractString)
    return parse(Float32, replace(lowercase(str.data), r"(?<=[^e])(?=[+-])" => "f"))
end
function fparse(::Type{Float64}, str::AbstractString)
    return parse(Float64, replace(lowercase(str.data), r"d"i => "e"))
end
function fparse(::Type{Complex{T}}, str::AbstractString) where {T<:AbstractFloat}
    str = str.data
    if first(str) == '(' && last(str) == ')' && length(split(str, ',')) == 2
        re, im = split(str[2:(end - 1)], ','; limit=2)
        return Complex(parse(T, re), parse(T, im))
    else
        throw(Meta.ParseError("$str must be in complex number form (x, y)."))
    end
end
function fparse(::Type{Bool}, str::AbstractString)
    str = lowercase(str.data)
    if str in (".true.", ".t.", "true", 't')
        return true
    elseif str in (".false.", ".f.", "false", 'f')
        return false
    else
        throw(Meta.ParseError("$str is not a valid logical constant."))
    end
end
function fparse(::Type{String}, str::AbstractString)
    str = str.data
    m = match(r"([\"'])((?:\\\1|.)*?)\1", str)
    if m === nothing
        throw(Meta.ParseError("$str is not a valid string!"))
    else
        quotation_mark, content = m.captures
        # Replace escaped strings
        return string(replace(content, repeat(quotation_mark, 2) => quotation_mark))
    end
end
