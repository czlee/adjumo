include("main.jl")
include("random.jl")

s = ArgParseSettings()
@add_arg_table s begin
    "-n", "--ndebates"
        help = "Number of debates in round"
        arg_type = Int
        default = 5
    "-r", "--currentround"
        help = "Current round number"
        arg_type = Int
        default = 5
    "--solver"
        help = "Solver to use ('gurobi', 'cbc' or 'glpk')"
        default = nothing
    "--profile"
        help = "Print profiling information"
        action = :store_true
    "--score-only"
        help = "Stop after computing score matrix"
        action = :store_true
end
args = parse_args(ARGS, s)

SOLVERS = Dict("gurobi" => "Gurobi", "cbc" => "Cbc", "glpk" => "GLPKMathProgInterface")
for (argvalue, package) in SOLVERS
    if args["solver"] == argvalue || (args["solver"] == nothing && Pkg.installed(package) != nothing)
        println("Using solver: $package")
        eval(parse("using " * package))
        break
    end
end

ndebates = args["ndebates"]
currentround = args["currentround"]
componentweights = AdjumoComponentWeights()
componentweights.quality = 1
componentweights.regional = 0.01
componentweights.language = 1
componentweights.gender = 1
componentweights.teamhistory = 100
componentweights.adjhistory = 100
componentweights.teamconflict = 1e6
componentweights.adjconflict = 1e6
@time roundinfo = randomroundinfo(ndebates, currentround)
roundinfo.componentweights = componentweights

debateindices, panels = allocateadjudicators(roundinfo; profile=args["profile"], scoreonly=args["score-only"])

if !args["score-only"]
    showconstraints(roundinfo)
    for (d, panel) in zip(debateindices, panels)
        showdebatedetail(roundinfo, d, panel)
    end
end

if args["profile"]
    Profile.print()
    Profile.print(format=:flat, sortedby=:count)
end
