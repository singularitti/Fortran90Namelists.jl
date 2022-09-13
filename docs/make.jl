using Fortran90Namelists
using Documenter

DocMeta.setdocmeta!(Fortran90Namelists, :DocTestSetup, :(using Fortran90Namelists); recursive=true)

makedocs(;
    modules=[Fortran90Namelists],
    authors="singularitti <singularitti@outlook.com> and contributors",
    repo="https://github.com/singularitti/Fortran90Namelists.jl/blob/{commit}{path}#{line}",
    sitename="Fortran90Namelists.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://singularitti.github.io/Fortran90Namelists.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/singularitti/Fortran90Namelists.jl",
)
