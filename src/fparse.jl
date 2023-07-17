export fparse

struct ParseError <: Exception
    msg::String
end

fparse(::Type{T}, str::AbstractString) where {T<:Integer} = Base.parse(T, str)
fparse(::Type{Float32}, str::AbstractString) =
    Base.parse(Float32, replace(lowercase(str), r"(?<=[^E])(?=[+-])"i => "f"))
fparse(::Type{Float64}, str::AbstractString) =
    Base.parse(Float64, replace(lowercase(str), r"D"i => "e"))
function fparse(::Type{Complex{T}}, str::AbstractString) where {T<:AbstractFloat}
    if first(str) == '(' && last(str) == ')' && length(split(str, ',')) == 2
        re, im = split(str[2:(end - 1)], ','; limit=2)
        return Complex(Base.parse(T, re), Base.parse(T, im))
    else
        throw(ParseError("`$str` must be in complex number form (x, y)."))
    end
end
function fparse(::Type{Bool}, str::AbstractString)
    str = lowercase(str)
    if str in (".true.", ".t.", "true")
        return true
    elseif str in (".false.", ".f.", "false")
        return false
    else
        throw(ParseError("`$str` is not a valid logical constant."))
    end
end
function fparse(::Type{String}, str::AbstractString)
    matched = match(r"([\"'])((?:\\\1|.)*?)\1", str)
    if matched === nothing
        throw(ParseError("`$str` is not a valid string!"))
    else
        quotation_mark, content = matched.captures
        # Replace escaped strings
        return string(replace(content, repeat(quotation_mark, 2) => quotation_mark))
    end
end
