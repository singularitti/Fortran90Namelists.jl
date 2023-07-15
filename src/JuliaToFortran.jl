export to_fortran

function to_fortran(v::Integer)
    return FortranData(string(v))
end
function to_fortran(v::Float32, scientific=false)
    str = string(v)
    if scientific
        return FortranData(replace(str, r"f"i => "e"))
    else
        return FortranData(str)
    end
end
function to_fortran(v::Float64, scientific=false)
    str = string(v)
    if scientific
        return FortranData(replace(str, r"e"i => "d"))
    else
        return FortranData(string(v))
    end
end
function to_fortran(v::Bool)
    return v ? FortranData(".true.") : FortranData(".false.")
end
function to_fortran(v::AbstractString)
    return FortranData("'$v'")
end
