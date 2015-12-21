push!(LOAD_PATH, joinpath(Base.source_dir(), ".."))
using Adjumo
using StatsBase
import Adjumo: panelregionbreakdown, DebateRegionClass, RegionClassA, RegionClassB, RegionClassC, RegionClassD, RegionClassE

n = parse(Int, ARGS[1])

function generatetestregions()
    class = rand(DebateRegionClass[instances(DebateRegionClass)...])
    a, b, c, d = sample(Region[instances(Region)...], 4; replace=false)
    if class == RegionClassA
        regions = [a, a, a, a]
    elseif class == RegionClassB
        regions = [a, a, a, b]
    elseif class == RegionClassC
        regions = [a, a, b, b]
    elseif class == RegionClassD
        regions = [a, a, b, c]
    elseif class == RegionClassE
        regions = [a, b, c, d]
    end
    shuffle!(regions)
    return regions
end

inst = Institution(1, "Institution")
function generatepanel()
    nadjs = rand(2:4)
    adjs = Vector{Adjudicator}(nadjs)
    for i = 1:nadjs
        regions = Region[rand(Region[instances(Region)...])]
        while rand() < 0.1
            push!(regions, rand(Region[instances(Region)...]))
        end
        adjs[i] = Adjudicator(i, "Adjudicator $i", inst, Panellist, regions, PersonNoGender, NoLanguage)
    end
    return AdjudicatorPanel(adjs, nadjs-1)
end

for i = 1:n
    teamregions = generatetestregions()
    @show teamregions
    panel = generatepanel()
    adjregions = [adj.regions for adj in adjlist(panel)]
    @show adjregions
    @show panelregionbreakdown(teamregions, panel)
end
