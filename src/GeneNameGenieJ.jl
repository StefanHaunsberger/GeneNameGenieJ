# VERSION >= v"0.4" && __precompile__(true)
module GeneNameGenieJ

using Neo4j, DataFrames, DataFramesMeta, Lazy;

global const DEFAULT_PORT = 7474;
global const DEFAULT_PATH = "db/data/";
global const DEFAULT_HOST = "localhost";

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
   con = Neo4j.Connection(DEFAULT_HOST);
   global NEO4J_CONNECTION;
   NEO4J_CONNECTION = con;
   try
      graph = getgraph(con);
      println("Neo4j connection with default URL $DEFAULT_HOST successfully established.");
      true;
   catch
      warn("Was not able to connect to Neo4j database on default host $DEFAULT_HOST");
      false;
   end

   return con;
end

global NEO4J_CONNECTION = establishNeo4jConnection();

"""
    setNeo4jConnection(;host::String = DEFAULT_HOST, port::Integer = DEFAULT_PORT, path::String = DEFAULT_PATH)

Set desired global Neo4j connection. Default is `localhost:7474/db/data/`.

"""
function setNeo4jConnection(;host::T = DEFAULT_HOST, port::I = DEFAULT_PORT, path::T = DEFAULT_PATH) where 
   {T<:String, I<:Integer}

   # Add leading and trailing slash if missing
   if !startswith(path, "/")
      path = "/" * path;
   end
   if !endswith(path, "/")
      path = path * "/";
   end

   con = Neo4j.Connection(host, port = port, path = path);
   # conUrl = con.host * ":" * string(con.port);
   try
      print("test connection for $(con.url)");
      graph = getgraph(con);
      println("Neo4j connection successfully established and set.");
      global NEO4J_CONNECTION;
      NEO4J_CONNECTION = con;
   catch
      warn("Was not able to connect to Neo4j database $(con.url)");
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
