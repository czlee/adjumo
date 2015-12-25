push!(LOAD_PATH, Base.source_dir())
using ArgParse
using Adjumo
using AdjumoDataTools
using JsonAPI

argsettings = ArgParseSettings()
@add_arg_table argsettings begin
    "outfile"
        help = "Output file name"
        required = true
    "-n", "--ndebates"
        help = "Number of debates in round (for random datasets only)"
        arg_type = Int
        default = 5
    "-r", "--currentround"
        help = "Current round number"
        arg_type = Int
        default = 5
    "--solver"
        help = "Solver to use ('gurobi', 'cbc' or 'glpk')"
        default = "default"
        range_tester = x -> x ∈ ["default", "gurobi", "cbc", "glpk"]
    "--tabbie1"
        help = "Import a Tabbie1 database: <username> <password> <database>"
        metavar = "ARG"
        nargs = 3
    "--tabbie2"
        help = "Import a Tabbie2 export file"
        metavar = "JSONFILE"
        default = ""
    "-l", "--limitpanels"
        help = "Limit how many panels it samples"
        arg_type = Int
        default = typemax(Int)
end
args = parse_args(ARGS, argsettings)

ndebates = args["ndebates"]
currentround = args["currentround"]

if length(args["tabbie2"]) > 0
    tabbie2file = open(args["tabbie2"])
    roundinfo = importtabbiejson(tabbie2file)
elseif length(args["tabbie1"]) > 0
    using DBI
    using PostgreSQL
    username, password, database = args["tabbie1"]
    dbconnection = connect(Postgres, "localhost", username, password, database, 5432)
    roundinfo = gettabbie1roundinfo(dbconnection, currentround)
else
    roundinfo = randomroundinfo(ndebates, currentround)
end

feasiblepanels = generatefeasiblepanels(roundinfo; limitpanels=args["limitpanels"])
f = open(args["outfile"], "w")
exportfeasiblepanels(f, feasiblepanels)
close(f)