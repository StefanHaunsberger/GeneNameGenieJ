using Documenter, GeneNameGenieJ

# makedocs()
makedocs(
    format = :html,
    sitename = "GeneNameGenieJ",
    doctest = true,
    pages = Any[
      "Introduction" => "index.md",
      "User Guide" => Any[
          "Getting Started" => "man/getting-started.md",
          "miRNAs" => "man/mirna-functions.md",
          "Molecular-ID handling" => "man/molecular-id-handling.md",
          "Attributes" => "man/attribute-functions.md"
      ]
      # ,
      # "API" => Any[
      #     "Types" => "lib/types.md",
      #     "Functions" => "lib/functions.md"
      # ]
    ]
)
