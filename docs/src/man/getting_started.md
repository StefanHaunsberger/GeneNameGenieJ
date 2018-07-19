# Getting Started

## Installation

GeneNameGenieJ depends on a [Neo4j](https://neo4j.com/) graph database (GDB) as a backend.
There are two ways GeneNameGenieJ can be used:
 1) Use the online hosted GeneNameGenie GDB as backend, or
 2) Set up a local GeneNameGenie GDB instance and use it locally.

The advantage of having it set up locally is that a 'stable' version of the
GeneNameGenie GDB can be used which is independent from online version updates.

### Setting up a local instance of the GeneNameGenie GDB

#### Part 1: Installing Neo4j community server and initialise GeneNameGenie

 1) Please install a local instance of the Neo4j GDB server.
Please visit the [Neo4j website](https://neo4j.com/download/) and download the
latest Neo4j Community version.
Unpack the archive and place it in a directory of your choice
 2) Download the GeneNameGenie GDB data from the following link -> [download]()
 3) Extract the archive and place it into the directory `$NEO4J_HOME/data/databases`.

#### Part 2: Java stored procedures and config file

 1) Download the Awecome Procedures (apoc) for Neo4j corresponding to the Neo4j version
 [apoc-library](https://github.com/neo4j-contrib/neo4j-apoc-procedures).
 2) Download the GeneNameGenie JAR file from the GitHub [repository]().
 3) Place the `*.jar` files into the `$NEO4J_HOME/plugins` folder.
 4) Open the `$NEO4J_HOME/conf/neoj4.conf` file with your editor of choice and add
 the `apoc.*,rcsi.*` to the `dbms.security.procedures.unrestricted` parameter. If the
 settings do not just exist, just add them to the end of the file. The line could look
 something like the following:

```bash
  #********************************************************************
  # Apoc
  #********************************************************************
  # Allow to run sandboxed stored procedures
  dbms.security.procedures.unrestricted=apoc.*,rcsi.*
```

 5) Two more parameters need to be adjusted (the `dbms.security.auth_enabled` is optional)

```bash
# Whether requests to Neo4j are authenticated.
# To disable authentication, uncomment this line
dbms.security.auth_enabled=false

# Enable this to be able to upgrade a store from an older version.
dbms.allow_upgrade=true
```

 6) Start the Neo4j server: Either via calling `sudo $NEO4J_HOME/bin/neo4j start` or 
      starting the service as described in the Neo4j [documentation]().

### GeneNameGenieJ

The GeneNameGenieJ package is available through the Julia package system and can be installed using the following command:

```julia
Pkg.add("GeneNameGenieJ")
```

At this stage we assume, that you have a running GeneNameGenie Neo4j GDB instance,
have installed the GeneNameGenieJ package and have already executed `using GeneNameGenieJ`.