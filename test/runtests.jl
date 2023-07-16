using Fortran90Namelists
using Test

@testset "Fortran90Namelists.jl" begin
    include("fparse.jl")
    include("Tokenizer.jl")
end
