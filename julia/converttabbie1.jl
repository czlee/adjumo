# Trial Tabbie1 data from a PostgreSQL database into a RoundInfo.
#
# Requirements:
#   Pkg.clone("https://github.com/JuliaDB/PostgreSQL.jl.git")
# AdjumoDataTools also requires
#   Pkg.clone("https://github.com/JuliaDB/DBI.jl.git")
# (These are both unregistered packages at time of writing.)
#
# This script requires the data to be in a PostgreSQL database. This is not the
# same database engine used by Tabbie1 -- Tabbie1 uses MySQL -- so Tabbie1 data
# needs to be ported before it can be used by this script. I used PostgreSQL
# because I normally use PostgreSQL and couldn't be bothered installing MySQL.
#
# There is quite a bit of manual work to get a Tabbie1 dataset into this form:
#
#  1. Access to a PostgreSQL server, probably one installed on your machine.
#
#  2. A PostgreSQL database that contains a port of the Tabbie1 database you
#     were using. The database must already exist in PostgreSQL.
#
#     If you're importing from a MySQL backup file from Tabbie1, this means you
#     need to port the backup file to a PostgreSQL backup file, and then run
#       createdb mydb
#       psql -d mydb -f mydb.psql
#
#     I used a tool at https://github.com/lanyrd/mysql-postgresql-converter, but
#     it wasn't designed for the general use-case, so I needed to edit the MySQL
#     backup file in order to avoid offending it.


push!(LOAD_PATH, Base.source_dir())
using Adjumo
using AdjumoDataTools
using ArgParse
using DBI
using PostgreSQL

argsettings = ArgParseSettings()
@add_arg_table argsettings begin
    "username"
        help = "PostgreSQL username"
        required = true
    "password"
        help = "PostgreSQL password"
        required = true
    "database"
        help = "Name of PostgreSQL database"
        required = true
    "currentround"
        help = "Current round (default 9)"
        arg_type = Int
        default = 9
    "--host"
        help = "IP address of PostgreSQL server (default localhost)"
        default = "localhost"
    "--port"
        help = "Port number of PostgreSQL server (default 5432)"
        arg_type = Int
        default = 5432
    "--dir"
        help = "Output directory"
        default = "tabbie1data"
end
args = parse_args(ARGS, argsettings)

host = args["host"]
dbname = args["database"]
println("Connecting to database $dbname on server $host...")
dbconnection = connect(Postgres, host, args["username"], args["password"], dbname, args["port"])

rinfo = gettabbie1roundinfo(dbconnection, args["currentround"])
showteams(rinfo)
showadjudicators(rinfo)
exportroundinfo(rinfo, args["dir"])