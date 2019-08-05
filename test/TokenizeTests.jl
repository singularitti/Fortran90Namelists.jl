#=
TokenizeTests:
- Julia version: 1.0
- Author: singularitti
- Date: 2019-08-02
=#
module TokenizeTests

using Test

using Fortran90Namelists.Tokenize

@testset "Test bcast" begin
    benchmark = [["&", "bcast_nml"],
    ["    ", "x", " ", "=", " ", "2", "*", "2.0"],
    ["    ", "y", " ", "=", " ", "3", "*"],
    ["    ", "z", " ", "=", " ", "4", "*", ".true."],
    ["/"],
    [],
    ["&", "bcast_endnull_nml"],
    ["    ", "x", " ", "=", " ", "2", "*", "2.0"],
    ["    ", "y", " ", "=", " ", "3", "*"],
    ["/"],
    [],
    ["&", "bcast_mixed_nml"],
    ["    ", "x", " ", "=", " ", "3", "*", "1", ",", " ", "2", ",", " ", "3", ",", " ", "4"],
    ["    ", "y", " ", "=", " ", "3", "*", "1", ",", " ", "2", "*", "2", ",", " ", "3"],
    ["/"]]
    tk = Tokenizer()
    open(joinpath(dirname(@__FILE__), "data/bcast.nml"), "r") do io
        for (i, line) in enumerate(eachline(io))
            @test parse(tk, line) == benchmark[i]
        end
    end
end # testset

@testset "Test bcast target" begin
    benchmark = [["&", "bcast_nml"],
    ["    ", "x", " ", "=", " ", "2.0", ",", " ", "2.0"],
    ["    ", "y", " ", "=", " ", ",", " ", ",", " ", ","],
    ["    ", "z", " ", "=", " ", ".true.", ",", " ", ".true.", ",", " ", ".true.", ",", " ", ".true."],
    ["/"],
    [],
    ["&", "bcast_endnull_nml"],
    ["    ", "x", " ", "=", " ", "2.0", ",", " ", "2.0"],
    ["    ", "y", " ", "=", " ", ",", " ", ",", " ", ","],
    ["/"],
    [],
    ["&", "bcast_mixed_nml"],
    ["    ", "x", " ", "=", " ", "1", ",", " ", "1", ",", " ", "1", ",", " ", "2", ",", " ", "3", ",", " ", "4"],
    ["    ", "y", " ", "=", " ", "1", ",", " ", "1", ",", " ", "1", ",", " ", "2", ",", " ", "2", ",", " ", "3"],
    ["/"]]
    tk = Tokenizer()
    open(joinpath(dirname(@__FILE__), "data/bcast_target.nml"), "r") do io
        for (i, line) in enumerate(eachline(io))
            @test parse(tk, line) == benchmark[i]
        end
    end
end # testset

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
    open(joinpath(dirname(@__FILE__), "data/string.nml"), "r") do io
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

@testset "Test empty namelist" begin
    benchmark = [["&", "empty_nml"],
    ["/"]]
    tk = Tokenizer()
    open(joinpath(dirname(@__FILE__), "data/empty.nml"), "r") do io
        for (i, line) in enumerate(eachline(io))
            @test parse(tk, line) == benchmark[i]
        end
    end
end # testset

@testset "Test external token" begin
    benchmark = [["a"],
    ["123"],
    ["&", "ext_token_nml"],
    ["    ", "x", " ", "=", " ", "1"],
    ["/"],
    ["456"],
    ["z"]]
    tk = Tokenizer()
    open(joinpath(dirname(@__FILE__), "data/ext_token.nml"), "r") do io
        for (i, line) in enumerate(eachline(io))
            @test parse(tk, line) == benchmark[i]
        end
    end
end # testset

# FIXME:
# @testset "Test external comment" begin
#     benchmark = [[],
#     ["&", "efitin"],
#     ["abc", " ", "=", " ", "0"],
#     ["/"]]
#     tk = Tokenizer()
#     open(joinpath(dirname(@__FILE__), "data/extern_cmt.nml"), "r") do io
#         for (i, line) in enumerate(eachline(io))
#             @test parse(tk, line) == benchmark[i]
#         end
#     end
# end # testset

@testset "Test float" begin
    benchmark = [["&", "float_nml"],
    ["    ", "v_float", " ", "=", " ", "1.0"],
    ["    ", "v_decimal_start", " ", "=", " ", ".1"],
    ["    ", "v_decimal_end", " ", "=", " ", "1."],
    ["    ", "v_negative", " ", "=", " ", "-1."],
    [],
    ["    ", "v_single", " ", "=", " ", "1.0e0"],
    ["    ", "v_double", " ", "=", " ", "1.0d0"],
    [],
    ["    ", "v_single_upper", " ", "=", " ", "1.0E0"],
    ["    ", "v_double_upper", " ", "=", " ", "1.0D0"],
    [],
    ["    ", "v_positive_index", " ", "=", " ", "1.0e+01"],
    ["    ", "v_negative_index", " ", "=", " ", "1.0e-01"],
    [],
    ["    ", "v_no_exp_pos", " ", "=", " ", "1+0"],
    ["    ", "v_no_exp_neg", " ", "=", " ", "1-0"],
    ["    ", "v_no_exp_pos_dot", " ", "=", " ", "1.+0"],
    ["    ", "v_no_exp_neg_dot", " ", "=", " ", "1.-0"],
    ["    ", "v_neg_no_exp_pos", " ", "=", " ", "-1+0"],
    ["    ", "v_neg_no_exp_neg", " ", "=", " ", "-1-0"],
    ["/"]]
    tk = Tokenizer()
    open(joinpath(dirname(@__FILE__), "data/float.nml"), "r") do io
        for (i, line) in enumerate(eachline(io))
            @test parse(tk, line) == benchmark[i]
        end
    end
end # testset

@testset "Test float target" begin
    benchmark = [["&", "float_nml"],
    ["    ", "v_float", " ", "=", " ", "1.0"],
    ["    ", "v_decimal_start", " ", "=", " ", "0.1"],
    ["    ", "v_decimal_end", " ", "=", " ", "1.0"],
    ["    ", "v_negative", " ", "=", " ", "-1.0"],
    ["    ", "v_single", " ", "=", " ", "1.0"],
    ["    ", "v_double", " ", "=", " ", "1.0"],
    ["    ", "v_single_upper", " ", "=", " ", "1.0"],
    ["    ", "v_double_upper", " ", "=", " ", "1.0"],
    ["    ", "v_positive_index", " ", "=", " ", "10.0"],
    ["    ", "v_negative_index", " ", "=", " ", "0.1"],
    ["    ", "v_no_exp_pos", " ", "=", " ", "1.0"],
    ["    ", "v_no_exp_neg", " ", "=", " ", "1.0"],
    ["    ", "v_no_exp_pos_dot", " ", "=", " ", "1.0"],
    ["    ", "v_no_exp_neg_dot", " ", "=", " ", "1.0"],
    ["    ", "v_neg_no_exp_pos", " ", "=", " ", "-1.0"],
    ["    ", "v_neg_no_exp_neg", " ", "=", " ", "-1.0"],
    ["/"]]
    tk = Tokenizer()
    open(joinpath(dirname(@__FILE__), "data/float_target.nml"), "r") do io
        for (i, line) in enumerate(eachline(io))
            @test parse(tk, line) == benchmark[i]
        end
    end
end # testset

@testset "Test float format" begin
    benchmark = [["&", "float_nml"],
    ["    ", "v_float", " ", "=", " ", "1.000"],
    ["    ", "v_decimal_start", " ", "=", " ", "0.100"],
    ["    ", "v_decimal_end", " ", "=", " ", "1.000"],
    ["    ", "v_negative", " ", "=", " ", "-1.000"],
    ["    ", "v_single", " ", "=", " ", "1.000"],
    ["    ", "v_double", " ", "=", " ", "1.000"],
    ["    ", "v_single_upper", " ", "=", " ", "1.000"],
    ["    ", "v_double_upper", " ", "=", " ", "1.000"],
    ["    ", "v_positive_index", " ", "=", " ", "10.000"],
    ["    ", "v_negative_index", " ", "=", " ", "0.100"],
    ["    ", "v_no_exp_pos", " ", "=", " ", "1.000"],
    ["    ", "v_no_exp_neg", " ", "=", " ", "1.000"],
    ["    ", "v_no_exp_pos_dot", " ", "=", " ", "1.000"],
    ["    ", "v_no_exp_neg_dot", " ", "=", " ", "1.000"],
    ["    ", "v_neg_no_exp_pos", " ", "=", " ", "-1.000"],
    ["    ", "v_neg_no_exp_neg", " ", "=", " ", "-1.000"],
    ["/"]]
    tk = Tokenizer()
    open(joinpath(dirname(@__FILE__), "data/float_format.nml"), "r") do io
        for (i, line) in enumerate(eachline(io))
            @test parse(tk, line) == benchmark[i]
        end
    end
end # testset

end
