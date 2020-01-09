using Fortran90Namelists
using Documenter

makedocs(;
    modules=[Fortran90Namelists],
    authors="Qi Zhang <singularitti@outlook.com>",
    repo="https://github.com/singularitti/Fortran90Namelists.jl/blob/{commit}{path}#L{line}",
    sitename="Fortran90Namelists.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://singularitti.github.io/Fortran90Namelists.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/singularitti/Fortran90Namelists.jl",
)
