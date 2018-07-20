# Handling 47 different molecluar IDs

## Translate input Ids to current version and retrieve metadata

The `getOfficialGeneSymbol` function can be used to retrieve the official gene symbol for any given molecular identifier
without having to provide the input ID type (optional).
Let us assume we want to find the official gene symbol for the following molecular
identifiers: 'AMPK', 'Bcl-2', '596' and 'NM_000657'. We can use the `getOfficialGeneSymbol`
function to retrieve the official gene symbol for each input identifier respectively.

```jldoctest molecularids
julia> ids = String["P10415", "AMPK", "ENSP00000381185", "ENST00000589955", "A0A024R2B3", "596"]
julia> getOfficialGeneSymbol(ids)
WARNING: Some input IDs have multiple mappings
9×3 DataFrames.DataFrame
│ Row │ InputId         │ InputSourceDb             │ OfficialGeneSymbol │
├─────┼─────────────────┼───────────────────────────┼────────────────────┤
│ 1   │ ENST00000589955 │ Ensembl Human Transcript  │ BCL2               │
│ 2   │ A0A024R2B3      │ UniProtKB Gene Name       │ BCL2               │
│ 3   │ A0A024R2B3      │ UniProtKB/TrEMBL          │ BCL2               │
│ 4   │ P10415          │ UniProtKB Gene Name       │ BCL2               │
│ 5   │ P10415          │ UniProtKB/Swiss-Prot      │ BCL2               │
│ 6   │ 596             │ WikiGene                  │ BCL2               │
│ 7   │ 596             │ NCBI gene                 │ BCL2               │
│ 8   │ AMPK            │ Gene Symbol Alias         │ PRKAA2             │
│ 9   │ ENSP00000381185 │ Ensembl Human Translation │ BCL2               │
```

The output is a data.frame object. Thereby, if warnings appear on the console, affected rows are printed at the top of the results. 
The actual result is the dataframe containing the three columns `InputId`, `InputSourceDb` and `OfficialGeneSymbol`.

Because we have not provided the source database parameter we get a warning that some input identifiers were actually mapped to multiple databases, such as P10415, which is a UniProtKB gene name as well as a UniProtKB/Swiss-Prot protein name.
We can run the same command again with the `Uniprot_gn`, for the UniProtKB Gene Name database, as input source database parameter.

```jldoctest molecularids
julia> ids = String["P10415", "AMPK", "ENSP00000381185", "ENST00000589955", "A0A024R2B3", "596"]
julia> getOfficialGeneSymbol(ids, sourceDb = "Uniprot_gn")
WARNING: No values found for:
AMPK
ENSP00000381185
ENST00000589955
596
2×3 DataFrames.DataFrame
│ Row │ InputId    │ InputSourceDb       │ OfficialGeneSymbol │
├─────┼────────────┼─────────────────────┼────────────────────┤
│ 1   │ A0A024R2B3 │ UniProtKB Gene Name │ BCL2               │
│ 2   │ P10415     │ UniProtKB Gene Name │ BCL2               │
```

This time we only received the official gene symbol for input identifiers which are from the 
UniProtKB gene name database.

The function `getValidDatabases` can be used to look up valid `sourceDb` values.

## Convert identifiers from and to different databases

With the `convertFromTo` function we can convert any given identifier to any supported 
target database. In the following example we are want to get all identifiers from 
`"Uniprot/SWISSPROT"`, `"Uniprot/SPTREMBL"`, `"EntrezGene"` for the `"BCL2"` and `"AMPK"`.

```jldoctest molecularids
julia> convertFromTo(String["BCL2", "AMPK"], targetDb = String["Uniprot/SWISSPROT", "Uniprot/SPTREMBL", "EntrezGene"])
7×4 DataFrames.DataFrame
│ Row │ InputId │ InputSourceDb        │ TargetDb             │ TargetId   │
├─────┼─────────┼──────────────────────┼──────────────────────┼────────────┤
│ 1   │ BCL2    │ Official Gene Symbol │ UniProtKB/Swiss-Prot │ P10415     │
│ 2   │ BCL2    │ Official Gene Symbol │ UniProtKB/TrEMBL     │ A0A024R2B3 │
│ 3   │ BCL2    │ Official Gene Symbol │ UniProtKB/TrEMBL     │ A0A024R2C4 │
│ 4   │ BCL2    │ Official Gene Symbol │ NCBI gene            │ 596        │
│ 5   │ AMPK    │ Gene Symbol Alias    │ UniProtKB/Swiss-Prot │ P54646     │
│ 6   │ AMPK    │ Gene Symbol Alias    │ UniProtKB/TrEMBL     │ A0A087WXX9 │
│ 7   │ AMPK    │ Gene Symbol Alias    │ NCBI gene            │ 5563       │
```