using Fortran90Namelists
using Test

@testset "Fortran90Namelists.jl" begin
    include("FortranToJuliaTests.jl")
    include("TokenizeTests.jl")
end
