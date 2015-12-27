# Trial Tabbie2 data import into a RoundInfo.

push!(LOAD_PATH, Base.source_dir())
using Adjumo
using AdjumoDataTools
using ArgParse
using Iterators

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
# showteams(rinfo)
# showadjudicators(rinfo)
exportroundinfo(rinfo, args["dir"])

averagepanelsize = numadjs(rinfo) / numdebates(rinfo)
smallersize = Int(floor(averagepanelsize))
biggersize = Int(ceil(averagepanelsize))
numbigger = numadjs(rinfo) - Int(smallersize) * numdebates(rinfo)
numsmaller = numdebates(rinfo) - numbigger

allocations = PanelAllocation[]

shuffledadjs = shuffle(rinfo.adjudicators)
for (debate, adjs) in zip(rinfo.debates[1:numsmaller], partition(shuffledadjs[1:smallersize*numsmaller], smallersize))
    panel = PanelAllocation(debate, rand()*400, adjs[1], [adjs[2:end]...], [])
    push!(allocations, panel)
end
for (debate, adjs) in zip(rinfo.debates[numsmaller+1:end], partition(shuffledadjs[smallersize*numsmaller+1:end], biggersize))
    panel = PanelAllocation(debate, rand()*400, adjs[1], [adjs[2:end-1]...], [adjs[end]])
    push!(allocations, panel)
end

exportallocations(allocations, args["dir"])
exporttabbiejson(allocations, args["dir"])
