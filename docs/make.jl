using Documenter, GeneNameGenieJ

# makedocs()
makedocs(
    format = :html,
    sitename = "GeneNameGenieJ",
    pages = [
        "page.md",
        "Page title" => "page2.md"
      #   "Subsection" => [
      #       ...
      #   ]
    ]
)
