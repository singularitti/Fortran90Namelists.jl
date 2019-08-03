#=
TokenizeTests:
- Julia version: 1.0
- Author: singularitti
- Date: 2019-08-02
=#
module TokenizeTests

using Test

using Fortran90Namelists.Tokenize

@testset "Test string" begin
    benchmark = [["&", "string_nml"],
    ["    ", "str_basic", " ", "=", " ", "'hello'"],
    ["    ", "str_no_delim", " ", "=", " ", "hello"],
    ["    ", "str_no_delim_no_esc", " ", "=", " ", "a''b"],
    ["    ", "single_esc_delim", " ", "=", " ", "'a ''single'' delimiter'"],
    ["    ", "double_esc_delim", " ", "=", " ", "\"a \"\"double\"\" delimiter\""],
    ["    ", "double_nested", " ", "=", " ", "\"''x'' \"\"y\"\"\""],
    ["    ", "str_list", " ", "=", " ", "'a'", ",", " ", "'b'", ",", " ", "'c'"],
    ["    ", "slist_no_space", " ", "=", " ", "'a'", ",", "'b'", ",", "'c'"],
    ["    ", "slist_no_quote", " ", "=", " ", "a", ",", "b", ",", "c"],
    ["    ", "slash", " ", "=", " ", "'back\\slash'"],
    ["/"]]
    tk = Tokenizer()
    open("test/data/string.nml", "r") do io
        for (i, line) in enumerate(eachline(io))
            @test parse(tk, line) == benchmark[i]
        end
    end
end # testset

@testset "Test dollar" begin
    benchmark = [[raw"$", "dollar_nml"],
    ["    ", "v", " ", "=", " ", "1.00"],
    [raw"$"]]
    tk = Tokenizer()
    open(joinpath(dirname(@__FILE__), "data/dollar.nml"), "r") do io
        for (i, line) in enumerate(eachline(io))
            @test parse(tk, line) == benchmark[i]
        end
    end
end # testset

@testset "Test dollar target" begin
    benchmark = [["&", "dollar_nml"],
    ["    ", "v", " ", "=", " ", "1.0"],
    ["/"]]
    tk = Tokenizer()
    open(joinpath(dirname(@__FILE__), "data/dollar_target.nml"), "r") do io
        for (i, line) in enumerate(eachline(io))
            @test parse(tk, line) == benchmark[i]
        end
    end
end # testset

@testset "Test comment argument" begin
    benchmark = [["&", "comment_alt_nml"],
    ["    ", "x", " ", "=", " ", "1"],
    ["    ", "#y = 2"],
    ["    ", "z", " ", "=", " ", "3"],
    ["/"]]
    tk = Tokenizer()
    open(joinpath(dirname(@__FILE__), "data/comment_alt.nml"), "r") do io
        for (i, line) in enumerate(eachline(io))
            @test parse(tk, line) == benchmark[i]
        end
    end
end # testset

@testset "Test comment patch" begin
    benchmark = [["! This is an external comment"],
    ["&", "comment_nml"],
    ["    ", "v_cmt_inline", " ", "=", " ", "456", "  ", "! This is an inline comment"],
    ["    ", "! This is a separate comment"],
    ["    ", "v_cmt_in_str", " ", "=", " ", "'This token ! is not a comment'"],
    ["    ", "v_cmt_after_str", " ", "=", " ", "'This ! is not a comment'", " ", "! But this is"],
    ["/"],
    ["! This is a post-namelist comment"]]
    tk = Tokenizer()
    open(joinpath(dirname(@__FILE__), "data/comment_patch.nml"), "r") do io
        for (i, line) in enumerate(eachline(io))
            @test parse(tk, line) == benchmark[i]
        end
    end
end # testset

@testset "Test comment target" begin
    benchmark = [["&", "comment_nml"],
    ["    ", "v_cmt_inline", " ", "=", " ", "123"],
    ["    ", "v_cmt_in_str", " ", "=", " ", "'This token ! is not a comment'"],
    ["    ", "v_cmt_after_str", " ", "=", " ", "'This ! is not a comment'"],
    ["/"]]
    tk = Tokenizer()
    open(joinpath(dirname(@__FILE__), "data/comment_target.nml"), "r") do io
        for (i, line) in enumerate(eachline(io))
            @test parse(tk, line) == benchmark[i]
        end
    end
end # testset

@testset "Test comment" begin
    benchmark = [["! This is an external comment"],
    ["&", "comment_nml"],
    ["    ", "v_cmt_inline", " ", "=", " ", "123", "  ", "! This is an inline comment"],
    ["    ", "! This is a separate comment"],
    ["    ", "v_cmt_in_str", " ", "=", " ", "'This token ! is not a comment'"],
    ["    ", "v_cmt_after_str", " ", "=", " ", "'This ! is not a comment'", " ", "! But this is"],
    ["/"],
    ["! This is a post-namelist comment"]]
    tk = Tokenizer()
    open(joinpath(dirname(@__FILE__), "data/comment.nml"), "r") do io
        for (i, line) in enumerate(eachline(io))
            @test parse(tk, line) == benchmark[i]
        end
    end
end # testset

@testset "Test default index" begin
    benchmark = [["&", "default_index_nml"],
    ["    ", "v", "(", "3", ":", "5", ")", " ", "=", " ", "3", ",", " ", "4", ",", " ", "5"],
    ["    ", "v", " ", "=", " ", "1", ",", " ", "2"],
    ["/"]]
    tk = Tokenizer()
    open(joinpath(dirname(@__FILE__), "data/default_index.nml"), "r") do io
        for (i, line) in enumerate(eachline(io))
            @test parse(tk, line) == benchmark[i]
        end
    end
end # testset

end
