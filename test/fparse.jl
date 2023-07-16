# Test data referenced from: http://www-classes.usc.edu/engr/ce/108/text/fbk01.htm.
@testset "Test `fparse*` functions" begin
    @test fparse(Float32, "1.0E-6") === 1.0f-6
    @test fparse(Float32, "3.2767e+2") === 3.2767f2
    @test fparse(Float32, "1.89e-14") === 1.89f-14
    @test fparse(Float32, "-0.65e-2") === -0.65f-2
    @test fparse(Float32, "+1e8") === 1.0f8

    @test fparse(Float64, "1.0D-6") === 1.0e-6
    @test fparse(Float64, "1d-8") === 1e-8
    @test fparse(Float64, "0.") === 0.0
    @test fparse(Float64, "1.00") === 1.00
    @test fparse(Float64, "+3.141593") === 3.141593
    @test fparse(Float64, "+3.1415926535d+0") === +3.1415926535
    @test fparse(Float64, "-4.78d+6") === -4.78e6
    @test fparse(Float64, "1.0d+0") === 1.0

    @test fparse(Complex{Float64}, "(5.229, -4.78)") === Complex(5.229, -4.78)
    @test fparse(Complex{Float64}, "(0.0,1.0)") === Complex(0.0, 1.0)
    @test fparse(Complex{Float64}, "(0.0,1)") === Complex(0.0, 1)
    @test fparse(Complex{Float32}, "(3.2767e+2, -0.65e-2)") ===
        Complex{Float32}(3.2767e2, -0.65e-2)

    @test fparse(Int, "124") === 124
    @test fparse(Int, "-448") === -448
    @test fparse(Int, "0") === 0
    @test fparse(Int, "32767") === 32767
    @test fparse(Int, "2147483647") === 2147483647
    @test fparse(Int, "-9874") === -9874

    @test fparse(Bool, ".true.") === true
    @test fparse(Bool, ".t.") === true
    @test fparse(Bool, ".false.") === false
    @test fparse(Bool, ".f.") === false

    @test fparse(String, "''") === ""
    @test fparse(String, "\"./tmp234\"") === "./tmp234"
    @test fparse(String, "'david'") === "david"
end
