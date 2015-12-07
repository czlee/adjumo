# Performance profiling for parallel computation of region scores

push!(LOAD_PATH, joinpath(Base.source_dir(), ".."))
using ArgParse
using Adjumo
import Adjumo: panelregionalrepresentationscore
include("../random.jl")

function regionalrepresentationmatrix(feasiblepanels::Vector{AdjudicatorPanel}, roundinfo::RoundInfo)
    ndebates = numdebates(roundinfo)
    npanels = length(feasiblepanels)

    teamregions = Vector{Vector{Region}}(ndebates)
    for (i, debate) in enumerate(roundinfo.debates)
        teamregions[i] = Region[t.region for t in debate]
    end

    panelinfos = Vector{Tuple{Int, Vector{Region}}}(npanels)
    for (i, panel) in enumerate(feasiblepanels)
        panelinfos[i] = (numadjs(panel), vcat(Vector{Region}[adj.regions for adj in adjlist(panel)]...))
    end

    βr = Matrix{Float64}(ndebates, npanels)
    @time for (p, (nadjs, adjregions)) in enumerate(panelinfos), (d, tr) in enumerate(teamregions)
        βr[d,p] = panelregionalrepresentationscore(tr, adjregions, nadjs)
    end
    return βr
end

function regionalrepresentationmatrix_dist(feasiblepanels::Vector{AdjudicatorPanel}, roundinfo::RoundInfo)
    ndebates = numdebates(roundinfo)
    npanels = length(feasiblepanels)

    teamregions = Vector{Vector{Region}}(ndebates)
    for (i, debate) in enumerate(roundinfo.debates)
        teamregions[i] = Region[t.region for t in debate]
    end

    panelinfos = Vector{Tuple{Int, Vector{Region}}}(npanels)
    for (i, panel) in enumerate(feasiblepanels)
        panelinfos[i] = (numadjs(panel), vcat(Vector{Region}[adj.regions for adj in adjlist(panel)]...))
    end

    # Parallelize this part, it's heavy
    βr = SharedArray(Float64, (ndebates, npanels))
    @time @sync @parallel for p in 1:length(panelinfos)
        nadjs, adjregions = panelinfos[p]
        for (d, tr) in enumerate(teamregions)
            βr[d,p] = panelregionalrepresentationscore(tr, adjregions, nadjs)
        end
    end
    return βr
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
end
args = parse_args(ARGS, argsettings)

ndebates = args["ndebates"]
currentround = args["currentround"]
roundinfo = randomroundinfo(ndebates, currentround)
feasiblepanels = generatefeasiblepanels(roundinfo)

# once first to compile
regionalrepresentationmatrix(feasiblepanels, roundinfo)
regionalrepresentationmatrix_dist(feasiblepanels, roundinfo)

println("serial:")
@time A = regionalrepresentationmatrix(feasiblepanels, roundinfo)
println("parallel:")
@time B = regionalrepresentationmatrix_dist(feasiblepanels, roundinfo)
@show maxabs(A-B)
