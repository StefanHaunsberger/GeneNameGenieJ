
function checkReturnedQueryIds(xDf::D, ids::T) where {D<:DataFrames.DataFrame, T<:Vector{String}}
   
   # Check for symbols that were not found in the DB
   uniqueIds = unique(xDf[:InputId]);

   diffIds = setdiff(ids, uniqueIds);
   if !isempty(diffIds)
      warn("No values found for:", prefix = "WARNING: ");
      foreach(el -> warn(el, prefix = ""), diffIds);
   end

   # Check if there are multiple records per input value
   idsOne2M = @> begin
      xDf
      @select(:InputId, :InputSourceDb)
      unique()
      @by(:InputId, nRows = length(:InputSourceDb))
      @where(:nRows .> 1)
   end

   if !isempty(idsOne2M)
      warn("Some input IDs have multiple mappings", prefix = "WARNING: ");
      # foreach(el -> warn(el, prefix = ""), idsOne2M[:InputId]);
   end

end


function postCheckMirnas(x::DataFrames.DataFrame, check::Symbol, input::Vector{String})
   if DataFrames.nrow(x) > 0
      # Check for multi matches
      # multiMatches = @> begin
      #    x[[:InputId, check]]
      #    unique()
      #    @by(:InputId, nRows = length(names()[2]))
      #    @where(:nRows .> 1)
      # end

      # if (DataFrames.nrow(multiMatches) != 0)
      #    warn("Some input identifiers match to more than one MIMAT accession!");
      #    show(multiMatches);
      # end

      dif = setdiff(input, x[:InputId]);
      if length(dif) != 0
         warn("Some input identifiers were not found in the database.");
         show(dif);
      end

      dif = setdiff(x[:InputId], input);
      if length(dif) != 0
         warn("Some input identifiers have multiple matches.");
         show(dif);
      end

   end
end
