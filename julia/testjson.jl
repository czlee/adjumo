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

adjudicatorsfile = open("../adjumo-frontend/public/data/adjudicators.json", "w")
exportjsonadjudicators(roundinfo, adjudicatorsfile)
close(adjudicatorsfile)

teamsfile = open("../adjumo-frontend/public/data/teams.json", "w")
exportjsonteams(roundinfo, teamsfile)
close(teamsfile)

institutionsfile = open("../adjumo-frontend/public/data/institutions.json", "w")
exportjsoninstitutions(roundinfo, institutionsfile)
close(institutionsfile)

debatesfile = open("../adjumo-frontend/public/data/debates.json", "w")
exportjsondebates(roundinfo, debatesfile)
close(debatesfile)


