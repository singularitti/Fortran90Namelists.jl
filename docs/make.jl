using Documenter, Fortran90Namelists

makedocs(;
    modules=[Fortran90Namelists],
    format=Documenter.HTML(),
    pages=[
        "Home" => "index.md",
    ],
    repo="https://github.com/singularitti/Fortran90Namelists.jl/blob/{commit}{path}#L{line}",
    sitename="Fortran90Namelists.jl",
    authors="Qi Zhang <singularitti@outlook.com>",
    assets=String[],
)

deploydocs(;
    repo="github.com/singularitti/Fortran90Namelists.jl",
)
