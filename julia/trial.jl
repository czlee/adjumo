push!(LOAD_PATH, Base.source_dir())
using ArgParse
using Adjumo
using AdjumoDataTools
using JsonAPI

argsettings = ArgParseSettings()
@add_arg_table argsettings begin
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
    "--enforce-team-conflicts"
        help = "Enforce team-adjudicator conflicts (as opposed to just penalize)"
        action = :store_true
    "--json-dir"
        help = "Where to write JSON files upon completion."
        default = "../frontend/public/data"
    "--tabbie1"
        help = "Import a Tabbie1 database: <username> <password> <database>"
        metavar = "ARG"
        nargs = 3
    "--tabbie2"
        help = "Import a Tabbie2 export file"
        metavar = "JSONFILE"
        default = nothing
    "--show"
        help = "Print result to console"
        action = :store_true
    "-g", "--gap"
        help = "Tolerance gap"
        arg_type = Float64
        default = 1e-2
    "-t", "--threads"
        help = "Number of threads to use for solver"
        arg_type = Int
        default = 8
end
args = parse_args(ARGS, argsettings)

ndebates = args["ndebates"]
currentround = args["currentround"]
componentweights = AdjumoComponentWeights()
componentweights.panelsize = 10
componentweights.quality = 1
componentweights.regional = 0.01
componentweights.language = 1
componentweights.gender = 1
componentweights.teamhistory = 100
componentweights.adjhistory = 100
componentweights.teamconflict = 1e6
componentweights.adjconflict = 1e6
if length(args["tabbie1"]) == 0
    roundinfo = randomroundinfo(ndebates, currentround)
elseif args["tabbie2"] != nothing
    tabbie2file = open(args["tabbie2"])
    roundinfo = importtabbiejson(tabbie2file)
else
    using DBI
    using PostgreSQL
    username, password, database = args["tabbie1"]
    dbconnection = connect(Postgres, "localhost", username, password, database, 5432)
    roundinfo = gettabbie1roundinfo(dbconnection, currentround)
end
roundinfo.componentweights = componentweights

allocations = allocateadjudicators(roundinfo; solver=args["solver"],
        enforceteamconflicts=args["enforce-team-conflicts"],
        gap=args["gap"], threads=args["threads"])

println("Writing JSON files...")
directory = args["json-dir"]

exportroundinfo(roundinfo, directory)
exportallocations(allocations, directory)

if args["show"]
    showconstraints(roundinfo)
    for allocation in allocations
        showdebatedetail(roundinfo, allocation)
    end
end
