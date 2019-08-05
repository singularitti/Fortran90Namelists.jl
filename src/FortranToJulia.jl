"""
# module FortranToJulia

Conversion of Fortran values (as strings) to equivalent Julia values.

The functions in this module are used to convert the string representation of
the values of basic Fortran data types into equivalent Julia values.

# Examples

```jldoctest
julia>
```
"""
module FortranToJulia

using Compat: isnothing

export FortranData, @f_str

struct FortranData{T <: AbstractString}
    data::T
end

macro f_str(str)
    return :(FortranData($str))
end

function Base.parse(::Type{T}, s::FortranData) where {T <: Integer}
    return parse(T, s.data)
end
function Base.parse(::Type{T}, s::FortranData) where {T <: Float32}
    return parse(T, replace(lowercase(s.data), r"(?<=[^e])(?=[+-])" => "f"))
end
function Base.parse(::Type{T}, s::FortranData) where {T <: Float64}
    return parse(T, replace(lowercase(s.data), r"d"i => "e"))
end
function Base.parse(::Type{Complex{T}}, s::FortranData) where {T <: AbstractFloat}
    str = s.data
    if first(str) == '(' && last(str) == ')' && length(split(str, ',')) == 2
        re, im = split(str[2:end - 1], ',', limit = 2)
        return Complex(parse(T, re), parse(T, im))
    else
        throw(ParseError("$str must be in complex number form (x, y)."))
    end
end
function Base.parse(::Type{Bool}, s::FortranData)
    str = lowercase(s.data)
    if str in (".true.", ".t.", "true", 't')
        return true
    elseif str in (".false.", ".f.", "false", 'f')
        return false
    else
        throw(ParseError("$str is not a valid logical constant."))
    end
end
function Base.parse(::Type{T}, s::FortranData) where {T <: AbstractString}
    str = s.data
    m = match(r"([\"'])((?:\\\1|.)*?)\1", str)
    isnothing(m) && throw(ParseError("$str is not a valid string!"))
    quotation_mark, content = m.captures
    # Replace escaped strings
    return string(replace(content, repeat(quotation_mark, 2) => quotation_mark))
end

end
