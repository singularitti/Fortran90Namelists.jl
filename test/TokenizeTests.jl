#=
TokenizeTests:
- Julia version: 1.0
- Author: singularitti
- Date: 2019-08-02
=#
module TokenizeTests

using Test

using Fortran90Namelists.Tokenize

@testset "" begin
    tk = Tokenizer()
    benchmark = [['&', "string_nml"],
    ["    ", "str_basic", ' ', '=', ' ', "'hello'"],
    ["    ", "str_no_delim", ' ', '=', ' ', "hello"],
    ["    ", "str_no_delim_no_esc", ' ', '=', ' ', "a''b"],
    ["    ", "single_esc_delim", ' ', '=', ' ', "'a ''single'' delimiter'"],
    ["    ", "double_esc_delim", ' ', '=', ' ', "\"a \"\"double\"\" delimiter\""],
    ["    ", "double_nested", ' ', '=', ' ', "\"\'\'x\'\' \"\"y\"\"\""],
    ["    ", "str_list", ' ', '=', ' ', "'a'", ',', ' ', "'b'", ',', ' ', "'c'"],
    ["    ", "slist_no_space", ' ', '=', ' ', "'a'", ',', "'b'", ',', "'c'"],
    ["    ", "slist_no_quote", ' ', '=', ' ', 'a', ',', 'b', ',', 'c'],
    ["    ", "slash", ' ', '=', ' ', "'back\\slash'"],
    ['/']]
    open("test/data/string.nml", "r") do io
        for (i, line) in enumerate(eachline(io))
            @test parse(tk, line) == benchmark[i]
        end
    end
end # testset

end
