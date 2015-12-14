push!(LOAD_PATH, joinpath(Base.source_dir(), ".."))
using ArgParse
using Adjumo
using JuMP
include("../random.jl")

function regionalrepresentationmatrix1(feasiblepanels::Vector{AdjudicatorPanel}, roundinfo::RoundInfo)
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
    for (p, (nadjs, adjregions)) in enumerate(panelinfos), (d, tr) in enumerate(teamregions)
        βr[d,p] = panelregionalrepresentationscore(tr, adjregions, nadjs)
    end
    return βr
end

function regionalrepresentationmatrix2(feasiblepanels::Vector{AdjudicatorPanel}, roundinfo::RoundInfo)
    ndebates = numdebates(roundinfo)
    npanels = length(feasiblepanels)

    teamregions = map(roundinfo.debates) do debate
        Region[t.region for t in debate]
    end
    panelinfos = map(feasiblepanels) do panel
        (numadjs(panel), vcat(Vector{Region}[adj.regions for adj in adjlist(panel)]...))
    end

    βr = Matrix{Float64}(ndebates, npanels)
    for (p, (nadjs, adjregions)) in enumerate(panelinfos), (d, tr) in enumerate(teamregions)
        βr[d,p] = panelregionalrepresentationscore(tr, adjregions, nadjs)
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

funcs = [
    regionalrepresentationmatrix1;
    regionalrepresentationmatrix2;
]

A = [f(feasiblepanels, roundinfo) for f in funcs]

for i = 1:5
    for f in shuffle(funcs)
        println(f)
        @time for j = 1:20
            f(feasiblepanels, roundinfo)
        end
    end
end

for (i, j) in combinations(1:length(funcs), 2)
    @show (funcs[i], funcs[j]) (A[i] == A[j])
end
