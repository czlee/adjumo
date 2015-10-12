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

"Alias for a list of lists of integers."
typealias FeasiblePanelsList{T<:Integer}Vector{Vector{T}}

@enum Wudc2015AdjudicatorRank TraineeMinus Trainee TraineePlus PanellistMinus Panellist PanellistPlus ChairMinus Chair ChairPlus

"""
Returns the score matrix using the information about the round.

The score matrix (denoted `Σ`) will be an `ndebates`-by-`npanels` matrix, where
`ndebates` is the number of debates in the round and `npanels` is the number of
feasible panels. The element `Σ[d,p]` is the score of allocating debate `d` to
panel `p`.
- `feasible_panels` is a list of lists, each list containing the indices of
adjudicators on a feasible panel.
- `round_info` is a round information Dict (see above definition).
"""
function score_matrix(feasible_panels::FeasiblePanelsList, round_info::Dict)
    ndebates = round_info["ndebates"]
    npanels = length(feasible_panels)
    α = quality(feasible_panels, round_info["adjrankings"])
    β = diversity(feasible_panels, round_info)
    γ = teamadjconflicts(feasible_panels, round_info)
    δ = adjadjconflicts(feasible_panels, round_info)
    # Σ = α + β + γ + δ
    return 10rand(ndebates, npanels)
end

"""
Returns a vector of quality scores, denoted `α`. The `p`th element of the
vector, `α[p]`, is the quality of panel `p`. "Quality" means the raw quality of
the panel, not accounting for any sort of diversity or conflict considerations.
- `feasible_panels` is a list of lists, each list containing the indices of
adjudicators on a feasible panel.
- `rankings` is a list of rankings, where `rankings[a]` is the ranking of
adjudicator `a`.
"""
function quality(feasible_panels::FeasiblePanelsList, rankings::Vector)
    npanels = length(feasible_panels)
    α = zeros(npanels)
    for (i, panel) in enumerate(feasible_panels)
        combination = [rankings[adj] for adj in panel]
        α[i] = panelquality(combination)
    end
end

"""
Returns the quality of a panel whose adjudicators have the given `rankings`.
"""
function panelquality(combination::Vector{Wudc2015AdjudicatorRank})

end

"""
Returns a matrix of diversity scores.
"""
function diversity(feasible_panels::FeasiblePanelsList, round_info::Dict)

end
