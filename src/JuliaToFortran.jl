"""
# module JuliaToFortran



# Examples

```jldoctest
julia>
```
"""
module JuliaToFortran

using Fortran90Namelists.FortranToJulia

export to_fortran

function to_fortran(v::Int)
    return FortranData(string(v))
end
function to_fortran(v::Float32; scientific::Bool=false)
    str = string(v)
    scientific && return FortranData(replace(str, r"f"i => "e"))
    return FortranData(str)
end
function to_fortran(v::Float64; scientific::Bool=false)
    str = string(v)
    scientific && return FortranData(replace(str, r"e"i => "d"))
    return FortranData(string(v))
end
function to_fortran(v::Bool)
    return v ? FortranData(".true.") : FortranData(".false.")
end
function to_fortran(v::AbstractString)
    return FortranData("'$v'")
end

function Base.string(s::FortranData)
    return string(s.data)
end

end
