# Performance profiling for parallel computation of region scores

push!(LOAD_PATH, joinpath(Base.source_dir(), ".."))
using ArgParse
using Adjumo
import Adjumo: debateregionclass, DebateRegionClass, panelregionalrepresentationscore
using AdjumoDataTools

function regionalrepresentationmatrix(feasiblepanels::Vector{AdjudicatorPanel}, roundinfo::RoundInfo)
    ndebates = numdebates(roundinfo)
    npanels = length(feasiblepanels)

    debateinfos = Vector{Tuple{DebateRegionClass, Vector{Region}}}(ndebates)
    for (i, debate) in enumerate(roundinfo.debates)
        teamregions = Region[t.region for t in debate.teams]
        debateinfos[i] = debateregionclass(teamregions)
    end

    Πα = Matrix{Float64}(ndebates, npanels)
    for (p, panel) in enumerate(feasiblepanels), (d, dinfo) in enumerate(debateinfos)
        Πα[d,p] = panelregionalrepresentationscore(dinfo..., panel)
    end
    return Πα
end

function regionalrepresentationmatrix_dist(feasiblepanels::Vector{AdjudicatorPanel}, roundinfo::RoundInfo)
    ndebates = numdebates(roundinfo)
    npanels = length(feasiblepanels)

    debateinfos = Vector{Tuple{DebateRegionClass, Vector{Region}}}(ndebates)
    for (i, debate) in enumerate(roundinfo.debates)
        teamregions = Region[t.region for t in debate.teams]
        debateinfos[i] = debateregionclass(teamregions)
    end

    # Parallelize this part, it's heavy
    Πα = SharedArray(Float64, (ndebates, npanels))
    @sync @parallel for p in 1:length(feasiblepanels)
        panel = feasiblepanels[p]
        for (d, dinfo) in enumerate(debateinfos)
            Πα[d,p] = panelregionalrepresentationscore(dinfo..., panel)
        end
    end
    return Πα
end

argsettings = ArgParseSettings()
@add_arg_table argsettings begin
    "-n", "--ndebates"
        help = "Number of debates in round"
        arg_type = Int
        default = 5
    "-r", "--currentround"
        help = "Current round number"
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
feasiblepanels = generatefeasiblepanels(roundinfo)

# once first to compile
smallroundinfo = randomroundinfo(5, 2)
smallfeasiblepanels = generatefeasiblepanels(smallroundinfo)
regionalrepresentationmatrix(smallfeasiblepanels, smallroundinfo)
regionalrepresentationmatrix_dist(smallfeasiblepanels, smallroundinfo)

println("serial:")
@time A = regionalrepresentationmatrix(feasiblepanels, roundinfo)
println("parallel:")
@time B = regionalrepresentationmatrix_dist(feasiblepanels, roundinfo)
@show size(A)
@show size(B)
@show sumabs(A-B)
@show maxabs(A-B)
