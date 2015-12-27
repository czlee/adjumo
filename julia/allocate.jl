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
        range_tester = x -> x ∈ ["default", "gurobi", "cbc", "glpk"] || startswith(x, "gurobicloud/")
    "--enforce-team-conflicts"
        help = "Enforce team-adjudicator conflicts (as opposed to just penalize)"
        action = :store_true
    "--json-dir"
        help = "Where to write JSON files upon completion."
        default = joinpath(Base.source_dir(), "../frontend/public/data")
    "--weights-file"
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
    "-t", "--threads"
        help = "Number of threads to use for solver"
        arg_type = Int
        default = CPU_CORES
    "-l", "--limitpanels"
        help = "Limit how many panels it samples"
        arg_type = Int
        default = typemax(Int)
    "-f", "--feasible-panels"
        help = "Feasible panels file"
        default = ""
    "--timelimit"
        help = "Time limit for Gurobi solver"
        default = 300
    "--randomize-blanks"
        help = "Randomize blank regions, genders, languages and rankings"
        action = :store_true
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

if args["randomize-blanks"]
    println("Randomizing blanks...")
    for adj in roundinfo.adjudicators
        if NoRegion in adj.regions
            randomregions!(adj)
        end
        if adj.gender == PersonNoGender
            randomgender!(adj)
        end
        if adj.language == NoLanguage
            randomlanguage!(adj)
        end
        randomranking!(adj)
    end
    for team in roundinfo.teams
        if team.region == NoRegion
            randomregion!(team)
        end
        if team.gender == TeamNoGender
            randomgender!(team)
        end
        if team.language == NoLanguage
            randomlanguage!(team)
        end
    end
end

componentweightsfile = open(args["weights-file"])
importcomponentweightsjsonintoroundinfo!(roundinfo, componentweightsfile)
close(componentweightsfile)

println("There are $(numdebates(roundinfo)) debates and $(numadjs(roundinfo)) adjudicators.")

kwargs = Dict(:solver=>args["solver"],
        :enforceteamconflicts=>args["enforce-team-conflicts"],
        :gap=>args["gap"], :threads=>args["threads"], :timelimit=>args["timelimit"])

if length(args["feasible-panels"]) > 0
    f = open(args["feasible-panels"])
    feasiblepanels = importfeasiblepanels(f, roundinfo)
    close(f)
    feasiblepanels = feasiblepanels[1:5:end]
    println("Imported $(length(feasiblepanels)) feasible panels")
    allocations = allocateadjudicators(roundinfo, feasiblepanels; kwargs...)
else
    allocations = allocateadjudicators(roundinfo; limitpanels=args["limitpanels"], kwargs...)
end

println("Writing JSON files...")
directory = args["json-dir"]

exportroundinfo(roundinfo, directory)
exportallocations(allocations, directory)
exporttabbiejson(allocations, directory)

if args["show"]
    showconstraints(roundinfo)
    for allocation in allocations
        showdebatedetail(roundinfo, allocation)
    end
end
