
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

"""
Generates a list of feasible panels using the information about the round.
Returns a list of AdjudicatorPanel instances.
"""
function generatefeasiblepanels(roundinfo::RoundInfo, panelsizes::Vector{Int}; options...)
    optionsdict = Dict(options)

    adjssorted = sort(roundinfo.adjudicators, by=adj->adj.ranking, rev=true)
    averagepanelsize = count(x -> x.ranking >= PanellistMinus, roundinfo.adjudicators) / numdebates(roundinfo)
    panels = AdjudicatorPanel[]

    if isinteger(averagepanelsize)
        panelsizes = Int[averagepanelsize]
    else
        panelsizes = Int[floor(averagepanelsize), ceil(averagepanelsize)]
    end

    println("generatefeasiblepanels: The average panel size is $averagepanelsize, trying these panel sizes: $panelsizes.")

    methodoption = get(optionsdict, :fpgmethod, :exhaustive)
    println("generatefeasiblepanels: Feasible panel generation method is $methodoption")
    method = FEASIBLE_PANEL_GENERATION_METHODS[methodoption]
    panels = method(roundinfo, panelsizes; options...)

    println("generatefeasiblepanels: There are $(length(panels)) panels to choose from.")
end

function generatefeasiblepanelsrandom(roundinfo::RoundInfo, panelsizes::Vector{Int}; options...)
    panels = AdjudicatorPanel[]
    sizehint!(panels, limitpanels)
    # TODO select in proportion to averagepanelsize
    for panelsize in panelsizes
        for i in 1:limitpanels÷2
            adjs = sample(roundinfo.adjudicators, panelsize; replace=false)
            while !feasible(adjs)
                adjs = sample(roundinfo.adjudicators, panelsize; replace=false)
            end
            possiblechairindices = find(adj -> adj.ranking == adjs[1].ranking, adjs)
            chairindex = rand(possiblechairindices)
            chair = adjs[chairindex]
            deleteat!(adjs, chairindex)
            panel = AdjudicatorPanel(chair, adjs)
            push!(panels, panel)
        end
    end

    return panels
end

function generatefeasiblepanelspermutations(roundinfo::RoundInfo; options...)
    # panels = AdjudicatorPanel[]
    # sizehint!(panels, limitpanels)
    # while length(panels) < limitpanels
    #     # Try the permutations method here
    # end


    # Take a very brute force approach
    # CONTINUE HERE - TODO - don't generate exhaustive list.
    # Probably provide options for different methods, actually:
    #  - random, exhaustive and sample, permuations
end

function generatefeasiblepanelsexhaustive(roundinfo::RoundInfo, panelsizes::Vector{Int}; options...)

    panels = AdjudicatorPanel[]
    sizehint!(panels, binomial(numadjs(roundinfo), maximum(panelsizes)))
    lastprint = 0
    for panelsize in panelsizes
        for adjs in combinations(adjssorted, panelsize)
            if !feasible(roundinfo, adjs)
                continue
            end
            possiblechairindices = find(adj -> adj.ranking == adjs[1].ranking, adjs)
            chairindex = rand(possiblechairindices)
            chair = adjs[chairindex]
            deleteat!(adjs, chairindex)
            panel = AdjudicatorPanel(chair, adjs)
            push!(panels, panel)
            if length(panels) - lastprint >= 100000
                println("Up to $(length(panels)) panels")
                lastprint = length(panels)
            end
        end
    end

    limitpanels = get(optionsdict, :limitpanels, typemax(Int))
    if length(panels) > limitpanels
        println("There are $(length(panels)) feasible panels, but limiting to $limitpanels panels, picking at random.")
        panels = sample(panels, limitpanels; replace=false)
    end

    return panels
end

FEASIBLE_PANEL_GENERATION_METHODS = Dict(
    :exhaustive => generatefeasiblepanelsexhaustive,
    :random => generatefeasiblepanelsrandom,
    :permuations => generatefeasiblepanelspermutations,
)

