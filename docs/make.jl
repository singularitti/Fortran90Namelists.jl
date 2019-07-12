using Documenter, Fotran90Namelist

makedocs(;
    modules=[Fotran90Namelist],
    format=Documenter.HTML(),
    pages=[
        "Home" => "index.md",
    ],
    repo="https://github.com/singularitti/Fotran90Namelist.jl/blob/{commit}{path}#L{line}",
    sitename="Fotran90Namelist.jl",
    authors="Qi Zhang <singularitti@outlook.com>",
    assets=String[],
)

deploydocs(;
    repo="github.com/singularitti/Fotran90Namelist.jl",
)
