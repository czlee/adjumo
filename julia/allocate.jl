push!(LOAD_PATH, Base.source_dir())
using ArgParse
using Adjumo
using AdjumoDataTools
using JsonAPI

argsettings = ArgParseSettings()
@add_arg_table argsettings begin
    "-r", "--currentround"
        help = "Current round number"
        arg_type = Int
        required = true
    "-S", "--solver"
        help = "Solver to use ('gurobi', 'cbc' or 'glpk')"
        default = "default"
        range_tester = x -> x ∈ ["default", "gurobi", "cbc", "glpk"] || startswith(x, "gurobicloud/")
    "-n", "--ndebates"
        help = "Number of debates in round (for random datasets only)"
        arg_type = Int
        default = 5
    "--tabbie1"
        help = "Import a Tabbie1 database: <username> <password> <database>"
        metavar = "ARG"
        nargs = 3
    "--tabbie2"
        help = "Import a Tabbie2 export file"
        metavar = "JSONFILE"
        default = ""
    "--enforceteamconflicts", "--enfteam"
        help = "Enforce team-adjudicator conflicts (as opposed to just penalize)"
        action = :store_true
    "--enforceallocateall", "--enfall"
        help = "Require all accredited adjudicators to be allocated"
        action = :store_true
    "--jsonoutdir"
        help = "Where to write JSON files upon completion."
        default = joinpath(Base.source_dir(), "../frontend/public/data/")
    "--backenddir"
        help = "Where to find inputs from the web-based UI (not the tab data)"
        default = joinpath(Base.source_dir(), "../backend/data/")
    "-R", "--printresult"
        help = "Print result to file, or '-' (a hyphen) for stdout"
        default = "result.txt"
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
        arg_type = Int
        default = 600
    "--randomizeblanks"
        help = "Randomize blank regions, genders, languages and rankings"
        action = :store_true
    "-f", "--fpgmethod"
        help = "Feasible panels generation method"
        arg_type = Symbol
        default = :exhaustive
end
args = parse_args(ARGS, argsettings; as_symbols=true)
for (k, v) in args
    println("argument $k = $v")
end

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

importsupplementaryinfofromjson!(roundinfo, args[:backenddir])

roundinfo.componentweights.quality = 1
roundinfo.componentweights.regional = 1
roundinfo.componentweights.language = 1
roundinfo.componentweights.gender = 5
roundinfo.componentweights.teamhistory = 25
roundinfo.componentweights.adjhistory = 25
roundinfo.componentweights.teamconflict = 1000
roundinfo.componentweights.adjconflict = 1000
roundinfo.componentweights.α = 1
roundinfo.componentweights.qualitydeficit = 1
roundinfo.componentweights.regionaldeficit = 1
roundinfo.componentweights.languagedeficit = 1
roundinfo.componentweights.genderdeficit = 1
@show roundinfo.componentweights

roundinfo.currentround = currentround
@show roundinfo.currentround

println("There are $(numdebates(roundinfo)) debates and $(numadjs(roundinfo)) adjudicators.")
println("$(length(roundinfo.lockedadjs)) locks, $(length(roundinfo.blockedadjs)) blocks, $(length(roundinfo.groupedadjs)) groups")

println("debate weights:")
@time computedebateweights!(roundinfo)

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
directory = args[:jsonoutdir]

exportroundinfo(roundinfo, directory)
exportallocations(allocations, directory)
exporttabbiejson(allocations, directory)

if length(args[:printresult]) > 0
    if args[:printresult] == "-"
        resultfile = STDOUT
    else
        resultfile = open(args[:printresult], "w")
    end

    showconstraints(resultfile, roundinfo)
    for allocation in allocations
        showdebatedetail(resultfile, roundinfo, allocation)
    end

    if resultfile != STDOUT
        close(resultfile)
    end
end
