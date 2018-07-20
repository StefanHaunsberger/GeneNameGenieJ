# Available DBs and metadata parameter values

## Metadata values for miRNAs

The `getValidMirnaMetadataValues` function returns a list of supported miRNA metadata parameter values. 
Some of the parameters apply only to mature miRNAs whereas others only return values for precursor miRNAs.

```julia
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

## DBs and Metadata values for molecular ID functions

The `getValidDatabases` function returns a list of supported database values. The values 
contained in the `DatabaseId` column are valid as `targetDb` and `sourceDb` parameter values.

```jldoctest attributes
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

Supported attributes for the `convertFromToExtended` function can be retrieved with the
`getValidAttributes` function.

```jldoctest attributes
julia> getValidAttributes()
17×1 DataFrames.DataFrame
│ Row │ Parameters       │
├─────┼──────────────────┤
│ 1   │ ensg:region      │
│ 2   │ ensg:regionStart │
│ 3   │ ensg:regionEnd   │
│ 4   │ ensg:strand      │
│ 5   │ ensg:name        │
⋮
│ 12  │ enst:strand      │
│ 13  │ enst:biotype     │
│ 14  │ enst:version     │
│ 15  │ ensp:version     │
│ 16  │ symbol           │
│ 17  │ aliases          │
```

## DB version information

### `getCurrentMirbaseVersion`: Get information on the latest miRBase release version supported by the package

```jldoctest attributes
julia> getCurrentMirbaseVersion()
"miRBase Release 22, March 12, 2018"
```

### `getEnsemblVersion`: Get information on the underlaying Ensembl DB release version

```jldoctest attributes
julia> getEnsemblVersion()
"Ensembl Release 91, December 12, 2017"
```