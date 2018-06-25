
geneCols = Dict{String,Symbol}(
   "aliases" => :GeneSymbolAlias,
   "symbol" => :OfficialGeneSymbol,
   "region" => :GeneRegion,
   "regionStart" => :GeneStart,
   "regionEnd" => :GeneEnd,
   "id" => :EnsemblGeneId,
   "version" => :EnsemblGeneVersion,
   "biotype" => :EnsemblGeneBiotype,
   "name" => :GeneName
);
transcriptCols = Dict{String,Symbol}(
   "region" => :TranscriptRegion,
   "regionStart" => :TranscriptStart,
   "regionEnd" => :TranscriptEnd,
   "id" => :EnsemblTranscriptId,
   "version" => :EnsemblTranscriptVersion,
   "biotype" => :EnsemblTranscriptBiotype
);
proteinCols = Dict{String,Symbol}(
   "id" => :EnsemblProteinId,
   "version" => :EnsemblProteinVersion
);
elTypeDict = Dict{String, Union}(
   # "aliases" => Vector{String},
   "aliases" => Union{String, Missing},
   "symbol" => Union{String, Missing},
   "region" => Union{String, Missing},
   "regionStart" => Union{Int, Missing},
   "regionEnd" => Union{Int, Missing},
   "id" => Union{String, Missing},
   "version" => Union{Int, Missing},
   "biotype" => Union{String, Missing},
   "name" => Union{String, Missing}
);


function parseGngJson(json::Array{Any,1})
  
   #########################
   # Count number or rows and create columns
   #  In the case of the columns only look at the first entry
   #  First four columns are inputDB, inputID, targetID and targetDB
   nCols = 4;
   colNames = Symbol["InputId", "InputSourceDb", "TargetId", "TargetDb"];
   colNamesUnstack = Symbol["InputId", "InputSourceDb"];
   colElTypes = Union[Union{String, Missing}, Union{String, Missing}, Union{String, Missing}, Union{String, Missing}];
   # Gene column names and types
   map(i->haskey(geneCols,i) && (push!(colNames, geneCols[i]),
                                 push!(colNamesUnstack, geneCols[i]),
                                 push!(colElTypes, elTypeDict[i])), keys(json[1]["row"][1]["gene"]))
   # Transcript:
   # Dict{String,Any} with 4 entries:
   # "peptide"   => Dict{String,Any}(Pair{String,Any}("id", "ENSP00000381185"),Pair{String,Any}("targetIds", Any[Dict{String,Any}(Pair{String,Any}("dbName", "UniProtKB/TrEMBL"),Pair{String,Any}("id", "A0A024R2B3"))]),Pair{String,A…
   # "id"        => "ENST00000398117"
   # "targetIds" => Any[]
   # "region"    => "18"
   map(i->haskey(transcriptCols,i) && (push!(colNames, transcriptCols[i]),
                                       push!(colNamesUnstack, transcriptCols[i]),
                                       push!(colElTypes, elTypeDict[i])), keys(json[1]["row"][1]["gene"]["transcript"][1]))
   # number of cols minus 1 because of targetIds, e.g.:
   # Dict{String,Any} with 3 entries:
   # "id"        => "ENSP00000381185"
   # "targetIds" => Any[Dict{String,Any}(Pair{String,Any}("dbName", "UniProtKB/TrEMBL"),Pair{String,Any}("id", "A0A024R2B3"))]
   # "version"   => 1
   map(i->haskey(proteinCols,i) && (push!(colNames, proteinCols[i]), 
                                    push!(colNamesUnstack, proteinCols[i]),
                                    push!(colElTypes, elTypeDict[i])), keys(json[1]["row"][1]["gene"]["transcript"][1]["peptide"]))
   ##################
   # Rows
   nRows = 0;
   for entry in json
      # For each gene entry
      # nRows += 1;
      # Number of external gene identifiers
      gene = entry["row"][1]["gene"];
      nRows += (length(gene["targetIds"]) * length(gene["transcript"]));
      for transcript in gene["transcript"]
         # Transcript:
         # Dict{String,Any} with 4 entries:
         # "peptide"   => Dict{String,Any}(Pair{String,Any}("id", "ENSP00000381185"),Pair{String,Any}("targetIds", Any[Dict{String,Any}(Pair{String,Any}("dbName", "UniProtKB/TrEMBL"),Pair{String,Any}("id", "A0A024R2B3"))]),Pair{String,A…
         # "id"        => "ENST00000398117"
         # "targetIds" => Any[]
         # "region"    => "18"
         nRows += length(transcript["targetIds"]);
         # Peptide:
         # Dict{String,Any} with 3 entries:
         # "id"        => "ENSP00000381185"
         # "targetIds" => Any[Dict{String,Any}(Pair{String,Any}("dbName", "UniProtKB/TrEMBL"),Pair{String,Any}("id", "A0A024R2B3"))]
         # "version"   => 1
         nRows += length(transcript["peptide"]["targetIds"]);
      end
      # println(entry["row"][1])
   end
   nRows


   x = DataFrames.DataFrame(
      colElTypes,
      colNames,
      nRows
      # 100
   );

   lowG = 1;
   highG = 1;
   lowT = 1;
   highT = 1;
   for entry in json
      # For each gene entry
      lowT = lowG;
      highT = lowT;
      highG = lowG;
      # Number of external gene identifiers
      gene = entry["row"][1]["gene"];
      externalIds = String[];
      externalDbs = String[];
      # In the case of external IDs add entries to arrays
      !isempty(gene["targetIds"]) && map(i->(push!(externalIds, i["id"]), push!(externalDbs, i["dbName"])), gene["targetIds"]);
      externalGeneIds = copy(externalIds);
      externalGeneDbs = copy(externalDbs);
      # nRows += length(gene["targetIds"])
      for transcript in gene["transcript"]
         # In the case of external IDs add entries to arrays
         !isempty(transcript["targetIds"]) && map(i->(push!(externalIds, i["id"]), push!(externalDbs, i["dbName"])), transcript["targetIds"]);
         peptide = transcript["peptide"];
         !isempty(peptide["targetIds"]) && map(i->(push!(externalIds, i["id"]), push!(externalDbs, i["dbName"])), peptide["targetIds"]);
         highT += (length(externalIds) - 1);
         # for 
         # map(i->haskey(geneCols,i) && (push!(colNames, geneCols[i]), push!(colElTypes, elTypeDict[i])), keys(json[1]["row"][1]["gene"]))
         # for epEntry in transcript["peptide"]["targetIds"]
            
         
         map(key->haskey(transcriptCols,key) && (x[transcriptCols[key]][lowT:highT] = transcript[key]), keys(transcript))
         map(key->haskey(proteinCols,key) && (x[proteinCols[key]][lowT:highT] = peptide[key]), keys(peptide))
         
         # map(key->haskey(geneCols,key) && (println("col: $(geneCols[key]) = $(gene[key])")), keys(gene))
         # map(key->haskey(geneCols,key) && (println("$(collect(lowT:highT)) -> $(fill(gene[key], high))")), keys(gene))

         x[:TargetId][lowT:highT] = externalIds;
         x[:TargetDb][lowT:highT] = externalDbs;
         externalIds = copy(externalGeneIds);
         externalDbs = copy(externalGeneDbs);
         # x[low,:EnsemblGeneId] = gene["id"];
         # x[low,:EnsemblTranscriptId] = transcript["id"];
         # x[low,:EnsemblProteinId] = peptide["id"];
         # println("[$i] : $externalId, $externalDb")
         # println.("enspId: $(transcript["peptide"]["id"]) -> $(transcript["peptide"]["targetIds"])")
         lowT = highT + 1;
         highT = lowT;
      end
      highG = highT-1;
      # Fill in gene information
      for (key, value) in gene
         if haskey(geneCols, key) && !isempty(value)
            val = value;
            if key == "aliases"
               val = join(value, ",");
            end
            x[geneCols[key]][lowG:highG] = val;
         end
      end
      # map(key->haskey(geneCols,key) && (x[geneCols[key]][lowG:highG] = fill(join(gene[key], ","), (highG - lowG + 1))), keys(gene));
      x[:InputId][lowG:highG] = entry["row"][1]["inputId"];
      x[:InputSourceDb][lowG:highG] = entry["row"][1]["inputDb"];
      lowG = highG + 1;
   end
   x

   return x;
   
end

function unstackDf(x::D, keyCols::S = Vector{Symbol}(), keyColsElType::T = Vector{DataType}()) where {
   D<:DataFrames.DataFrame,
   S<:Vector{Symbol},
   T<:Vector{DataType}}
   
   if isempty(keyCols)
      keyCols = names(x)[map(i->!in(i,["TargetId", "TargetDb"]), collect(String,names(x)))];
      keyColsElType = DataFrames.eltypes(x)[map(i->!in(i,["TargetId", "TargetDb"]), collect(String,names(x)))];
   elseif length(keyCols != length(keyColsElType))
      error("keyCols and keyColsElType have to be of same length.!");
   end
   colNames = copy(keyCols);
   colElTypes = copy(keyColsElType);
   
   append!(colNames, DataFrames.identifier.(collect(unique(x[:TargetDb]))));
   append!(colElTypes, fill(Union{String, Missing}, (length(colNames) - length(keyCols))));
   nRows = DataFrames.nrow(unique(x[keyCols]));

   xDf = DataFrames.DataFrame(
      colElTypes,
      colNames,
      nRows
   );
   sortByCols = copy(keyCols);
   push!(sortByCols, :TargetDb);
   sort!(x, cols = sortByCols);
   idx = 0;
   key = "";
   for row in DataFrames.eachrow(x)
      keyCurr = join(map(i->i[2], row[keyCols]));
      if key != keyCurr
         idx += 1;
         key = keyCurr;
         map(i->xDf[idx,i[1]] = i[2], row[keyCols]);
      end
      colId = DataFrames.identifier(row[:TargetDb])
      xDf[idx, colId] = DataFrames.ismissing(xDf[idx, colId]) ?
                           row[:TargetId] :
                           xDf[idx, colId] * "," * row[:TargetId];
   end
   return xDf;
end
