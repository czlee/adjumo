# Performance profiling for computation of panel allocation type conversion

push!(LOAD_PATH, joinpath(Base.source_dir(), ".."))
using ArgParse
using Adjumo
using StatsBase
import Adjumo.PanelAllocation
using AdjumoDataTools

function convertallocations1(debates::Vector{Debate}, panels::Vector{AdjudicatorPanel}, debateindices::Vector{Int}, panelindices::Vector{Int})
    map(debateindices, panelindices) do d, p
        debate = debates[d]
        panel = panels[p]
        chair = panel.adjs[1]
        panellists = panel.adjs[2:panel.np+1]
        trainees = panel.adjs[panel.np+2:end]
        PanelAllocation(debate, chair, panellists, trainees)
    end
end

function convertallocations2(debates::Vector{Debate}, panels::Vector{AdjudicatorPanel}, debateindices::Vector{Int}, panelindices::Vector{Int})
    map(debateindices, panelindices) do d, p
        debate = debates[d]
        panel = panels[p]
        PanelAllocation(debate, chair(panel), panellists(panel), trainees(panel))
    end
end

function convertallocations3(debates::Vector{Debate}, panels::Vector{AdjudicatorPanel}, debateindices::Vector{Int}, panelindices::Vector{Int})
    allocations = Array{PanelAllocation}(length(debateindices))
    for (i, (d, p)) in enumerate(zip(debateindices, panelindices))
        debate = debates[d]
        panel = panels[p]
        chair = panel.adjs[1]
        panellists = panel.adjs[2:panel.np+1]
        trainees = panel.adjs[panel.np+2:end]
        allocations[i] = PanelAllocation(debate, chair, panellists, trainees)
    end
    return allocations
end

function convertallocations4(debates::Vector{Debate}, panels::Vector{AdjudicatorPanel}, debateindices::Vector{Int}, panelindices::Vector{Int})
    allocations = Array{PanelAllocation}(length(debateindices))
    for (i, (d, p)) in enumerate(zip(debateindices, panelindices))
        debate = debates[d]
        panel = panels[p]
        allocations[i] = PanelAllocation(debate, chair(panel), panellists(panel), trainees(panel))
    end
    return allocations
end

function convertallocations5(debates::Vector{Debate}, panels::Vector{AdjudicatorPanel}, debateindices::Vector{Int}, panelindices::Vector{Int})
    allocateddebates = Debate[debates[d] for d in debateindices]
    allocatedpanels = AdjudicatorPanel[panels[p] for p in panelindices]
    chairs = [panel.adjs[1] for panel in allocatedpanels]
    panellists = [panel.adjs[2:panel.np+1] for panel in allocatedpanels]
    trainees = [panel.adjs[panel.np+2:end] for panel in allocatedpanels]
    [PanelAllocation(args...) for args in zip(allocateddebates, chairs, panellists, trainees)]
end

function equivalent(α::PanelAllocation, β::PanelAllocation)
    α.debate == β.debate && α.chair == β.chair && α.panellists == β.panellists && α.trainees == β.trainees
end

function equivalent(a::Vector{PanelAllocation}, b::Vector{PanelAllocation})
    all([equivalent(α, β) for (α, β) in zip(a, b)])
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
debateindices = shuffle(collect(1:ndebates))
panelindices = sample(1:length(feasiblepanels), ndebates; replace=false)

funcs = [
    convertallocations1,
    convertallocations2,
    convertallocations3,
    convertallocations4, # chosen
    convertallocations5,
]

A = [f(roundinfo.debates, feasiblepanels, debateindices, panelindices) for f in funcs]

for i = 1:5
    for f in shuffle(funcs)
        println("$f")
        @time [f(roundinfo.debates, feasiblepanels, debateindices, panelindices) for j in 1:10000]
    end
end

for (i, j) in combinations(1:length(funcs), 2)
    @show (funcs[i], funcs[j]) equivalent(A[i], A[j])
end
