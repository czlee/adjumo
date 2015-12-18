push!(LOAD_PATH, Base.source_dir())
using AdjumoDataTools
using ArgParse

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
end
args = parse_args(ARGS, argsettings)

rinfo = gettabbie1roundinfo(args["username"], args["password"], args["database"], 9;
        host=args["host"], port=args["port"])
showteams(rinfo)
showadjudicators(rinfo)