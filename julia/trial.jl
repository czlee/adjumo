push!(LOAD_PATH, Base.source_dir())
using ArgParse
using Adjumo
using JsonAPI

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
    "--enforce-team-conflicts"
        help = "Enforce team-adjudicator conflicts (as opposed to just penalize)"
        action = :store_true
    "--json-dir"
        help = "Where to write JSON files upon completion."
        default = "../adjumo-frontend/public/data"
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

allocations = allocateadjudicators(roundinfo; solver=args["solver"], enforceteamconflicts=args["enforce-team-conflicts"])

println("Writing JSON files...")
directory = args["json-dir"]
standard_fields = [
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

for field in standard_fields
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

filename = joinpath(directory, "panelallocations.json")
println("Creating $filename")
f = open(filename, "w")
printjsonapi(f, allocations)
close(f)

showconstraints(roundinfo)
for allocation in allocations
    showdebatedetail(roundinfo, allocation)
end