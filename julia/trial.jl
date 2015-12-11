push!(LOAD_PATH, Base.source_dir())
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
    "--solver"
        help = "Solver to use ('gurobi', 'cbc' or 'glpk')"
        default = "default"
        range_tester = x -> x ∈ ["default", "gurobi", "cbc", "glpk"]
end
args = parse_args(ARGS, argsettings)

ndebates = args["ndebates"]
currentround = args["currentround"]
componentweights = AdjumoComponentWeights()
componentweights.panelsize = 10
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

debateindices, panels = allocateadjudicators(roundinfo; solver=args["solver"])

showconstraints(roundinfo)
for (d, panel) in zip(debateindices, panels)
    showdebatedetail(roundinfo, d, panel)
end
