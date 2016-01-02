
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

    # if isinteger(averagepanelsize)
    #     panelsizes = [(Int(averagepanelsize), 1.0)]
    # else
    #     proportionbigger = mod(averagepanelsize, 1.0)
    #     panelsizes = [(ceil(Int, averagepanelsize),  proportionbigger),
    #                   (floor(Int, averagepanelsize), 1 - proportionbigger)]
    # end
    # HACK for outrounds
    panelsizes = [(5, 0.8), (7, 0.2)]

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


    # HACK: Hard-code testee ids because it's easier and we didn't have much time
    # # round 7
    # testeesids = [2411, 2503, 2588, 2449, 2593, 2787, 2825, 2533, 2786, 2520, 2826, 2552, 2499, 2509, 2595, 2472, 2494, 2544, 2827, 2508, 2594, 2470, 2587, 2493, 2536, 2404, 2504, 2487, 2534, 2796]

    # # round 9
    # testeesids = [2758, 2764, 2766, 2769, 2770, 2777, 2785, 2801, 2803, 2809, 2815, 2820, 2836, 2845, 2855]

    # # round 8
    # testeesids = [2650, 2644, 2510, 2584, 2632, 2669, 2582, 2577, 2690, 2697, 2641, 2702, 2730, 2704, 2716]

    # testees = Adjudicator[getobjectwithid(roundinfo.adjudicators, id) for id in testeesids]
    # filter!(adj -> adj.ranking != ChairPlus, testees)
    # println("Testees:")
    # for testee in testees
    #     println(" $(testee.name), $(testee.institution.name), $(testee.ranking)")
    # end

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
                # HACK: Commented out for outrounds (first set)
                # if !feasible(roundinfo, adjs)
                    # continue
                # end
                #
                # HACK: Additional part to prevent testees from being allocated
                # remove = false
                # for adj in adjs
                #     if adj in testees
                #         remove = true
                #     end
                # end
                # if remove
                #     continue
                # end
                push!(runpanels, makepanelwithrandomchair(adjs))
            end
            for j in 1:panelsize-1
                adjs = [shuffledadjs[end-panelsize+1+j:end]; shuffledadjs[1:j]]
                # HACK: Commented out for outrounds (first set)
                # if !feasible(roundinfo, adjs)
                    # continue
                # end
                #
                # HACK: Additional part to prevent testees from being allocated
                # remove = false
                # for adj in adjs
                #     if adj in testees
                #         remove = true
                #     end
                # end
                # if remove
                #     continue
                # end
                push!(runpanels, makepanelwithrandomchair(adjs))
            end
            append!(panels, runpanels)
        end
        println("generatefeasiblepanelspermutations: There are $(length(panels)) panels of size $panelsize")
        append!(allpanels, panels)
    end

    # HACK: This grouped adjudicators idea didn't work, it seemed to make the
    # problem infeasible. Not sure why.
    #
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

function generatefeasiblepanelsoutrounds(roundinfo::RoundInfo, panelsizes::Vector{Tuple{Int,Float64}}; options...)

    nfeasiblepanels = get(Dict(options), :nfeasiblepanels, typemax(Int))
    compositions = [
    #    C+ C  C-
        (1, 1, 3),
        (3, 4, 0),
    ]

    # activeadjids = []
    # activeadjudicators = filter(adj -> adj.id ∈ activeadjids, roundinfo.adjudicators)
    activeadjudicators = roundinfo.adjudicators
    plusadjs  = filter(adj -> adj.ranking == ChairPlus, activeadjudicators)
    zeroadjs  = filter(adj -> adj.ranking == Chair, activeadjudicators)
    minusadjs = filter(adj -> adj.ranking == ChairMinus, activeadjudicators)
    ntotalplusadjs = length(plusadjs)
    ntotalzeroadjs = length(zeroadjs)
    ntotalminusadjs = length(minusadjs)

    allpanels = AdjudicatorPanel[]

    for ((panelsize, proportion), (nplus, nzero, nminus)) in zip(panelsizes, compositions)

        panels = AdjudicatorPanel[]

        # Print estimates of how many there are
        npluscombs = binomial(ntotalplusadjs, nplus)
        nzerocombs = binomial(ntotalzeroadjs, nzero)
        nminuscombs = binomial(ntotalminusadjs, nminus)
        println("generatefeasiblepaneloutrounds: $npluscombs C+ combinations ($ntotalplusadjs choose $nplus)")
        println("generatefeasiblepaneloutrounds: $nzerocombs C  combinations ($ntotalzeroadjs choose $nzero)")
        println("generatefeasiblepaneloutrounds: $nminuscombs C- combinations ($ntotalminusadjs choose $nminus)")

        for pluscomb in combinations(plusadjs, nplus),
                zerocomb in combinations(zeroadjs, nzero),
                minuscomb in combinations(minusadjs, nminus)
            adjs = [pluscomb; zerocomb; minuscomb]
            panel = makepanelwithrandomchair(adjs)
            push!(panels, panel)
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

FEASIBLE_PANEL_GENERATION_METHODS = Dict(
    :exhaustive => generatefeasiblepanelsexhaustive,
    :random => generatefeasiblepanelsrandom,
    :permutations => generatefeasiblepanelspermutations,
    :outrounds => generatefeasiblepanelsoutrounds,
)

