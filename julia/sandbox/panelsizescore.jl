push!(LOAD_PATH, joinpath(Base.source_dir(), ".."))
using ArgParse
using Adjumo
using JuMP
include("../random.jl")

panelsizescore1(panel::AdjudicatorPanel) = [10,10,0,3][numadjs(panel)]
function panelsizescore2(panel::AdjudicatorPanel)
    nadjs = numadjs(panel)
    if nadjs == 3
        return 0
    elseif nadjs < 3
        return 10
    else
        return 3
    end
end
function panelsizescore3(nadjs::Int)
    if nadjs == 3
        return 0
    elseif nadjs < 3
        return 10
    else
        return 3
    end
end
panelsizescore4(nadjs::Int) = [10,10,0,3][nadjs]

panelsizevector1(panels::Vector{AdjudicatorPanel}) = map(panelsizescore1, panels)
panelsizevector2(panels::Vector{AdjudicatorPanel}) = map(panelsizescore2, panels)

function panelsizevector3(panels::Vector{AdjudicatorPanel})
    panelsizes = map(numadjs, panels)
    return [[10,10,0,3][s] for s in panelsizes]
end
function panelsizevector4(panels::Vector{AdjudicatorPanel})
    panelsizes = map(numadjs, panels)
    return [panelsizescore3(s) for s in panelsizes]
end
function panelsizevector5(panels::Vector{AdjudicatorPanel})
    panelsizes = map(numadjs, panels)
    return map(panelsizescore3, panelsizes)
end
panelsizevector6(panels::Vector{AdjudicatorPanel}) = map(panelsizescore3, map(numadjs, panels))
function panelsizevector7(panels::Vector{AdjudicatorPanel})
    panelsizes = map(numadjs, panels)
    return map(panelsizescore4, panelsizes)
end
panelsizevector8(panels::Vector{AdjudicatorPanel}) = map(panelsizescore4, map(numadjs, panels))

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
    panelsizevector1;
    panelsizevector2;
    panelsizevector3;
    panelsizevector4;
    panelsizevector5;
    panelsizevector6;
    panelsizevector7;
    panelsizevector8;
]

A = [f(feasiblepanels) for f in funcs]

for i = 1:5
    for f in shuffle(funcs)
        println(f)
        @time for j = 1:20
            f(feasiblepanels)
        end
    end
end

for (i, j) in combinations(1:length(funcs), 2)
    @show (funcs[i], funcs[j]) (A[i] == A[j])
end
