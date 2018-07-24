using Documenter, GeneNameGenieJ

# makedocs()
makedocs(
   modules = [GeneNameGenieJ],
   clean = false,
   format = :html,
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

# Deploy built documentation from Travis.
# =======================================

# deploydocs(
#     # options
#     repo = "github.com/JuliaData/DataFrames.jl.git",
#     target = "build",
#     julia = "0.6",
#     deps = nothing,
#     make = nothing,
# )