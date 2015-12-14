# Performance profiling for trainee constraints

push!(LOAD_PATH, joinpath(Base.source_dir(), ".."))
using ArgParse
using Adjumo
import Adjumo: historyscore, conflictsscore
include("../random.jl")

traineeindices1(adjs::Vector{Adjudicator}) = [adj.ranking <= TraineePlus for adj in adjs]
traineeindices2(adjs::Vector{Adjudicator}) = map(x -> x.ranking <= TraineePlus, adjs)
traineeindices3(adjs::Vector{Adjudicator}) = find(x -> x.ranking <= TraineePlus, adjs)

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

funcs = [
    traineeindices1;
    traineeindices2;
    traineeindices3;
]

A = [f(roundinfo.adjudicators) for f in funcs]
A = A[1:2]

for i = 1:5
    for f in shuffle(funcs)
        println(f)
        @time [f(roundinfo.adjudicators) for j = 1:10000]
    end
end

for (i, a) in enumerate(A)
    @show funcs[i] sumabs(A[i])
end
for (i, j) in combinations(1:length(A), 2)
    @show (funcs[i], funcs[j]) sumabs(A[i] - A[j])
end
