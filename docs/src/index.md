# GeneNameGenieJ.jl Documentation

This guide aims to show you how to use functions from the GeneNameGenieJ package
to handle various molecular identifiers from biological datasets. Please report
bugs by [opening an issue](https://github.com/StefanHaunsberger/GeneNameGenieJ.jl/issues)
on the repository's website.

## What is GeneNameGnieJ used for

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

## Package Manual

```@contents
Pages = ["man/getting_started.md",
         "man/mirna-functions.md",
         "man/molecular-id-handling.md",
         "man/attribute-functions.md"]
Depth = 2
```

## API

```@contents
Pages = ["lib/functions.md"]
Depth = 2
```

## Index

```@index
Pages = ["lib/functions.md"]
```