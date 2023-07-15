export fstring

fstring(number::Integer) = string(number)
fstring(number::Float32) = string(number)
function fstring(number::Float64)
    str = string(number)
    return replace(str, r"e"i => "d")
end
fstring(bool::Bool) = bool ? ".true." : ".false."
function fstring(str::AbstractString)
    escaped_str = replace(str, "\"" => "\"\"")  # escape double quotes within the string
    return "\"$escaped_str\""
end
fstring(array::AbstractVector) = "(/" * join(fstring.(array), ", ") * "/)"
