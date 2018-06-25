
"""
getOfficialGeneSymbol(queryId::String; sourceDb::String, chromosomal::Bool=true)
getOfficialGeneSymbol(queryId::Vector{String}; sourceDb::String, chromosomal::Bool=true)

Compute the official gene symbol for a single or multiple `queryId`(s). 

If `sourceDb` is missing, the database will automatically try to detect the queryId's 
source database. Per default `chromosomal` is set to `true`.

### Arguments
- `queryId` : can either be of type `String` or `Vector{String}`
- `sourceDb::String` : source database of the `queryId`
- `chromosomal::Bool` : if `true`, only features located on one of the 23 chromosomes ({1,2,...,X,Y})
              are considered. If `false`, features located on human alternative chromosomes will also
              be considered. Alternative sequences are sequences regions which differ from the 
              genomic DNA on the primary assembly, such as HSCHR17_2_CTG4 [info on ensembl blog](http://www.ensembl.info/2011/05/20/accessing-non-reference-sequences-in-human/).

### Examples
```julia-repl
julia> getOfficialGeneSymbol("596")
WARNING: Some input IDs have multiple mappings
2×3 DataFrames.DataFrame
│ Row │ InputId │ InputSourceDb │ OfficialGeneSymbol │
├─────┼─────────┼───────────────┼────────────────────┤
│ 1   │ 596     │ NCBI gene     │ BCL2               │
│ 2   │ 596     │ WikiGene      │ BCL2               │

julia> getOfficialGeneSymbol("596", sourceDb = "WikiGene")
1×3 DataFrames.DataFrame
│ Row │ InputId │ InputSourceDb │ OfficialGeneSymbol │
├─────┼─────────┼───────────────┼────────────────────┤
│ 1   │ 596     │ WikiGene      │ BCL2               │

julia> getOfficialGeneSymbol(["BCL2", "Bcl-2", "AMPK", "NotIn", "GJE1"])
WARNING: No values found for:
NotIn
WARNING: Some input IDs have multiple mappings
WARNING: Some input IDs result in multiple official gene symbols
5×3 DataFrames.DataFrame
│ Row │ InputId │ InputSourceDb        │ OfficialGeneSymbol │
├─────┼─────────┼──────────────────────┼────────────────────┤
│ 1   │ GJE1    │ Official Gene Symbol │ GJE1               │
│ 2   │ GJE1    │ Gene Symbol Alias    │ GJC3               │
│ 3   │ Bcl-2   │ Gene Symbol Alias    │ BCL2               │
│ 4   │ BCL2    │ Official Gene Symbol │ BCL2               │
│ 5   │ AMPK    │ Gene Symbol Alias    │ PRKAA2             │
```
"""
function getOfficialGeneSymbol(
        queryId::S;
        sourceDb::S = "", 
        chromosomal::B = true) where {B<:Bool, S<:String}

   return getOfficialGeneSymbol([queryId]; sourceDb = sourceDb, chromosomal = chromosomal);
end

function getOfficialGeneSymbol(
        queryId::T;
        sourceDb::S = "", 
        chromosomal::B = true) where {B<:Bool, S<:String, T<:Vector{String}}

   q = "CALL rcsi.convert.table.getOfficialGeneSymbol(" *
      "{ids}, " *
      (sourceDb == "" ? "null, " : ("'" * sourceDb * "', ")) *
      "{chr}) YIELD value " *
      "RETURN " *
      "   value.InputId AS InputId, " *
      "   value.InputSourceDb AS InputSourceDb, " *
      "   value.OfficialGeneSymbol AS OfficialGeneSymbol";

   x = Neo4j.cypherQuery(
      NEO4J_CONNECTION, 
      q,
      "ids" => queryId,
      "chr" => chromosomal
   );
   if DataFrames.nrow(x) > 0
      xDiff = setdiff(queryId, x[:InputId]);

      checkReturnedQueryIds(x, queryId);

      in2multiOut = @> begin
         x
         @select(:InputId, :OfficialGeneSymbol)
         unique()
         @by(:InputId, n = length(:OfficialGeneSymbol))
         @where(:n .> 1)
      end
      if !isempty(in2multiOut)
         warn("Some input IDs result in multiple official gene symbols", prefix = "WARNING: ");
      end
   end

   return x;
end

"""
convertFromToExtended(queryId::String; targetDb::Union{String, Vector{String}} attributesUnion{String, Vector{String}}, sourceDb::String, longFormat::Bool, chromosomal::Bool)
convertFromToExtended(queryId::Vector{String}; targetDb::Union{String, Vector{String}}, attributesUnion{String, Vector{String}}, sourceDb::String, longFormat::Bool, chromosomal::Bool)

Retrieve molecular identifier from other databases, `targetDb`, for single or mulitple query IDs, `queryId`,
and moreover information on Ensembl gene, transcript and peptide IDs, such as ID and genomic loation.

### Arguments
- `queryId` : either be of type `String` or `Vector{String}`
- `targetDb` : either of type `String` or `Vector{String}` (default: `[GeneSymbolDB]`) (keyword argument). 
- `attributes` : either be of type `String` or `Vector{String}`. Please see `getValidAttributes()`
              for the kind of attributes available.
- `sourceDb::String` : source database of the `queryId` (keyword argument)
- `longFormat::Bool` : `true` -> target values are stored in two columns `TargetDb` and `TargetId`.
                    If `false`, each `TargetDb` value will be in a separate column. In the case
                    when there are multiple `TargetId` values for one `TargetDb` values will be 
                    concatenated and separated by a comma (only for databases other than Ensembl) (keyword argument).
- `chromosomal::Bool` : if `true`, only features located on one of the 23 chromosomes ({1,2,...,X,Y})
              are considered. If `false`, features located on human alternative chromosomes will also
              be considered. Alternative sequences are sequences regions which differ from the 
              genomic DNA on the primary assembly, such as HSCHR17_2_CTG4 
              [info on ensembl blog](http://www.ensembl.info/2011/05/20/accessing-non-reference-sequences-in-human/). (keyword argument)

**See also**
`getValidAttributes()`
`getValidDatabases()`

### Examples
```julia-repl
julia> 

```

"""
function convertFromToExtended(
queryId::S; 
targetDb::U = ["GeneSymbolDB"], 
attributes::U = Vector{String}(), 
sourceDb::S = "",
longFormat::B = true,
chromosomal::B = true) where {S<:String, U<:Union{String, Vector{String}}, B<:Bool}

return convertFromToExtended(
  [queryId], 
  targetDb = isa(targetDb, String) ? String[targetDb] : targetDb, 
  attributes = isa(attributes, String) ? [attributes] : attributes,
  sourceDb = sourceDb, 
  longFormat = longFormat, 
  chromosomal = chromosomal);
end

function convertFromToExtended(
   queryId::T;
   targetDb::U = ["GeneSymbolDB"], 
   attributes::U = Vector{String}(),
   sourceDb::S = "",
   longFormat::B = true, 
   chromosomal::B = true) where {S<:String, T<:Vector{String}, U<:Union{String, Vector{String}}, B<:Bool}

   targetDb = isa(targetDb, String) ? String[targetDb] : targetDb;
   attributes = isa(attributes, String) ? [attributes] : attributes;

   tDb = copy(targetDb);
   append!(tDb, collect(keys(addDbColDict)));

   q = "CALL rcsi.convert.json.convertIdsExtended(" *
         "{queryId}, {tDb}, {attributes}, " *
         (sourceDb == "" ? "null, " : ("'" * sourceDb * "', ")) * 
         "{chromosomal});";

   tx = Neo4j.transaction(NEO4J_CONNECTION)
   tx(q, 
      "queryId" => queryId,
      "tDb" => tDb, 
      "attributes" => isempty(attributes) ? String[] : attributes,
      "chromosomal" => chromosomal);
   c = Neo4j.commit(tx);

   if isempty(c.results)
      warn("message: " * c.errors[1]["message"]);
      error("code: " * c.errors[1]["code"]);
   end

   res = c.results[end];

   # Parse returned JSON object
   if isempty(res["data"])
      return DataFrames.DataFrame();
   end
   x = parseGngJson(res["data"]);

   if DataFrames.nrow(x) > 0
   # Check if some symbols were not found or returned multiple values
   keysUq = unique(x[[:InputId, :InputSourceDb]]);

   gd = DataFramesMeta.groupby(keysUq, :InputId)
   for group in gd
      DataFrames.nrow(group) == 1 && continue;
      g = unique(group[:InputSourceDb]);
      if length(g) == 1 
         if g[1] == "Official Gene Symbol" && !in("ArrayExpress", targetDb)
            warn("Input ID '$(group[:InputId][1])' is an official gene symbol that codes for multiple Ensembl gene IDs. " *
                  "Possible reasons:" *
                  "\n* One of the ENSG-IDs is located on an 'Alternative Human chromosome' or " *
                  "\n* the ENSG-IDs encode different biotypes" *
                  "\n\nConsider " *
                  ((!chromosomal && !in("ArrayExpress", targetDb)) ? 
                     "setting `chromosomal = false` and adding 'ArrayExpress' to targetDb parameter" : 
                        (!chromosomal ? "setting `chromosomal = false`" : "adding 'ArrayExpress' to targetDb parameter")));
         elseif g[1] == "Gene Symbol Alias"
            warn("Input ID '$(group[:InputId][1])' represents multiple official gene symbols.")
         end
      elseif all(map(i->in(i,g),String["Gene Symbol Alias", "Official Gene Symbol"]))
         warn("Input ID '$(group[:InputId][1])' represents a gene symbol alias as well as an official gene symbol.")
      end
   end

   if !longFormat
      x = unstackDf(x);
   end

   # Remove id columns (id columns that are not in the targetDb are removed)
   ## it always assumes it is unstacked!!!
   tDbDiff = setdiff(tDb, targetDb);
   !isempty(tDbDiff) && map(i->delete!(x, addDbColDict[i]), tDbDiff);
   
   x = unique(x);

   checkReturnedQueryIds(x, queryId);
   else
      return DataFrames.DataFrame();
   end

   return x;

end


"""
convertFromTo(queryId::String; targetDb::Union{String, Vector{String}}, sourceDb::String, longFormat::Bool=true, chromosomal::Bool=true)
convertFromTo(queryId::Vector{String}; targetDb::Union{String, Vector{String}}, sourceDb::String, longFormat::Bool=true, chromosomal::Bool=true)

Given a single or multiple input IDs, `queryId`, convert to a single or multiple target databases, `targetDb`.
If `sourceDb` is missing, the database will automatically try to detect the queryId's 
source database. Per default `chromosomal` is set to `true`.

### Arguments
- `queryId` : either be of type `String` or `Vector{String}`
- `targetDb` : either of type `String` or `Vector{String}` (default: `[GeneSymbolDB]`) (keyword argument).
- `sourceDb::String` : source database of the `queryId` (keyword argument)
- `longFormat::Bool` : `true` -> target values are stored in two columns `TargetDb` and `TargetId`.
                    If `false`, each `TargetDb` value will be in a separate column. In the case
                    when there are multiple `TargetId` values for one `TargetDb` values will be 
                    concatenated and separated by a comma (only for databases other than Ensembl) (keyword argument).
- `chromosomal::Bool` : if `true`, only features located on one of the 23 chromosomes ({1,2,...,X,Y})
              are considered. If `false`, features located on human alternative chromosomes will also
              be considered. Alternative sequences are sequences regions which differ from the 
              genomic DNA on the primary assembly, such as HSCHR17_2_CTG4 
              [info on ensembl blog](http://www.ensembl.info/2011/05/20/accessing-non-reference-sequences-in-human/). (keyword argument)

**See also**
`getValidDatabases()`

### Examples
```julia-repl
julia> convertFromTo(["IGHV1-2", "Bcl-2"])
2×4 DataFrames.DataFrame
│ Row │ InputId │ InputSourceDb        │ TargetDb             │ TargetId │
├─────┼─────────┼──────────────────────┼──────────────────────┼──────────┤
│ 1   │ IGHV1-2 │ Official Gene Symbol │ Official Gene Symbol │ IGHV1-2  │
│ 2   │ Bcl-2   │ Gene Symbol Alias    │ Official Gene Symbol │ BCL2     │

julia> convertFromTo(["IGHV1-2", "Bcl-2"], chromosomal = false)
WARNING:root:Input ID 'IGHV1-2' is an official gene symbol that codes for multiple Ensembl gene IDs. Possible reasons:
* One of the ENSG-IDs is located on an 'Alternative Human chromosome' or
* the ENSG-IDs encode different biotypes

Consider setting `chromosomal = false` and adding 'ArrayExpress' to targetDb parameter
2×4 DataFrames.DataFrame
│ Row │ InputId │ InputSourceDb        │ TargetDb             │ TargetId │
├─────┼─────────┼──────────────────────┼──────────────────────┼──────────┤
│ 1   │ IGHV1-2 │ Official Gene Symbol │ Official Gene Symbol │ IGHV1-2  │
│ 2   │ Bcl-2   │ Gene Symbol Alias    │ Official Gene Symbol │ BCL2     │

# Once we run this again we can see that IGHV1-2 also encodes for a ENSG-ID on an alternative sequence
julia> convertFromTo(["IGHV1-2", "Bcl-2"], ["EntrezGene", "GeneSymbolDB", "ArrayExpress"], chromosomal = false)
6×4 DataFrames.DataFrame
│ Row │ InputId │ InputSourceDb        │ TargetDb             │ TargetId        │
├─────┼─────────┼──────────────────────┼──────────────────────┼─────────────────┤
│ 1   │ IGHV1-2 │ Official Gene Symbol │ Ensembl Human Gene   │ ENSG00000211934 │
│ 2   │ IGHV1-2 │ Official Gene Symbol │ Official Gene Symbol │ IGHV1-2         │
│ 3   │ IGHV1-2 │ Official Gene Symbol │ Ensembl Human Gene   │ ENSG00000282550 │
│ 4   │ Bcl-2   │ Gene Symbol Alias    │ Ensembl Human Gene   │ ENSG00000171791 │
│ 5   │ Bcl-2   │ Gene Symbol Alias    │ Official Gene Symbol │ BCL2            │
│ 6   │ Bcl-2   │ Gene Symbol Alias    │ NCBI gene            │ 596             │

# Using the above query and setting `longFormat = false`:
julia> convertFromTo(["IGHV1-2", "Bcl-2"], ["EntrezGene", "GeneSymbolDB", "ArrayExpress"], chromosomal = false, longFormat=false)
3×5 DataFrames.DataFrame
│ Row │ InputId │ InputSourceDb        │ Ensembl_Human_Gene │ Official_Gene_Symbol │ NCBI_gene │
├─────┼─────────┼──────────────────────┼────────────────────┼──────────────────────┼───────────┤
│ 1   │ Bcl-2   │ Gene Symbol Alias    │ ENSG00000171791    │ BCL2                 │ 596       │
│ 2   │ IGHV1-2 │ Official Gene Symbol │ ENSG00000211934    │ IGHV1-2              │ missing   │
│ 3   │ IGHV1-2 │ Official Gene Symbol │ ENSG00000282550    │ IGHV1-2              │ missing   │

```

"""
function convertFromTo(
        queryId::S;
        targetDb::U = ["GeneSymbolDB"],
        sourceDb::S = "",
        longFormat::B = true, 
        chromosomal::B = true) where {S<:String, U<:Union{String, Vector{String}}, B<:Bool}

return convertFromTo(
           [queryId], 
           targetDb = isa(targetDb, String) ? [targetDb] : targetDb, 
           sourceDb = sourceDb, 
           longFormat = longFormat, 
           chromosomal = chromosomal);

end

function convertFromTo(
        queryId::T;
        targetDb::U = ["GeneSymbolDB"], 
        sourceDb::S = "",
        longFormat::B = true, 
        chromosomal::B = true) where {S<:String, T<:Vector{String}, U<:Union{String, Vector{String}}, B<:Bool}

   targetDb = isa(targetDb, String) ? String[targetDb] : targetDb;

   tDb = copy(targetDb);
   append!(tDb, collect(keys(addDbColDict)));

   q = "CALL rcsi.convert.table.convertIds({ids}, {dbs}, " *
   (sourceDb == "" ? "null, " : ("'" * sourceDb * "', ")) * 
   "{chromosomal}) " *
   "YIELD value " *
   "RETURN value.InputId AS InputId, " *
   "value.InputSourceDb AS InputSourceDb, " *
   "value.EnsemblGeneId AS EnsemblGeneId, " *
   "value.TargetDb AS TargetDb, " *
   "value.TargetId AS TargetId;"

   x = Neo4j.cypherQuery(
      NEO4J_CONNECTION, 
      q,
      "ids" => queryId,
      "dbs" => targetDb,
      "chromosomal" => chromosomal);

   if DataFrames.nrow(x) > 0
      # Check if some symbols were not found or returned multiple values
      keysUq = unique(x[[:InputId, :InputSourceDb, :EnsemblGeneId]]);

      gd = DataFramesMeta.groupby(keysUq, :InputId)
      for group in gd
         DataFrames.nrow(group) == 1 && continue;
         g = unique(group[:InputSourceDb]);
         if length(g) == 1 
            if g[1] == "Official Gene Symbol" && !in("ArrayExpress", targetDb)
               warn("Input ID '$(group[:InputId][1])' is an official gene symbol that codes for multiple Ensembl gene IDs. " *
                     "Possible reasons:" *
                     "\n* One of the ENSG-IDs is located on an 'Alternative Human chromosome' or " *
                     "\n* the ENSG-IDs encode different biotypes" *
                     "\n\nConsider " *
                     ((!chromosomal && !in("ArrayExpress", targetDb)) ? 
                        "setting `chromosomal = false` and adding 'ArrayExpress' to targetDb parameter" : 
                           (!chromosomal ? "setting `chromosomal = false`" : "adding 'ArrayExpress' to targetDb parameter")));
            elseif g[1] == "Gene Symbol Alias"
               warn("Input ID '$(group[:InputId][1])' represents multiple official gene symbols.")
            end
         elseif all(map(i->in(i,g),String["Gene Symbol Alias", "Official Gene Symbol"]))
            warn("Input ID '$(group[:InputId][1])' represents a gene symbol alias as well as an official gene symbol.")
         end
      end

      if !longFormat
         x = unstackDf(x);
      end

      delete!(x, :EnsemblGeneId);
   
      x = unique(x);

      checkReturnedQueryIds(x, queryId);
   end

   return x;

end