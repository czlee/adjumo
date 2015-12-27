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
    "-S", "--solver"
        help = "Solver to use ('gurobi', 'cbc' or 'glpk')"
        default = "default"
        range_tester = x -> x ∈ ["default", "gurobi", "cbc", "glpk"] || startswith(x, "gurobicloud/")
    "--enforceteamconflicts", "--enfteam"
        help = "Enforce team-adjudicator conflicts (as opposed to just penalize)"
        action = :store_true
    "--enforceallocateall", "--enfall"
        help = "Require all accredited adjudicators to be allocated"
        action = :store_true
    "--jsondir"
        help = "Where to write JSON files upon completion."
        default = joinpath(Base.source_dir(), "../frontend/public/data")
    "--weightsfile"
        help = "Where to find the component weights JSON file."
        default = joinpath(Base.source_dir(), "../backend/data/allocation-config.json")
    "--tabbie1"
        help = "Import a Tabbie1 database: <username> <password> <database>"
        metavar = "ARG"
        nargs = 3
    "--tabbie2"
        help = "Import a Tabbie2 export file"
        metavar = "JSONFILE"
        default = ""
    "--show"
        help = "Print result to console"
        action = :store_true
    "-g", "--gap"
        help = "Tolerance gap"
        arg_type = Float64
        default = 1.2e-2
    "-t", "--solverthreads"
        help = "Number of threads to use for solver"
        arg_type = Int
    "-p", "--nfeasiblepanels"
        help = "Limit how many panels it samples"
        arg_type = Int
        default = -1
    "--feasiblepanelsfile"
        help = "Feasible panels file"
        default = ""
    "-T", "--timelimit"
        help = "Time limit for Gurobi solver"
    "--randomizeblanks"
        help = "Randomize blank regions, genders, languages and rankings"
        action = :store_true
    "-f", "--fpgmethod"
        help = "Feasible panels generation method"
        arg_type = Symbol
        default = :exhaustive
end
args = parse_args(ARGS, argsettings; as_symbols=true)

ndebates = args[:ndebates]
currentround = args[:currentround]

if length(args[:tabbie2]) > 0
    tabbie2file = open(args[:tabbie2])
    roundinfo = importtabbiejson(tabbie2file)
elseif length(args[:tabbie1]) > 0
    using DBI
    using PostgreSQL
    username, password, database = args[:tabbie1]
    dbconnection = connect(Postgres, "localhost", username, password, database, 5432)
    roundinfo = gettabbie1roundinfo(dbconnection, currentround)
else
    roundinfo = randomroundinfo(ndebates, currentround)
end

if args[:randomizeblanks]
    randomizeblanks!(roundinfo)
end

componentweightsfile = open(args[:weightsfile])
importcomponentweightsjsonintoroundinfo!(roundinfo, componentweightsfile)
close(componentweightsfile)

println("There are $(numdebates(roundinfo)) debates and $(numadjs(roundinfo)) adjudicators.")

if length(args[:feasiblepanelsfile]) > 0
    f = open(args[:feasiblepanelsfile])
    feasiblepanels = importfeasiblepanels(f, roundinfo)
    close(f)
    feasiblepanels = feasiblepanels[1:5:end]
    println("Imported $(length(feasiblepanels)) feasible panels")
    allocations = allocateadjudicators(roundinfo, feasiblepanels; args...)
else
    allocations = allocateadjudicators(roundinfo; args...)
end

println("Writing JSON files...")
directory = args[:jsondir]

exportroundinfo(roundinfo, directory)
exportallocations(allocations, directory)
exporttabbiejson(allocations, directory)

if args[:show]
    showconstraints(roundinfo)
    for allocation in allocations
        showdebatedetail(roundinfo, allocation)
    end
end
