
function feasible(roundinfo, adjs)
    if panelquality(adjs) <= -20
        return false
    end
    if hasconflict(roundinfo, adjs)
        return false
    end
    for groupedadjs in roundinfo.groupedadjs
        overlap = length(adjs ∩ groupedadjs)
        if overlap != 0 && overlap != length(groupedadjs)
            return false
        end
    end
    return true
end

function makepanelwithrandomchair(adjs::Vector{Adjudicator})
    maxranking = maximum([adj.ranking for adj in adjs])
    possiblechairindices = find(adj -> adj.ranking == maxranking, adjs)
    chairindex = rand(possiblechairindices)
    chair = adjs[chairindex]
    deleteat!(adjs, chairindex)
    return AdjudicatorPanel(chair, adjs)
end

"""
Generates a list of feasible panels using the information about the round.
Returns a list of AdjudicatorPanel instances.
"""
function generatefeasiblepanels(roundinfo::RoundInfo; options...)

    averagepanelsize = count(x -> x.ranking >= PanellistMinus, roundinfo.adjudicators) / numdebates(roundinfo)
    panels = AdjudicatorPanel[]

    if isinteger(averagepanelsize)
        panelsizes = [(Int(averagepanelsize), 1.0)]
    else
        proportionbigger = mod(averagepanelsize, 1.0)
        panelsizes = [(ceil(Int, averagepanelsize),  proportionbigger),
                      (floor(Int, averagepanelsize), 1 - proportionbigger)]
    end

    println("generatefeasiblepanels: The average panel size is $averagepanelsize.")
    println("generatefeasiblepanels: Panel sizes and proportions: $panelsizes.")

    methodoption = get(Dict(options), :fpgmethod, :exhaustive)
    println("generatefeasiblepanels: Feasible panel generation method is $methodoption")
    method = FEASIBLE_PANEL_GENERATION_METHODS[methodoption]
    panels = method(roundinfo, panelsizes; options...)

    println("generatefeasiblepanels: There are $(length(panels)) panels to choose from.")
    return panels
end

function generatefeasiblepanelsrandom(roundinfo::RoundInfo, panelsizes::Vector{Tuple{Int,Float64}}; options...)

    nfeasiblepanels = get(Dict(options), :nfeasiblepanels, -1)
    if nfeasiblepanels == -1
        nfeasiblepanels = 10000
    end

    panels = AdjudicatorPanel[]
    sizehint!(panels, nfeasiblepanels)

    for (panelsize, proportion) in panelsizes
        npanelsforthissize = round(Int, nfeasiblepanels * proportion)
        println("generatefeasiblepanelsrandom: Generating $npanelsforthissize panels of size $panelsize at random")
        for i in 1:npanelsforthissize
            adjs = sample(roundinfo.adjudicators, panelsize; replace=false)
            while !feasible(roundinfo, adjs)
                adjs = sample(roundinfo.adjudicators, panelsize; replace=false)
            end
            panel = makepanelwithrandomchair(adjs)
            push!(panels, panel)
        end
    end

    return panels
end

function generatefeasiblepanelspermutations(roundinfo::RoundInfo, panelsizes::Vector{Tuple{Int,Float64}}; options...)

    testeesids = [2411, 2503, 2588, 2449, 2593, 2787, 2825, 2533, 2786, 2520, 2826, 2552, 2499, 2509, 2595, 2472, 2494, 2544, 2827, 2508, 2594, 2470, 2587, 2493, 2536, 2404, 2504, 2487, 2534, 2796]
    testees = Adjudicator[getobjectwithid(roundinfo.adjudicators, id) for id in testeesids]
    filter!(adj -> adj.ranking != ChairPlus, testees)
    println("Testees:")
    for testee in testees
        println(" $(testee.name), $(testee.institution.name), $(testee.ranking)")
    end

    nfeasiblepanels = get(Dict(options), :nfeasiblepanels, -1)
    if nfeasiblepanels == -1
        nfeasiblepanels = 10000
    end
    accreditedadjs = filter(adj -> adj.ranking >= TraineePlus, roundinfo.adjudicators)
    nadjs = length(accreditedadjs)

    allpanels = AdjudicatorPanel[]
    sizehint!(allpanels, nfeasiblepanels)

    for (panelsize, proportion) in panelsizes
        npanelsforthissize = round(Int, proportion * nfeasiblepanels)
        panels = AdjudicatorPanel[]
        sizehint!(panels, npanelsforthissize)
        println("generatefeasiblepanelspermutations: Generating $npanelsforthissize panels of size $panelsize by permutation")
        while length(panels) < npanelsforthissize
            shuffledadjs = shuffle(accreditedadjs)
            runpanels = AdjudicatorPanel[]
            sizehint!(panels, nadjs)
            for j in 1:nadjs-panelsize+1
                adjs = shuffledadjs[j:j+panelsize-1]
                if !feasible(roundinfo, adjs)
                    continue
                end
                remove = false
                for adj in adjs
                    if adj in testees
                        remove = true
                    end
                end
                if remove
                    continue
                end
                push!(runpanels, makepanelwithrandomchair(adjs))
            end
            for j in 1:panelsize-1
                adjs = [shuffledadjs[end-panelsize+1+j:end]; shuffledadjs[1:j]]
                if !feasible(roundinfo, adjs)
                    continue
                end
                remove = false
                for adj in adjs
                    if adj in testees
                        remove = true
                    end
                end
                if remove
                    continue
                end
                push!(runpanels, makepanelwithrandomchair(adjs))
            end
            append!(panels, runpanels)
        end
        println("generatefeasiblepanelspermutations: There are $(length(panels)) panels of size $panelsize")
        append!(allpanels, panels)
    end

    # panellistjudges = filter(adj -> adj.ranking >= PanellistMinus, roundinfo.adjudicators)
    # for group in roundinfo.groupedadjs
    #     println("Special panels for")
    #     @show group
    #     runpanels = AdjudicatorPanel[]
    #     for i = 1:200
    #         panellist = rand(panellistjudges)
    #         if panellist in group
    #             continue
    #         end
    #         adjs = [group; panellist]
    #         if conflicted(roundinfo, adjs[1], adjs[2])
    #             println("Conflict!")
    #             break
    #         end
    #         if feasible(roundinfo, adjs)
    #             push!(runpanels, makepanelwithrandomchair(adjs))
    #         end
    #     end
    #     @show length(runpanels)
    #     append!(allpanels, runpanels)
    # end

    return allpanels
end

function generatefeasiblepanelsexhaustive(roundinfo::RoundInfo, panelsizes::Vector{Tuple{Int,Float64}}; options...)

    nfeasiblepanels = get(Dict(options), :nfeasiblepanels, typemax(Int))
    adjssorted = sort(roundinfo.adjudicators, by=adj->adj.ranking, rev=true)

    allpanels = AdjudicatorPanel[]
    lastprint = 0
    for (panelsize, proportion) in panelsizes
        estimatednpanels = binomial(numadjs(roundinfo), panelsize)
        println("generatefeasiblepanelsexhaustive: Estimated number of panels of size $panelsize: $(numadjs(roundinfo)) choose $panelsize makes $estimatednpanels")
        panels = AdjudicatorPanel[]
        sizehint!(panels, estimatednpanels)
        for adjs in combinations(adjssorted, panelsize)
            if !feasible(roundinfo, adjs)
                continue
            end
            panel = makepanelwithrandomchair(adjs)
            push!(panels, panel)
            if length(panels) - lastprint >= 100000
                println("generatefeasiblepanelsexhaustive: Up to $(length(panels)) panels")
                lastprint = length(panels)
            end
        end

        if nfeasiblepanels != -1
            npanelsforthissize = round(Int, nfeasiblepanels * proportion)
            if length(panels) > npanelsforthissize
                println("generatefeasiblepanelsexhaustive: There are $(length(panels)) feasible panels of size $panelsize, but limiting to $npanelsforthissize panels, picking at random")
                panels = sample(panels, npanelsforthissize; replace=false)
            end
        else
                println("generatefeasiblepanelsexhaustive: There are $(length(panels)) feasible panels of size $panelsize")
        end

        append!(allpanels, panels)
    end

    return allpanels
end

function generatefeasiblepanelstesters(roundinfo::RoundInfo, panelsizes::Vector{Tuple{Int,Float64}}; options...)

    testerids = []
    testeesids = Dict{Int,Vector{Int}}(
        7 => [],
        8 => [],
        9 => [],
    )
    testgroups = []
    panelids = []
    for testerid in testerids, testeeid in testeesids

    end


end

FEASIBLE_PANEL_GENERATION_METHODS = Dict(
    :exhaustive => generatefeasiblepanelsexhaustive,
    :random => generatefeasiblepanelsrandom,
    :permutations => generatefeasiblepanelspermutations,
)

