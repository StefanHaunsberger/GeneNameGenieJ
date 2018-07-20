"""
    getValidDatabases()
   
Return a `DataFrame` object with two columns, `DatabaseDisplayName` and `DatabaseId`.
The dataframe containing all supported databases. Values from the column 
`DatabaseId` can be used as input parameter `targetDb` and `sourceDb`
in several functions contained in the GeneNameGenie module, such as the function
`convertFromTo`.
"""
function getValidDatabases()
   x = Neo4j.cypherQuery(NEO4J_CONNECTION, "CALL rcsi.params.getValidDatabases() YIELD value RETURN value.DatabaseDisplayName AS DatabaseDisplayName, value.DatabaseId AS DatabaseId");
   return x;
end

"""
    getValidAttributes()
   
Return a `DataFrame` object with a single column, `Parameters`. Values from 
the `Parameters` column can be used as input parameter `attributes` in the 
`convertFromToExtended` function, for example `ensg:region`, which will return
the genomic region of the corresponding Ensembl gene.
"""
function getValidAttributes()
   x = Neo4j.cypherQuery(NEO4J_CONNECTION, "CALL rcsi.params.getValidAttributes() YIELD value RETURN value AS Parameters");
   return x;
end

"""
    getValidMirnaMetadataValues()
   
Return a `DataFrame` object with a single column, `Parameters`. Values from 
the `Parameters` column can be used as input parameter `metadata` in the 
`convertToCurrentMirbaseVersion` function, for example the parameter `region`
returns the genomic region of the corresponding precursor miRNA gene.
"""
function getValidMirnaMetadataValues()
   x = Neo4j.cypherQuery(
         NEO4J_CONNECTION,
         "CALL rcsi.params.getValidMirnaMetadataValues() YIELD value RETURN value AS Parameter");
   return x;
end

"""
    getCurrentMirbaseVersion()
   
Return the current miRBase release version information (the highest supported version).
"""
function getCurrentMirbaseVersion()
   x = Neo4j.cypherQuery(
         NEO4J_CONNECTION, 
         "MATCH (db :MirnaDB {id: 'miRBase_mature_name'}) RETURN db.release AS release;")[1,:release];
   # mirbaseVersion = parse(match(r"\d+(\.?\d+)", split(x, ",")[1]).match);
   # mirbaseVersion = split(x, ",");
   return x;
end

"""
    getEnsemblVersion()
   
Return the Ensembl DB version of GeneNameGenie.
"""
function getEnsemblVersion()
   x = Neo4j.cypherQuery(
         NEO4J_CONNECTION, 
         "MATCH (db :EnsemblDB {id: 'ArrayExpress'}) RETURN db.release AS release;")[1,:release];
   # mirbaseVersion = parse(match(r"\d+(\.?\d+)", split(x, ",")[1]).match);
   # mirbaseVersion = split(x, ",");
   return x;
end
