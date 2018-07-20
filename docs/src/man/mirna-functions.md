# miRNA functions in GeneNameGenieJ

## Translate input Ids to current version and retrieve metadata

Most cases require retrieval of miRNA names for the current miRBase version. The `convertToCurrentMirbaseVersion` function takes a single or multiple input values and returns the current miRNA name for each input value respectively (where possible). The following example illustrates 
a simple use case where a single miRNA is converted to the current miRBase version.

```jldoctest mirna
julia> convertToCurrentMirbaseVersion("hsa-miR-29a")
1×4 DataFrames.DataFrame
│ Row │ InputId     │ Accession    │ CurrentMirna   │ CurrentVersion │
├─────┼─────────────┼──────────────┼────────────────┼────────────────┤
│ 1   │ hsa-miR-29a │ MIMAT0000086 │ hsa-miR-29a-3p │ 22.0           │
```

Moreover, metadata for mature as well as precursor miRNAs, such as comments and reads, can be retrieved by passing the parameter value `metadata` to the function. The function accepts mature miRNA identifiers (miRNA name and MIMAT-accession) as well as precursor identifiers (pre-miRNA name and MI-accession). Hence, some metadata values only apply to precursor miRNAs, such as genomic location and strand.

The following example returns the current miRNA name and metadata for a the mature miRNA name `hsa-miR-29a` and the precursor miRNA name `hsa-mir-29a`.

```jldoctest mirna
julia> convertToCurrentMirbaseVersion(String["hsa-miR-29a", "hsa-mir-29a"], metadata = String["nExperiments", "strand", "reads"])
2×7 DataFrames.DataFrame
│ Row │ InputId     │ Accession    │ CurrentMirna   │ CurrentVersion │ nExperiments │ Strand  │ Reads   │
├─────┼─────────────┼──────────────┼────────────────┼────────────────┼──────────────┼─────────┼─────────┤
│ 1   │ hsa-miR-29a │ MIMAT0000086 │ hsa-miR-29a-3p │ 22.0           │ 77           │ missing │ 2045292 │
│ 2   │ hsa-mir-29a │ MI0000087    │ hsa-mir-29a    │ 22.0           │ 77           │ -       │ 2055333 │
```

As we can see, the strand information is only available for the precursor miRNA. It is to mention that not all metadata information is available for each miRNA. So, for example, the mature miRNA-X could return a value for the `communityAnnotation` metadata value whereas miRNA-Y does not just because one has a value in the database and the other one does not.

**Some more examples:**

```jldoctest mirna
julia> convertToCurrentMirbaseVersion("hsa-mir-29a", metadata = String["sequence", "type", "previousIds"])
1×7 DataFrames.DataFrame
│ Row │ InputId     │ Accession │ CurrentMirna │ CurrentVersion │ Sequence     │ Type      │ PreviousIds │
├─────┼─────────────┼───────────┼──────────────┼────────────────┼──────────────┼───────────┼─────────────┤
│ 1   │ hsa-mir-29a │ MI0000087 │ hsa-mir-29a  │ 22.0           │ AUGA...GUUAU │ antisense │ hsa-mir-29  │
```

```jldoctest mirna
julia> convertToCurrentMirbaseVersion(String["hsa-miR-29a", "MI0000087"], metadata = String["nExperiments", "evidenceType", "reads"])
2×7 DataFrames.DataFrame
│ Row │ InputId     │ Accession    │ CurrentMirna   │ CurrentVersion │ nExperiments │ EvidenceType │ Reads   │
├─────┼─────────────┼──────────────┼────────────────┼────────────────┼──────────────┼──────────────┼─────────┤
│ 1   │ MI0000087   │ MI0000087    │ hsa-mir-29a    │ 22.0           │ 77           │ missing      │ 2055333 │
│ 2   │ hsa-miR-29a │ MIMAT0000086 │ hsa-miR-29a-3p │ 22.0           │ 77           │ experimental │ 2045292 │
```

## Translate mature miRNA names to different miRBase release versions

The `convertMatureMirnasToVersions` function allows for translation of
mature miRNA names to different miRBase release versions.

If no target versions are provided, the name from the highest supported miRBase release version is returned.

```jldoctest mirna
julia> convertMatureMirnasToVersions("hsa-miR-29a")
1×4 DataFrames.DataFrame
│ Row │ InputId     │ MatureAccession │ miRBaseVersion │ TargetMirna    │
├─────┼─────────────┼─────────────────┼────────────────┼────────────────┤
│ 1   │ hsa-miR-29a │ MIMAT0000086    │ 22.0           │ hsa-miR-29a-3p │
```

The following code returns the names for miRBase version 17, 21 and 22 for the mature miRNA `hsa-miR-29a`.

```jldoctest mirna
julia> convertMatureMirnasToVersions("hsa-miR-29a", targetVersion = Int[17, 21, 22])
3×4 DataFrames.DataFrame
│ Row │ InputId     │ MatureAccession │ miRBaseVersion │ TargetMirna    │
├─────┼─────────────┼─────────────────┼────────────────┼────────────────┤
│ 1   │ hsa-miR-29a │ MIMAT0000086    │ 17.0           │ hsa-miR-29a    │
│ 2   │ hsa-miR-29a │ MIMAT0000086    │ 21.0           │ hsa-miR-29a-3p │
│ 3   │ hsa-miR-29a │ MIMAT0000086    │ 22.0           │ hsa-miR-29a-3p │
```

In the case where also the sequence for a specific version is required we can 
pass the parameter `sequence = TRUE` to the function.

```jldoctest mirna
julia> convertMatureMirnasToVersions("hsa-miR-29a", targetVersion = Int[17, 21, 22], sequence = true)
3×5 DataFrames.DataFrame
│ Row │ InputId     │ MatureAccession │ miRBaseVersion │ TargetMirna    │ TargetSequence         │
├─────┼─────────────┼─────────────────┼────────────────┼────────────────┼────────────────────────┤
│ 1   │ hsa-miR-29a │ MIMAT0000086    │ 17.0           │ hsa-miR-29a    │ UAGCACCAUCUGAAAUCGGUUA │
│ 2   │ hsa-miR-29a │ MIMAT0000086    │ 21.0           │ hsa-miR-29a-3p │ UAGCACCAUCUGAAAUCGGUUA │
│ 3   │ hsa-miR-29a │ MIMAT0000086    │ 22.0           │ hsa-miR-29a-3p │ UAGCACCAUCUGAAAUCGGUUA │
```

## List valid databases and supported parameter values

### `getValidDatabases`: for supported database values

The `getValidDatabases` function returns a list of supported database values. The values contained in the `DatabaseId` column are valid as `targetDb` and `sourceDb` parameter values.

```jldoctest mirna
julia> getValidDatabases()
48×2 DataFrames.DataFrame
│ Row │ DatabaseDisplayName              │ DatabaseId                     │
├─────┼──────────────────────────────────┼────────────────────────────────┤
│ 1   │ Ensembl Human Gene               │ ArrayExpress                   │
│ 2   │ CCDS                             │ CCDS                           │
│ 3   │ ChEMBL                           │ ChEMBL                         │
│ 4   │ Clone-based (Ensembl) gene       │ Clone_based_ensembl_gene       │
│ 5   │ Clone-based (Ensembl) transcript │ Clone_based_ensembl_transcript │
⋮
│ 43  │ WikiGene                         │ WikiGene                       │
│ 44  │ miRBase                          │ miRBase                        │
│ 45  │ miRBase mature miRNA accession   │ miRBase_mature_accession       │
│ 46  │ miRBase mature names             │ miRBase_mature_name            │
│ 47  │ miRBase transcript name          │ miRBase_trans_name             │
│ 48  │ INSDC protein ID                 │ protein_id                     │
```

### `getValidMirnaMetadataValues`: List valid miRNA metadata parameter values

The `getValidMirnaMetadataValues` function returns a list of supported miRNA metadata parameter values. Some of the parameters apply only to mature miRNAs whereas others only return values for precursor miRNAs.

```jldoctest mirna
julia> getValidMirnaMetadataValues()
14×1 DataFrames.DataFrame
│ Row │ Parameter           │
├─────┼─────────────────────┤
│ 1   │ confidence          │
│ 2   │ type                │
│ 3   │ sequence            │
│ 4   │ comments            │
│ 5   │ previousIds         │
⋮
│ 9   │ regionEnd           │
│ 10  │ strand              │
│ 11  │ communityAnnotation │
│ 12  │ nExperiments        │
│ 13  │ reads               │
│ 14  │ evidenceType        │
```

### `getCurrentMirbaseVersion`: Get information on the latest miRBase release version supported by the package

```jldoctest mirna
julia> getCurrentMirbaseVersion()
"miRBase Release 22, March 12, 2018"
```