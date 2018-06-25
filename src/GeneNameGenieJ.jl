# VERSION >= v"0.4" && __precompile__(true)
module GeneNameGenieJ

using Neo4j, DataFrames, DataFramesMeta, Lazy;

global NEO4J_DEFAULT_HOST_URL = "localhost";

export 
   setNeo4jConnection,
   getOfficialGeneSymbol, 
   convertFromToExtended, 
   convertFromTo,
   getValidDatabases,
   getValidAttributes,
   convertToCurrentMirbaseVersion,
   convertMatureMirnasToVersions,
   getValidMirnaMetadataValues,
   getCurrentMirbaseVersion,
   getEnsemblVersion;

function establishNeo4jConnection()
   
   # Try and connect to default host
   con = Neo4j.Connection(NEO4J_DEFAULT_HOST_URL);
   global NEO4J_CONNECTION;
   NEO4J_CONNECTION = con;
   try
      graph = getgraph(con);
      println("Neo4j connection with default URL $NEO4J_DEFAULT_HOST_URL successfully established.");
      true;
   catch
      warn("Was not able to connect to Neo4j database on default host $NEO4J_DEFAULT_HOST_URL");
      false;
   end

   return con;
end

global NEO4J_CONNECTION = establishNeo4jConnection();

"""
    setNeo4jConnection(con::Neo4j.Connection)

Set desired global Neo4j connection. Default is `localhost`.

"""
function setNeo4jConnection(con::C) where {C<:Neo4j.Connection}
   
   conUrl = con.host * ":" * string(con.port);
   try
      print("test connection for $conUrl");
      graph = getgraph(con);
      println("Neo4j connection successfully established and set.");
      global NEO4J_CONNECTION;
      NEO4J_CONNECTION = con;
   catch
      warn("Was not able to connect to Neo4j database $conUrl");
   end
   
end

# ids = String["P10415", "PUMA", "Bcl-2", "MYH14", "IGHV1-2", "AMPK", "ENST00000589955"];
# ids = String["Bcl-2", "MYH14", "IGHV1-2"];
# # ids = String["HOX1A", "CDK1", "ENST00000589950", "MYH14", "IGHV1-2", "PRKAA2", "HGNC:5550"];
# # dbs = String["HGNC", "GeneSymbolDB", "Uniprot/SWISSPROT", "Uniprot/SPTREMBL", "ArrayExpress", "Ens_Hs_transcript"];
# dbs = String["HGNC", "GeneSymbolDB", "Uniprot/SWISSPROT", "Uniprot/SPTREMBL"];
# # params = String["ensg:version", "ensg:region", "enst:region", "enst:regionStart", "enst:regionEnd", "aliases"];
# params = String["aliases"];

global addDbColDict = Dict{String, Symbol}(
   "ArrayExpress" => :EnsemblGeneId,
   "Ens_Hs_transcript" => :EnsemblTranscriptId,
   "Ens_Hs_translation" => :EnsemblProteinId
);

#########################################
# Include files
#########################################
include("validationFunctions.jl");
include("convertFromToExtendedParser.jl");
include("parameterFunctions.jl");
include("molecularIdentifierFunctions.jl");
include("mirnas.jl");

end # module
