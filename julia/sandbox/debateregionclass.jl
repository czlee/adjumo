# Performance profiling for debateregionclass

push!(LOAD_PATH, joinpath(Base.source_dir(), ".."))
using Adjumo
using DataStructures
import Adjumo: DebateRegionClass, RegionClassA, RegionClassB, RegionClassC, RegionClassD, RegionClassE

function equivalent(a::Tuple{DebateRegionClass,Vector{Region}}, b::Tuple{DebateRegionClass,Vector{Region}})
    aclass, aregions = a
    bclass, bregions = b
    if aclass != bclass
        return false
    end
    if aclass == RegionClassA || aclass == RegionClassB
        return aregions == bregions
    elseif aclass == RegionClassC || aclass == RegionClassE
        return Set(aregions) == Set(bregions)
    else
        if aregions[1] != bregions[1]
            return false
        end
        return Set(aregions[2:3]) == Set(bregions[2:3])
    end
end

function debateregionclass1(teamregions::Vector{Region})
    assert(length(teamregions) == 4)
    # TODO the next two lines are very heavy, find a way to reduce
    regioncounts = collect(Pair{Region,Int64}, counter(teamregions))
    sort!(regioncounts, by=x->x.second, rev=true) # e.g. [NorthAsia=>3, Oceania=>1]
    regions = [x.first for x in regioncounts]     # e.g. [NorthAsia, Oceania]
    counts = [x.second for x in regioncounts]     # e.g. [3, 1]
    if counts == [4]
        return RegionClassA, regions
    elseif counts == [3, 1]
        return RegionClassB, regions
    elseif counts == [2, 2]
        return RegionClassC, regions
    elseif counts == [2, 1, 1]
        return RegionClassD, regions
    elseif counts == [1, 1, 1, 1]
        return RegionClassE, regions
    else
        throw(ArgumentError("Region counts were invalid: $counts"))
    end
end

function debateregionclass2(teamregions::Vector{Region})
    assert(length(teamregions) == 4)
    regioncounts = Pair{Region,Int}[]
    for region in teamregions
        index = findfirst(x -> x.first == region, regioncounts)
        if index == 0
            push!(regioncounts, region=>1)
        else
            regioncounts[index] = region=>regioncounts[index].second+1
        end
    end
    sort!(regioncounts, by=x->x.second, rev=true) # e.g. [NorthAsia=>3, Oceania=>1]
    regions = [x.first for x in regioncounts]     # e.g. [NorthAsia, Oceania]
    counts = [x.second for x in regioncounts]     # e.g. [3, 1]
    if counts == [4]
        return RegionClassA, regions
    elseif counts == [3, 1]
        return RegionClassB, regions
    elseif counts == [2, 2]
        return RegionClassC, regions
    elseif counts == [2, 1, 1]
        return RegionClassD, regions
    elseif counts == [1, 1, 1, 1]
        return RegionClassE, regions
    else
        throw(ArgumentError("Region counts were invalid: $counts"))
    end
end

function debateregionclass3(teamregions::Vector{Region})
    assert(length(teamregions) == 4)
    regioncounts = [Region[] for i in 1:4]
    for region in teamregions
        index = findfirst(regionsatcount -> region ∈ regionsatcount, regioncounts)
        if index > 0
            deleteat!(regioncounts[index], findfirst(regioncounts[index], region))
        end
        push!(regioncounts[index+1], region)
    end
    reverse!(regioncounts)
    regions = vcat(regioncounts...)
    counts = [length(regionsatcount) for regionsatcount in regioncounts]
    if counts == [1, 0, 0, 0]
        return RegionClassA, regions
    elseif counts == [0, 1, 0, 1]
        return RegionClassB, regions
    elseif counts == [0, 0, 2, 0]
        return RegionClassC, regions
    elseif counts == [0, 0, 1, 2]
        return RegionClassD, regions
    elseif counts == [0, 0, 0, 4]
        return RegionClassE, regions
    else
        throw(ArgumentError("Region counts were invalid: $counts"))
    end
end

function debateregionclass4(teamregions::Vector{Region})
    assert(length(teamregions) == 4)
    regioncounts = [Region[] for i in 1:4]
    for region in teamregions
        index = 0
        for i in 1:3
            if region ∈ regioncounts[i]
                index = i
                break
            end
        end
        if index > 0
            deleteat!(regioncounts[index], findfirst(regioncounts[index], region))
        end
        push!(regioncounts[index+1], region)
    end
    reverse!(regioncounts)
    regions = vcat(regioncounts...)
    counts = [length(regionsatcount) for regionsatcount in regioncounts]
    if counts == [1, 0, 0, 0]
        return RegionClassA, regions
    elseif counts == [0, 1, 0, 1]
        return RegionClassB, regions
    elseif counts == [0, 0, 2, 0]
        return RegionClassC, regions
    elseif counts == [0, 0, 1, 2]
        return RegionClassD, regions
    elseif counts == [0, 0, 0, 4]
        return RegionClassE, regions
    else
        throw(ArgumentError("Region counts were invalid: $counts"))
    end
end

function debateregionclass5(teamregions::Vector{Region})
    assert(length(teamregions) == 4)
    regioncounts = [Region[] for i in 1:4]
    regionindex = 0
    for region in teamregions
        index = 0
        for i in 1:3, j in 1:length(regioncounts[i])
            if region == regioncounts[i][j]
                index = i
                regionindex = j
                break
            end
        end
        if index > 0
            deleteat!(regioncounts[index], regionindex)
        end
        push!(regioncounts[index+1], region)
    end
    reverse!(regioncounts)
    regions = vcat(regioncounts...)
    counts = [length(regionsatcount) for regionsatcount in regioncounts]
    if counts == [1, 0, 0, 0]
        return RegionClassA, regions
    elseif counts == [0, 1, 0, 1]
        return RegionClassB, regions
    elseif counts == [0, 0, 2, 0]
        return RegionClassC, regions
    elseif counts == [0, 0, 1, 2]
        return RegionClassD, regions
    elseif counts == [0, 0, 0, 4]
        return RegionClassE, regions
    else
        throw(ArgumentError("Region counts were invalid: $counts"))
    end
end

function debateregionclass6(teamregions::Vector{Region})
    assert(length(teamregions) == 4)
    regioncounts = Vector{Pair{Region,Int}}(4)
    nregions = 0
    for region in teamregions
        index = 0
        for i = 1:nregions
            if region == regioncounts[i].first
                index = i
                break
            end
        end
        if index == 0
            nregions += 1
            regioncounts[nregions] = region=>1
        else
            regioncounts[index] = region=>regioncounts[index].second+1
        end
    end
    deleteat!(regioncounts, nregions+1:4)
    regions = Vector{Region}(nregions)
    counts = Vector{Int}(nregions)
    j = 1
    for i = 4:-1:1, regioncount in regioncounts
        if regioncount.second == i
            regions[j] = regioncount.first
            counts[j] = regioncount.second
            j += 1
        end
    end
    if counts == [4]
        return RegionClassA, regions
    elseif counts == [3, 1]
        return RegionClassB, regions
    elseif counts == [2, 2]
        return RegionClassC, regions
    elseif counts == [2, 1, 1]
        return RegionClassD, regions
    elseif counts == [1, 1, 1, 1]
        return RegionClassE, regions
    else
        throw(ArgumentError("Region counts were invalid: $counts"))
    end
end

function debateregionclass7(teamregions::Vector{Region})
    assert(length(teamregions) == 4)
    regioncounts = Vector{Pair{Region,Int}}(4)
    nregions = 0
    for region in teamregions
        index = 0
        for i = 1:nregions
            if region == regioncounts[i].first
                index = i
                break
            end
        end
        if index == 0
            nregions += 1
            regioncounts[nregions] = region=>1
        else
            regioncounts[index] = region=>regioncounts[index].second+1
        end
    end
    deleteat!(regioncounts, nregions+1:4)
    regions = Vector{Region}(nregions)
    counts = [rc.second for rc in regioncounts]
    maxcount = maximum(counts)
    j = 1
    for i = 4:-1:1, regioncount in regioncounts
        if regioncount.second == i
            regions[j] = regioncount.first
            j += 1
        end
    end
    if maxcount == 4
        return RegionClassA, regions
    elseif maxcount == 3
        return RegionClassB, regions
    elseif maxcount == 1
        return RegionClassE, regions
    elseif length(counts) == 2
        return RegionClassC, regions
    else
        return RegionClassD, regions
    end
end

using StatsBase
function generatetestregions(n::Int)
    classes = rand(DebateRegionClass[instances(DebateRegionClass)...], n)
    @show counter(classes)
    regions = Vector{Vector{Region}}(n)
    for (i, class) in enumerate(classes)
        a, b, c, d = sample(Region[instances(Region)...], 4; replace=false)
        if class == RegionClassA
            regions[i] = [a, a, a, a]
        elseif class == RegionClassB
            regions[i] = [a, a, a, b]
        elseif class == RegionClassC
            regions[i] = [a, a, b, b]
        elseif class == RegionClassD
            regions[i] = [a, a, b, c]
        elseif class == RegionClassE
            regions[i] = [a, b, c, d]
        end
        shuffle!(regions[i])
    end
    return regions
end


testdata = generatetestregions(500000)

funcs = [
    debateregionclass1;
    # debateregionclass2;
    # debateregionclass3;
    # debateregionclass4;
    # debateregionclass5;
    # debateregionclass6;
    debateregionclass7;
]

for i = 1:5
    for f in shuffle(funcs)
        println(f)
        @time [f(regions) for regions in testdata]
    end
end

A = [[f(regions) for regions in testdata] for f in funcs]
for (i, j) in combinations(1:length(funcs), 2)
    @show (i, j) all([equivalent(a, b) for (a, b) in zip(A[i], A[j])])
end