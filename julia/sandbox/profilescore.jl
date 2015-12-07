# Performance profiling of score matrix function

push!(LOAD_PATH, "..")
using ArgParse
using Adjumo
include("random.jl")

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

@time feasiblepanels = generatefeasiblepanels(roundinfo)

# once to compile
println("once:")
@time scorematrix(feasiblepanels, roundinfo)

println("twice:")
@time Σ = scorematrix(feasiblepanels, roundinfo)
@profile scorematrix(feasiblepanels, roundinfo)

Profile.print(maxdepth=5)
Profile.print(format=:flat, sortedby=:count)
