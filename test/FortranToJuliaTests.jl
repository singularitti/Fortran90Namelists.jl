#=
Mod:
- Julia version: 1.0
- Author: singularitti
- Date: 2019-07-28
=#
module Mod

using Test

using Test

using Fortran90Namelists.FortranToJulia

# Test data referenced from: http://www-classes.usc.edu/engr/ce/108/text/fbk01.htm.

@testset "Test `parse*` functions" begin
    @test parse(Float32, f"1.0E-6") === 1.0f-6
    @test parse(Float32, f"3.2767e+2") === 3.2767f2
    @test parse(Float32, f"1.89e-14") === 1.89f-14
    @test parse(Float32, f"-0.65e-2") === -0.65f-2
    @test parse(Float32, f"+1e8") === 1f8

    @test parse(Float64, f"1.0D-6") === 1.0e-6
    @test parse(Float64, f"1d-8") === 1e-8
    @test parse(Float64, f"0.") === 0.
    @test parse(Float64, f"1.00") === 1.00
    @test parse(Float64, f"+3.141593") === 3.141593
    @test parse(Float64, f"+3.1415926535d+0") === +3.1415926535
    @test parse(Float64, f"-4.78d+6") === -4.78e6
    @test parse(Float64, f"1.0d+0") === 1.0

    @test parse(Complex{Float64}, f"(5.229, -4.78)") === Complex(5.229, -4.78)
    @test parse(Complex{Float64}, f"(0.0,1.0)") === Complex(0.0, 1.0)
    @test parse(Complex{Float64}, f"(0.0,1)") === Complex(0.0, 1)
    @test parse(Complex{Float32}, f"(3.2767e+2, -0.65e-2)") === Complex{Float32}(3.2767e2, -0.65e-2)

    @test parse(Int, f"124") === 124
    @test parse(Int, f"-448") === -448
    @test parse(Int, f"0") === 0
    @test parse(Int, f"32767") === 32767
    @test parse(Int, f"2147483647") === 2147483647
    @test parse(Int, f"-9874") === -9874

    @test parse(Bool, f".true.") === true
    @test parse(Bool, f".t.") === true
    @test parse(Bool, f".false.") === false
    @test parse(Bool, f".f.") === false

    @test parse(String, f"''") === ""
    @test parse(String, f"\"./tmp234\"") === "./tmp234"
    @test parse(String, f"'david'") === "david"
end  # testset

end
