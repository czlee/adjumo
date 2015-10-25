"""Score matrix calculator.
Contains functions that generate the score matrix, using information about the
round.

The (d,p)-th element of the score matrix Σ is the score for allocating panel p
to debate d, and is calculated as
    Σ[d,p] = w(d)[α(p) + β(d,p) - γ(d,p) - δ(p)]
where
    w(d)   is the weighting of the debate (a.k.a. importance, "energy")
    α(p)   is the score given to panel p based on its quality
    β(d,p) is the score for allocating panel p to debate d based on diversity
    γ(d,p) is the penalty for team-adjudicator conflicts and history
    δ(p)   is the penalty for adjudicator-adjudicator conflicts and history
"""

"""
Returns the score matrix using the information about the round.

The score matrix (denoted `Σ`) will be an `ndebates`-by-`npanels` matrix, where
`ndebates` is the number of debates in the round and `npanels` is the number of
feasible panels. The element `Σ[d,p]` is the score of allocating debate of index
`d` to the panel `feasiblepanels[p]`.
- `feasiblepanels` is a list of feasible panels (see definition of
`FeasiblePanelsList`).
`roundinfo` is a RoundInfo instance.
"""
function scorematrix(feasiblepanels::FeasiblePanelsList, roundinfo::RoundInfo)
    ndebates = numdebates(roundinfo)
    npanels = length(feasiblepanels)
    α = quality(feasiblepanels, roundinfo.adjudicators)
    # β = diversity(feasiblepanels, roundinfo)
    # γ = teamadjconflicts(feasiblepanels, roundinfo)
    # δ = adjadjconflicts(feasiblepanels, roundinfo)
    # Σ = α + β + γ + δ
    Σ = repmat(α, ndebates, 1)
    return Σ
end

"""
Returns a 1-by-`npanels` array of quality scores, denoted `α`. The element
`α[p]` is the quality of the panel given by `feasiblepanels[p]`. "Quality" means
the raw quality of the panel, not accounting for any sort of diversity or
conflict considerations.
- `feasiblepanels` is a list of feasible panels (see definition of
`FeasiblePanelsList`).
- `rankings` is a list of rankings, where `rankings[a]` is the ranking of
adjudicator at index `a`.
"""
function quality(feasiblepanels::FeasiblePanelsList, adjudicators::Vector{Adjudicator})
    npanels = length(feasiblepanels)
    α = Array{Float64}(1, npanels)
    for (i, panel) in enumerate(feasiblepanels)
        adjrankings = [adjudicators[adj].ranking for adj in panel]
        α[i] = panelquality(adjrankings)
    end
    return α
end

"""
Returns the quality of a panel whose adjudicators have the given rankings.
"""
function panelquality(rankings::Vector{Wudc2015AdjudicatorRank})
    sort!(rankings, rev=true)
    score = 0

    # Score for chair: 25 if there is a Chair or above, -25 if there are no
    # chairs but there is a PanellistPlus, -75 if the best-ranked judge is
    # Panellist or lower.
    const GOOD_CHAIR = 25
    const CHAIR_IS_PANELLIST_PLUS = -25
    const CHAIR_IS_PANELLIST_OR_LOWER = -75

    if rankings[1] >= Chair
        score += GOOD_CHAIR
    elseif rankings[1] == PanellistPlus
        score += CHAIR_IS_PANELLIST_PLUS
    elseif rankings[1] <= Panellist
        score += CHAIR_IS_PANELLIST_OR_LOWER
    end

    # Score for trainees: -100 if there is more than one trainee, -10 if there
    # is a trainee on the panel but a majority comprises PanellistPlus or
    # higher, -50 if there is a trainee on the panel but no 'safe majority'.
    const MORE_THAN_ONE_TRAINEE = -100
    const ONE_TRAINEE_SAFE_MAJORITY = -10
    const ONE_TRAINEE_UNSAFE_MAJORITY = -50
    numtrainees = count(x -> x <= TraineePlus, rankings)
    if numtrainees > 1
        score += MORE_THAN_ONE_TRAINEE
    elseif numtrainees == 1
        numsafejudges = count(x -> x >= PanellistPlus, rankings)
        if numsafejudges >= 2
            score += ONE_TRAINEE_SAFE_MAJORITY
        else
            score += ONE_TRAINEE_UNSAFE_MAJORITY
        end
    end

    # Score for safe majority: 15 if there is a safe majority, 5 for tolerable
    # majority, 0 otherwise.
    const SAFE_MAJORITY = 15
    const TOLERABLE_MAJORITY = 5
    values_safe = Dict(zip(instances(Wudc2015AdjudicatorRank), (0, 0, 0, 0, 0, 1, 1, 2, 2)))
    total_safe = sum([values_safe[r] for r in rankings])
    if total_safe > 2
        score += SAFE_MAJORITY
    else
        values_tolerable = Dict(zip(instances(Wudc2015AdjudicatorRank), (0, 0, 0, 0, 1, 2, 2, 2, 4)))
        total_tolerable = sum([values_tolerable[r] for r in rankings])
        if total_tolerable > 2
            score += TOLERABLE_MAJORITY
        end
    end

    return score
end

"""
Returns a matrix of diversity scores, denoted β. The element `β[d,p] is the
diversity score achieved when panel given by `feasiblepanels[p]` is allocated
to debate of index `d`.
- `feasiblepanels` is a list of feasible panels (see definition of
`FeasiblePanelsList`).
- `roundinfo` is a RoundInfo instance.
"""
function diversity(feasiblepanels::FeasiblePanelsList, roundinfo::RoundInfo)

end

