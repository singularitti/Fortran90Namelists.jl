export FortranData, @f_str

struct FortranData
    data::String
end

macro f_str(str)
    return :(FortranData($str))
end

function Base.parse(::Type{T}, s::FortranData) where {T<:Integer}
    return parse(T, s.data)
end
function Base.parse(::Type{Float32}, s::FortranData)
    return parse(Float32, replace(lowercase(s.data), r"(?<=[^e])(?=[+-])" => "f"))
end
function Base.parse(::Type{Float64}, s::FortranData)
    return parse(Float64, replace(lowercase(s.data), r"d"i => "e"))
end
function Base.parse(::Type{Complex{T}}, s::FortranData) where {T<:AbstractFloat}
    str = s.data
    if first(str) == '(' && last(str) == ')' && length(split(str, ',')) == 2
        re, im = split(str[2:(end - 1)], ','; limit=2)
        return Complex(parse(T, re), parse(T, im))
    else
        throw(Meta.ParseError("$str must be in complex number form (x, y)."))
    end
end
function Base.parse(::Type{Bool}, s::FortranData)
    str = lowercase(s.data)
    if str in (".true.", ".t.", "true", 't')
        return true
    elseif str in (".false.", ".f.", "false", 'f')
        return false
    else
        throw(Meta.ParseError("$str is not a valid logical constant."))
    end
end
function Base.parse(::Type{String}, s::FortranData)
    str = s.data
    m = match(r"([\"'])((?:\\\1|.)*?)\1", str)
    if m === nothing
        throw(Meta.ParseError("$str is not a valid string!"))
    else
        quotation_mark, content = m.captures
        # Replace escaped strings
        return string(replace(content, repeat(quotation_mark, 2) => quotation_mark))
    end
end
