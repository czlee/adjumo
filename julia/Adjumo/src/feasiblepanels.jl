"""
Generates a list of feasible panels using the information about the round.
Returns a list of AdjudicatorPanel instances.
"""
function generatefeasiblepanels(roundinfo::RoundInfo; limitpanels::Int=typemax(Int))
    adjssorted = sort(roundinfo.adjudicators, by=adj->adj.ranking, rev=true)
    averagepanelsize = count(x -> x.ranking >= PanellistMinus, roundinfo.adjudicators) / numdebates(roundinfo)
    panels = AdjudicatorPanel[]

    if isinteger(averagepanelsize)
        panelsizes = Int[averagepanelsize]
    else
        panelsizes = Int[floor(averagepanelsize), ceil(averagepanelsize)]
    end
    println("The average panel size is $averagepanelsize, trying $panelsizes.")

    function feasible(adjs)
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

    panels = AdjudicatorPanel[]
    sizehint!(panels, limitpanels)
    while length(panels) < limitpanels
        # Try the permutations method here
    end

    # panels = AdjudicatorPanel[]
    # sizehint!(panels, limitpanels)
    # # TODO select in proportion to averagepanelsize
    # for panelsize in panelsizes
    #     for i in 1:limitpanels÷2
    #         adjs = sample(roundinfo.adjudicators, panelsize; replace=false)
    #         while !feasible(adjs)
    #             adjs = sample(roundinfo.adjudicators, panelsize; replace=false)
    #         end
    #         possiblechairindices = find(adj -> adj.ranking == adjs[1].ranking, adjs)
    #         chairindex = rand(possiblechairindices)
    #         chair = adjs[chairindex]
    #         deleteat!(adjs, chairindex)
    #         panel = AdjudicatorPanel(chair, adjs)
    #         push!(panels, panel)
    #     end
    # end

    # Take a very brute force approach
    # CONTINUE HERE - TODO - don't generate exhaustive list.
    # Probably provide options for different methods, actually:
    #  - random, exhaustive and sample, permuations

    # panels = AdjudicatorPanel[]
    # sizehint!(panels, binomial(numadjs(roundinfo), maximum(panelsizes)))
    # lastprint = 0
    # for panelsize in panelsizes
    #     for adjs in combinations(adjssorted, panelsize)
    #         if !feasible(adjs)
    #             continue
    #         end
    #         possiblechairindices = find(adj -> adj.ranking == adjs[1].ranking, adjs)
    #         chairindex = rand(possiblechairindices)
    #         chair = adjs[chairindex]
    #         deleteat!(adjs, chairindex)
    #         panel = AdjudicatorPanel(chair, adjs)
    #         push!(panels, panel)
    #         if length(panels) - lastprint >= 100000
    #             println("Up to $(length(panels)) panels")
    #             lastprint = length(panels)
    #         end
    #     end
    # end

    # if length(panels) > limitpanels
    #     println("There are $(length(panels)) feasible panels, but limiting to $limitpanels panels, picking at random.")
    #     panels = sample(panels, limitpanels; replace=false)
    # end
    println("There are $(length(panels)) panels to choose from.")

    return panels
end
