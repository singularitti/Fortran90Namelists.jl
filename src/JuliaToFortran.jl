export fstring

function fstring(v::Integer)
    return FortranData(string(v))
end
function fstring(v::Float32, scientific=false)
    str = string(v)
    if scientific
        return FortranData(replace(str, r"f"i => "e"))
    else
        return FortranData(str)
    end
end
function fstring(v::Float64, scientific=false)
    str = string(v)
    if scientific
        return FortranData(replace(str, r"e"i => "d"))
    else
        return FortranData(string(v))
    end
end
function fstring(v::Bool)
    return v ? FortranData(".true.") : FortranData(".false.")
end
function fstring(v::AbstractString)
    return FortranData("'$v'")
end
