# GeneNameGenieJ

[![Build Status](https://travis-ci.org/StefanHaunsberger/GeneNameGenieJ.jl.svg?branch=master)](https://travis-ci.org/StefanHaunsberger/GeneNameGenieJ.jl)

[![Coverage Status](https://coveralls.io/repos/StefanHaunsberger/GeneNameGenieJ.jl/badge.svg?branch=master&service=github)](https://coveralls.io/github/StefanHaunsberger/GeneNameGenieJ.jl?branch=master)

[![codecov.io](http://codecov.io/github/StefanHaunsberger/GeneNameGenieJ.jl/coverage.svg?branch=master)](http://codecov.io/github/StefanHaunsberger/GeneNameGenieJ.jl?branch=master)


The _GeneNameGenieJ_ Julia package has been developed to provide functions for molecular identifier conversion, such as gene symbols, aliases, transcripts and miRNAs. The base thereby is a Neo4j graph database containing identifiers from Ensembl v91 and 22 miRBase release versions ([miRBase](http://www.mirbase.org)).

* [Introduction](#introduction)
* [Use Cases](#use-cases)
   - [How to translate molecular identifiers](#how-to-translate-molecular-identifiers)
       - [Get official gene symbol](#get-official-gene-symbol)
       - [Convert identifiers from and to different databases](#convert-identifiers-from-and-to-different-databases)
   - [How to translate miRNAs](#how-to-translate-mirnas)
       - [Translate input Ids to current version and retrieve metadata](#translate-input-ids-to-current-version-and-retrieve-metadata)
       - [Translate mature miRNA names to different miRBase release versions](#translate-mature-mirna-names-to-different-mirbase-release-versions)
   - [List valid databases and supported parameter values](#list-valid-databases-and-supported-parameter-values)
   - [Additional information](#additional-information)

*Availability:* 

The package can be installed using the following command:

```julia
Pkg.install("GeneNameGenieJ")
```

# Introduction

The _GeneNameGenieJ_ package provides a programmatic interface to the GeneNameGenie
Neo4j graph database (GDB). The GeneNameGenie Neo4j GDB can either be used as standalone
or also as part of miRGIK, in which GeneNameGenie is fully integrated.
GeneNameGenieJ provides functions for translating any general molecular identifier which 
is supported by Ensembl. Functions include translation to the official gene symbol, 
retrieving metadata for Ensembl genes and transcripts and translating between different
database formats. Thereby, providing the source database of the input identifier is **optional**.

Moreover GeneNameGeneiJ supports 22 different miRBase release versions, with the most recent one 
from March 2018, miRBase version 22. miRNAs can be translated to the most recent as well as
any other supported miRBase version version and metadata, such as sequence, previous 
identifiers or type, can also be included.

The main methods are: 

- `getOfficialGeneSymbol`: Convert input id to its corresponding official gene symbol,
- `convertFromTo`: Convert molecular identifier to target identifiers,
- `getValidDatabases`: List all supported databases
- `convertToCurrentMirbaseVersion`: Get current miRNA name for mature input miRNAs
- `convertMatureMirnasToVersions`: Translate mature miRNA names to different versions.
- `getValidMirnaMetadataValues`: List all valid miRNA metadata parameters.

 
To load the package and gain access to the functions just run the 
following command:

```julia
using GeneNameGenieJ
```

## Database information

GeneNameGenieJ depends on a GeneNameGenie Neo4j graph database instance. This can either
be locally or online. The default URL is set to `http://localhost:7474/db/data/`.
To use a different URL pass the URL as a string parameter to the GeneNameGenieR object
instantiation:

```julia
setNeo4jConnection(Neo4j.Connection("http://<url>:<port>/db/data"))
```

# Use Cases

## How to translate molecular identifiers

### Get official gene symbol

To retrieve the official gene symbol for any given molecular identifier, the 
`getOfficialGeneSymbol` function can be used.
Let us assume we want to find the official gene symbol for the following molecular 
identifiers: 'AMPK', 'Bcl-2', '596' and 'NM_000657'. We can use the `getOfficialGeneSymbol` 
function to retrieve the official gene symbol for each input identifier respectively.
```julia
julia> ids = String["P10415", "AMPK", "ENSP00000381185", "ENST00000589955", "A0A024R2B3", "596"];
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

Because we have not provided the source database parameter we get a warning that some input 
identifiers were actually mapped to multiple databases, such as P10415, which is a UniProtKB 
gene name as well as a UniProtKB/Swiss-Prot protein name.
We can run the same command again with the `Uniprot_gn`, for the UniProtKB Gene Name database, 
as input source database parameter. 

```julia
julia> ids = String["P10415", "AMPK", "ENSP00000381185", "ENST00000589955", "A0A024R2B3", "596"];
julia> getOfficialGeneSymbol(ids, sourceDb = "Uniprot_gn");
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

### Convert identifiers from and to different databases

With the `convertFromTo` function we can convert any given identifier to any supported 
target database. In the following example we are want to get all identifiers from 
`"Uniprot/SWISSPROT"`, `"Uniprot/SPTREMBL"`, `"EntrezGene"` for the `"BCL2"` and `"AMPK"`.

```julia
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

## How to translate miRNAs

### Translate input Ids to current version and retrieve metadata

Most of the time all one needs is to retrieve the miRNA name of the current 
miRBase release version. The `convertToCurrentMirbaseVersion` function 
takes a single or multiple input values and returns the current miRNA name for 
each input value respectively (where possible). The following example illustrates 
a simple use case where a single miRNA is converted to the current miRBase version.

```julia
julia> convertToCurrentMirbaseVersion("hsa-miR-29a")
1×4 DataFrames.DataFrame
│ Row │ InputId     │ Accession    │ CurrentMirna   │ CurrentVersion │
├─────┼─────────────┼──────────────┼────────────────┼────────────────┤
│ 1   │ hsa-miR-29a │ MIMAT0000086 │ hsa-miR-29a-3p │ 22.0           │
```

Moreover, metadata for mature as well as precursor miRNAs, such as comments and reads, 
can be retrieved by passing the parameter value `metadata` to the function. 
The function accepts mature miRNA identifiers (miRNA name and MIMAT-accession) as well as 
precursor identifiers (pre-miRNA name and MI-accession). Hence, some metadata values 
only apply to precursor miRNAs, such as genomic location and strand.

The following example returns the current miRNA name and metadata for a the mature 
miRNA name `hsa-miR-29a` and the precursor miRNA name `hsa-mir-29a`.

```julia
julia> convertToCurrentMirbaseVersion(String["hsa-miR-29a", "hsa-mir-29a"], metadata = String["nExperiments", "strand", "reads"])
2×7 DataFrames.DataFrame
│ Row │ InputId     │ Accession    │ CurrentMirna   │ CurrentVersion │ nExperiments │ Strand  │ Reads   │
├─────┼─────────────┼──────────────┼────────────────┼────────────────┼──────────────┼─────────┼─────────┤
│ 1   │ hsa-miR-29a │ MIMAT0000086 │ hsa-miR-29a-3p │ 22.0           │ 77           │ missing │ 2045292 │
│ 2   │ hsa-mir-29a │ MI0000087    │ hsa-mir-29a    │ 22.0           │ 77           │ -       │ 2055333 │
```
As we can see, the strand information is only available for the precursor miRNA. 
It is to mention that not all metadata information is available for each miRNA. So, for 
example, the mature miRNA-X could return a value for the `communityAnnotation` metadata value 
whereas miRNA-Y does not just because one has a value in the database and the other one does not.

*Some more examples:*

```julia
julia> convertToCurrentMirbaseVersion("hsa-mir-29a", metadata = String["sequence", "type", "previousIds"])
1×7 DataFrames.DataFrame
│ Row │ InputId     │ Accession │ CurrentMirna │ CurrentVersion │ Sequence     │ Type      │ PreviousIds │
├─────┼─────────────┼───────────┼──────────────┼────────────────┼──────────────┼───────────┼─────────────┤
│ 1   │ hsa-mir-29a │ MI0000087 │ hsa-mir-29a  │ 22.0           │ AUGA...GUUAU │ antisense │ hsa-mir-29  │
```

```julia
julia> convertToCurrentMirbaseVersion(String["hsa-miR-29a", "MI0000087"], metadata = String["nExperiments", "evidenceType", "reads"])
2×7 DataFrames.DataFrame
│ Row │ InputId     │ Accession    │ CurrentMirna   │ CurrentVersion │ nExperiments │ EvidenceType │ Reads   │
├─────┼─────────────┼──────────────┼────────────────┼────────────────┼──────────────┼──────────────┼─────────┤
│ 1   │ MI0000087   │ MI0000087    │ hsa-mir-29a    │ 22.0           │ 77           │ missing      │ 2055333 │
│ 2   │ hsa-miR-29a │ MIMAT0000086 │ hsa-miR-29a-3p │ 22.0           │ 77           │ experimental │ 2045292 │
```

### Translate mature miRNA names to different miRBase release versions

In cases where we want to use tools which require the miRNA from a certain miRBase release 
version one can use the `convertMatureMirnasToVersions` function.

If no target versions are provided, the name from the most recent supported miRBase 
release version is returned.

```julia
julia> convertMatureMirnasToVersions("hsa-miR-29a")
1×4 DataFrames.DataFrame
│ Row │ InputId     │ MatureAccession │ miRBaseVersion │ TargetMirna    │
├─────┼─────────────┼─────────────────┼────────────────┼────────────────┤
│ 1   │ hsa-miR-29a │ MIMAT0000086    │ 22.0           │ hsa-miR-29a-3p │
```

The following code returns the names for miRBase version 17, 21 and 22 for the 
mature miRNA `hsa-miR-29a`.

```julia
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

```julia
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

The `getValidDatabases` function returns a list of supported database values. The values 
contained in the `DatabaseId` column are valid as `targetDb` and `sourceDb` parameter values.

```julia
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

### `getCurrentMirbaseVersion`: Get information on the latest miRBase release version supported by the package

```julia
julia> getCurrentMirbaseVersion()
"miRBase Release 22, March 12, 2018"
```

### `getEnsemblVersion`: Get information on the underlaying Ensembl DB release version

```julia
julia> getEnsemblVersion()
"Ensembl Release 91, December 12, 2017"
```

## Additional information
