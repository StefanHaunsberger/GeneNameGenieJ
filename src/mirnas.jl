
METADATA_MAP = Dict{String, String}("confidence" => "value.Conficence AS Confidence",
                 "type" => "value.Type AS Type",
                 "sequence" => "value.Sequence AS Sequence",
                 "comments" => "value.Comments AS Comments",
                 "previousIds" => "value.PreviousIds AS PreviousIds",
                 "url" => "value.URL AS Url",
                 "chromosome" => "value.Chromosome AS Chromosome",
                 "regionStart" => "value.RegionStart AS RegionStart",
                 "regionEnd" => "value.RegionEnd AS RegionEnd",
                 "strand" => "value.Strand AS Strand",
                 "communityAnnotation" => "value.CommunityAnnotation AS CommunityAnnotation",
                 "nExperiments" => "value.nExperiments AS nExperiments",
                 "reads" => "value.Reads AS Reads",
                 "evidenceType" => "value.EvidenceType AS EvidenceType");

"""
    convertToCurrentMirbaseVersion(queryId::String; species::String, metadata::Union{String, Vector{String}})
    convertToCurrentMirbaseVersion(queryId::Vector{String}; species::String, metadata::Union{String, Vector{String}})

Translate input IDs to the name in the current miRBase release version.

As input all kinds of miRNA identifiers are accepted, such as mature miRNA names, MI-accession, MIMAT-accession 
and precursor-miRNA name. Moreover, metadata from the latest miRBase release version 
can be returned with the name, such as the sequence, genomic location and annotations (
see `getValidMirnaMetadataValues` for further information on metadata values).

### Arguments
- `queryId` : either of type `String` or `Vector{String}` containing any miRNA identifier
- `species::String` : Three letter species value, such as `"hsa"` or `"mmu"`
- `metadata` : `String` or `Vector{String}` with metadata keywords (see `getValidMirnaMetadataValues()`)

**See also**
`getValidMirnaMetadataValues()`

### Examples
```julia-repl
> convertToCurrentMirbaseVersion("hsa-mir-29a")
1×4 DataFrames.DataFrame
│ Row │ InputId     │ Accession │ CurrentMirna │ CurrentVersion │
├─────┼─────────────┼───────────┼──────────────┼────────────────┤
│ 1   │ hsa-mir-29a │ MI0000087 │ hsa-mir-29a  │ 22.0           │

> convertToCurrentMirbaseVersion(["hsa-mir-29a", "hsa-mir-134a", "hsa-miR-29a"], metadata = ["sequence", "chromosome"])
10-Apr 16:23:41:WARNING:root:Some input identifiers were not found in the database.
Union{Missings.Missing, String}["hsa-mir-134a"]2×6 DataFrames.DataFrame
│ Row │ InputId     │ Accession    │ CurrentMirna   │ CurrentVersion │ Sequence                                                         │ Chromosome │
├─────┼─────────────┼──────────────┼────────────────┼────────────────┼──────────────────────────────────────────────────────────────────┼────────────┤
│ 1   │ hsa-miR-29a │ MIMAT0000086 │ hsa-miR-29a-3p │ 22.0           │ UAGCACCAUCUGAAAUCGGUUA                                           │ missing    │
│ 2   │ hsa-mir-29a │ MI0000087    │ hsa-mir-29a    │ 22.0           │ AUGACUGAUUUCUUUUGGUGUUCAGAGUCAAUAUAAUUUUCUAGCACCAUCUGAAAUCGGUUAU │ 7          │
```
"""
function convertToCurrentMirbaseVersion(
   queryId::S;
   species::S = "", 
   metadata::U = [""]) where {S<:String, U<:Union{String, Vector{String}}}

   return convertToCurrentMirbaseVersion(
         [queryId], 
         species = species,
         metadata = isa(metadata, String) ? [metadata] : metadata);

end

function convertToCurrentMirbaseVersion(
   queryId::T;
   species::S = "", 
   metadata::U = [""]) where {S<:String, T<:Vector{String}, U<:Union{String, Vector{String}}}

   metadata = isa(metadata, String) ? String[metadata] : metadata;

   q = "CALL rcsi.mirna.convertToCurrentMirbaseVersion(" *
      "{queryId}, {species}" *
      (metadata[1] == "" ? "" : (", {metadata}")) * 
      ") " *
      "YIELD value " *
      "RETURN DISTINCT value.InputId AS InputId, " *
      "value.Accession AS Accession, " *
      "value.CurrentMirna AS CurrentMirna, " *
      "value.CurrentVersion AS CurrentVersion";

   if (all(metadata .!= ""))
      q *= ", " * 
         join(
            map(i->haskey(METADATA_MAP, i) ? 
               METADATA_MAP[i] : 
               error("provided metadata value '$i' not supported"), metadata), ", ");
   end

   x = Neo4j.cypherQuery(
         NEO4J_CONNECTION, 
         q,
         "queryId" => queryId,
         "species" => species,
         "metadata" => metadata);

   # Check for multi matches and not found input Ids
   multiMatches = @> begin
      x[[:InputId, :Accession]]
      unique()
      @by(:InputId, nRows = length(:Accession))
      @where(:nRows .> 1)
   end

   if (DataFrames.nrow(multiMatches) != 0)
      warn("Some input identifiers match to more than one MIMAT accession!");
      show(multiMatches);
   end
   postCheckMirnas(x, :Accession, queryId);

   return x;
   
end

"""
    convertMatureMirnasToVersions(queryId::String; targetVersion::Union{Union{Float64, Int64}, Union{Vector{Float64}, Vector{Int64}}}, species::String, sequence::Boolean)
    convertMatureMirnasToVersions(queryId::Vector{String}; targetVersion::Union{Union{Float64, Int64}, Union{Vector{Float64}, Vector{Int64}}}, species::String, sequence::Boolean)

Translate mature miRNA names to different versions

Taking single or multiple `queryId`s return the name(s) for a single or
#' multiple `targetVersion`(s). Optionally the `species` can be provided and if
#' `sequence` == TRUE the sequence for each version respecively returned.

### Arguments
- `queryId` : either of type `String` or `Vector{String}` containing any miRNA identifier
- `targetVersion` : The target miRBase version(s), such as `[20, 21]` (default: highest supported version).
- `species::String` : Three letter species value, such as `"hsa"` or `"mmu"` (default: "")
- `sequence::Bool` : A boolean depicting if sequence for respective miRBase versions is returned or not (default: `false`).

**See also**
`convertToCurrentMirbaseVersion()` if only current version is needed.

### Examples
```julia-repl
> convertMatureMirnasToVersions("hsa-mir-29a")
1×4 DataFrames.DataFrame
│ Row │ InputId     │ Accession │ CurrentMirna │ CurrentVersion │
├─────┼─────────────┼───────────┼──────────────┼────────────────┤
│ 1   │ hsa-mir-29a │ MI0000087 │ hsa-mir-29a  │ 22.0           │

> convertMatureMirnasToVersions(["hsa-mir-29a", "hsa-mir-134a", "hsa-miR-29a"], metadata = ["sequence", "chromosome"])
10-Apr 16:23:41:WARNING:root:Some input identifiers were not found in the database.
Union{Missings.Missing, String}["hsa-mir-134a"]2×6 DataFrames.DataFrame
│ Row │ InputId     │ Accession    │ CurrentMirna   │ CurrentVersion │ Sequence                                                         │ Chromosome │
├─────┼─────────────┼──────────────┼────────────────┼────────────────┼──────────────────────────────────────────────────────────────────┼────────────┤
│ 1   │ hsa-miR-29a │ MIMAT0000086 │ hsa-miR-29a-3p │ 22.0           │ UAGCACCAUCUGAAAUCGGUUA                                           │ missing    │
│ 2   │ hsa-mir-29a │ MI0000087    │ hsa-mir-29a    │ 22.0           │ AUGACUGAUUUCUUUUGGUGUUCAGAGUCAAUAUAAUUUUCUAGCACCAUCUGAAAUCGGUUAU │ 7          │
```
"""
function convertMatureMirnasToVersions(
   queryId::S;
   targetVersion::F = [0.0],
   species::S = "", 
   sequence::B = false) where {S<:String, F<:Union{Union{Float64, Int64}, Union{Vector{Float64}, Vector{Int64}}}, B<:Bool}

   # targetVersionF = normaliseTargetVersionParameter(targetVersion);

   return convertMatureMirnasToVersions(
         [queryId],
         targetVersion = targetVersion,
         species = species,
         sequence = sequence);

end

function convertMatureMirnasToVersions(
   queryId::T;
   targetVersion::F = [0.0],
   species::S = "", 
   sequence::B = false) where {S<:String, T<:Vector{String}, F<:Union{Union{Float64, Int64}, Union{Vector{Float64}, Vector{Int64}}}, B<:Bool}


   targetVersionF = normaliseTargetVersionParameter(targetVersion);

   q = "CALL rcsi.mirna.convertMatureMirnas(" *
         "{queryId}, {targetVersion}, {species}, {sequence}" *
         ") " *
         "YIELD value " *
         "RETURN DISTINCT value.InputId AS InputId, " *
            "value.MatureAccession AS MatureAccession, " *
            "value.miRBaseVersion AS miRBaseVersion, " *
            "value.TargetMirna AS TargetMirna";

   if (sequence)
      q *= ", value.TargetSequence AS TargetSequence";
   end

   x = Neo4j.cypherQuery(
         NEO4J_CONNECTION, 
         q,
         "queryId" => queryId,
         "targetVersion" => targetVersionF,
         "species" => species,
         "sequence" => sequence);

   # Check for multi matches and not found input Ids
   if DataFrames.nrow(x) > 0
      multiMatches = @> begin
         x[[:InputId, :MatureAccession]]
         unique()
         @by(:InputId, nRows = length(:MatureAccession))
         @where(:nRows .> 1)
      end
   else
      return x;
   end

   if (DataFrames.nrow(multiMatches) != 0)
      warn("Some input identifiers match to more than one MIMAT accession!");
      show(multiMatches);
   end
   postCheckMirnas(x, :MatureAccession, queryId);

   return x;
   
end

function normaliseTargetVersionParameter(targetVersion::Union{Union{Float64, Int64}, Union{Vector{Float64}, Vector{Int64}}})
   targetVersionF = [0.0];
   if isa(targetVersion, Int64) || isa(targetVersion, Float64)
      targetVersionF = Float64[targetVersion];
   elseif isa(targetVersion, Vector{Int64})
      targetVersionF = collect(Float64,targetVersion);
   elseif isa(targetVersion, Vector{Float64})
      targetVersionF = targetVersion;
   end
   return targetVersionF;
end
