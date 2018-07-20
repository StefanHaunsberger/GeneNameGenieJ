using Documenter, GeneNameGenieJ

# makedocs()
makedocs(
    format = :html,
    modules = [GeneNameGenieJ],
    sitename = "GeneNameGenieJ.jl",
    doctest = false,
    pages = Any[
      "Introduction" => "index.md",
      "User Guide" => Any[
          "Getting Started" => "man/getting-started.md",
          "miRNAs" => "man/mirna-functions.md",
          "Molecular-ID handling" => "man/molecular-id-handling.md",
          "Attributes" => "man/attribute-functions.md"
      ],
      "API" => Any[
          "Functions" => "lib/functions.md"
      ]
    ]
)
