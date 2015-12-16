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

fields = [
    :adjudicators,
    :teams,
    :institutions,
    :debates,
    :adjadjconflicts,
    :teamadjconflicts,
    :lockedadjs,
    :blockedadjs,
    :componentweights,
]

for field in fields
    filename = joinpath(directory, string(field)*".json")
    println("Creating $filename")
    f = open(filename, "w")
    exportjson(f, roundinfo, field)
    close(f)
end

special_fields = [
    "adjadjhistory",
    "teamadjhistory",
    "groupedadjs"
]

for field in special_fields
    filename = joinpath(directory, field*".json")
    println("Creating $filename")
    f = open(filename, "w")
    func = eval(symbol("exportjson"*field))
    func(f, roundinfo)
    close(f)
end
