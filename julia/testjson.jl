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

directory = "../adjumo-frontend/public/data"
mkpath(directory)

adjudicatorsfile = open(joinpath(directory, "adjudicators.json"), "w")
exportjsonadjudicators(adjudicatorsfile, roundinfo)
close(adjudicatorsfile)

teamsfile = open(joinpath(directory, "teams.json"), "w")
exportjsonteams(teamsfile, roundinfo)
close(teamsfile)

institutionsfile = open(joinpath(directory, "institutions.json"), "w")
exportjsoninstitutions(institutionsfile, roundinfo)
close(institutionsfile)

debatesfile = open(joinpath(directory, "debates.json"), "w")
exportjsondebates(debatesfile, roundinfo)
close(debatesfile)


