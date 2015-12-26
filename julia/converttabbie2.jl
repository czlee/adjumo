# Trial Tabbie2 data import into a RoundInfo.

push!(LOAD_PATH, Base.source_dir())
using Adjumo
using AdjumoDataTools
using ArgParse

argsettings = ArgParseSettings()
@add_arg_table argsettings begin
    "filename"
        help = "File name"
        required = true
    "--dir"
        help = "Output directory"
        default = "tabbie2data"
end
args = parse_args(ARGS, argsettings)
f = open(args["filename"])
rinfo = importtabbiejson(f)
showteams(rinfo)
showadjudicators(rinfo)
exportroundinfo(rinfo, args["dir"])