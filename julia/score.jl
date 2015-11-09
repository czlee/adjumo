# Score matrix calculator.
# Contains functions that generate the score matrix, using information about the
# round.

# The (d,p)-th element of the score matrix Σ is the score for allocating panel p
# to debate d, and is calculated as
#     Σ[d,p] = w(d)[α(p) + β(d,p) - γ(d,p) - δ(p)]
# where
#     w(d)   is the weighting of the debate (a.k.a. importance, "energy")
#     α(p)   is the score given to panel p based on its quality
#     β(d,p) is the score for allocating panel p to debate d based on diversity
#     γ(d,p) is the penalty for team-adjudicator conflicts and history
#     δ(p)   is the penalty for adjudicator-adjudicator conflicts and history

using DataStructures

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
    α = qualitymatrix(feasiblepanels, roundinfo.adjudicators)
    # β = diversitymatrix(feasiblepanels, roundinfo)
    # γ = teamadjconflictsmatrix(feasiblepanels, roundinfo)
    # δ = adjadjconflictsmatrix(feasiblepanels, roundinfo)
    # Σ = α + β + γ + δ
    Σ = repmat(α, ndebates, 1)
    return Σ
end

# ==============================================================================
# Quality
# ==============================================================================

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
function qualitymatrix(feasiblepanels::FeasiblePanelsList, adjudicators::Vector{Adjudicator})
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

# ==============================================================================
# Diversity
# ==============================================================================

"""
Returns a matrix of diversity scores, denoted β. The element `β[d,p]` is the
diversity score achieved when panel given by `feasiblepanels[p]` is allocated
to debate of index `d`.
- `feasiblepanels` is a list of feasible panels (see definition of
`FeasiblePanelsList`).
- `roundinfo` is a RoundInfo instance.
"""
function diversitymatrix(feasiblepanels::FeasiblePanelsList, roundinfo::RoundInfo)
    βr = regionaldiversitymatrix(feasiblepanels, roundinfo)
    βl = languagediversitymatrix(feasiblepanels, roundinfo)
    βg = genderdiversitymatrix(feasiblepanels, roundinfo)
    return βr + βl + βg
end

"""
Returns a matrix of diversity scores for regions, denoted βr. Elements
correspond to elements in `diversity()`. Arguments are as for `diversity()`.

In rough terms, we expect regions in the debate to be represented in
adjudicators on the panel. This function returns zero if that is the case; a
negative number if any region in the debate is not on the panel.
"""
function regionaldiversitymatrix(feasiblepanels::FeasiblePanelsList, roundinfo::RoundInfo)
    ndebates = length(roundinfo.debates)
    npanels = length(feasiblepanels)

    teamregions = Vector{Region}(ndebates)
    for (i, debate) in enumerate(roundinfo.debates)
        teamregions[i] = Region[t.region for t in debate]
    end

    adjregions = Vector{Region}(npanels)
    for (i, panel) in enumerate(feasiblepanels)
        adjregions[i] = Region[roundinfo.adjudicators[adj].region for adj in panel]
    end

    βr = Matrix{Float64}(ndebates, npanels)
    for ((d, tr), (p, ar)) in product(enumerate(teamregions), enumerate(adjregions))
        βr[d,p] = panelregionaldiversityscore(tr, ar)
    end
end

@enum DebateRegionClass RegionClassA RegionClassB RegionClassC RegionClassD RegionClassE

"""
Infers the 'region class' of a debate whose teams have the given regions.
The 'region class' is:
    - RegionClassA if all four teams are from the same region
    - RegionClassB if three teams are from one region
    - RegionClassC if two teams are from each of two regions
    - RegionClassD if two teams are from one region, and the other two are from different regions
    - RegionClassE if all four teams are from different regions
Returns a tuple with two elements. The first is the class (an integer), and the
second is
"""
function debateregionclass(teamregions::Vector{Region})
    assert(length(teamregions) == 4)
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
        throw(ArgumentError("Region counts were invalid."))
    end
end

"Returns the regional diversity score for a debate whose teams have the given
regions, and whose adjudicators have the given regions."
function panelregionaldiversityscore(teamregions::Vector{Region}, adjregions::Vector{Region})
    nadjs = length(adjregions)
    regionclass, teamregionsordered = debateregionclass(teamregions)
    panelregioncounts = counter(adjregions)
    cost = 0

    if nadjs == 3

        if regionclass == RegionClassA
            # There must be at least two regions on the panel.
            costfactor = 10
            if length(panelregioncounts) < 3
                cost += 20
            end

        elseif regionclass == RegionClassB
            costfactor = 100
            for tr in teamregionsordered
                if tr ∉ adjregions
                    cost += 20
                end
            end
            if all([ar ∈ teamregionsordered for ar in adjregions])
                cost += 100
            end

        elseif regionclass == RegionClassC
            costfactor = 80
            for tr in teamregionsordered
                if tr ∉ adjregions
                    cost += 10
                end
            end
            if all([ar ∈ teamregionsordered for ar in adjregions])
                cost += 80
            end

        elseif regionclass == RegionClassD
            costfactor = 60
            for tr in teamregionsordered
                if tr ∉ adjregions
                    cost += 40
                end
            end

        elseif regionclass == RegionClassE
            costfactor =  60
            externaladjs = count(ar -> ar ∉ teamregionsordered, adjregions)
            if externaladjs == 0
                cost += 30
            elseif externaladjs == 1
                cost += 10
            end
            if length(teamregionsordered) < 2
                cost += 5
            end

        end


    elseif nadjs == 2
        return 0

    elseif nadjs == 4
        return 0


    elseif nadjs == 1
        return 0

    else
        return 0

    end

    return -costfactor * cost

end

"""
Returns a matrix of diversity scores for language, denoted βl. Elements
correspond to elements in `diversity()`. Arguments are as for `diversity()`.
"""
function languagediversity(feasiblepanels::FeasiblePanelsList, roundinfo::RoundInfo)

end

"""
Returns a matrix of diversity scores for gender, denoted βg. Elements
correspond to elements in `diversity()`. Arguments are as for `diversity()`.
"""
function genderdiversity(feasiblepanels::FeasiblePanelsList, roundinfo::RoundInfo)

end

