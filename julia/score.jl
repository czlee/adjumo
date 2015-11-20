# Score matrix calculator.
# Contains functions that generate the score matrix, using information about the
# round.

# The (d,p)-th element of the score matrix Σ is the score for allocating panel p
# to debate d, and is calculated as
#     Σ[d,p] = w(d)[α(p) + β(d,p) - γ(d,p) - δ(p)]
# where
#     w(d)   is the weighting of the debate (a.k.a. importance, "energy")
#     α(p)   is the score given to panel p based on its quality
#     β(d,p) is the score for allocating panel p to debate d based on representation
#     γ(d,p) is the penalty for team-adjudicator conflicts and history
#     δ(p)   is the penalty for adjudicator-adjudicator conflicts and history

using DataStructures

# ==============================================================================
# Top-level functions
# ==============================================================================

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
    weights = roundinfo.weights
    Σ  = weights.quality      * matrixfromvector(qualityvector, feasiblepanels, roundinfo)
    Σ += weights.regional     * regionalrepresentationmatrix(feasiblepanels, roundinfo)
    Σ += weights.language     * languagerepresentationmatrix(feasiblepanels, roundinfo)
    Σ += weights.gender       * genderrepresentationmatrix(feasiblepanels, roundinfo)
    Σ += weights.teamhistory  * teamadjhistorymatrix(feasiblepanels, roundinfo)
    Σ += weights.adjhistory   * matrixfromvector(adjadjhistoryvector, feasiblepanels, roundinfo)
    Σ += weights.teamconflict * teamadjconflictsmatrix(feasiblepanels, roundinfo)
    Σ += weights.adjconflict  * matrixfromvector(adjadjconflictsvector, feasiblepanels, roundinfo)
    return Σ
end

function matrixfromvector(f::Function, feasiblepanels::FeasiblePanelsList, roundinfo::RoundInfo)
    v = f(feasiblepanels, roundinfo)
    ndebates = numdebates(roundinfo)
    return repmat(v, ndebates, 1)
end

# ==============================================================================
# Quality
# ==============================================================================

qualityvector(feasiblepanels::FeasiblePanelsList, roundinfo::RoundInfo) = qualityvector(feasiblepanels, roundinfo.adjudicators)

"""
Returns a 1-by-`npanels` row vector of quality scores, denoted `α`. The element
`α[p]` is the quality of the panel given by `feasiblepanels[p]`. "Quality" means
the raw quality of the panel, not accounting for any sort of representation or
conflict considerations.
- `feasiblepanels` is a list of feasible panels (see definition of
`FeasiblePanelsList`).
- `rankings` is a list of rankings, where `rankings[a]` is the ranking of
adjudicator at index `a`.
"""
function qualityvector(feasiblepanels::FeasiblePanelsList, adjudicators::Vector{Adjudicator})
    npanels = length(feasiblepanels)
    α = Array{Float64}(1, npanels)
    for (i, panel) in enumerate(feasiblepanels)
        adjs = [adjudicators[adj] for adj in panel]
        α[i] = panelquality(adjs)
    end
    return α
end

panelquality(panel::Vector{Adjudicator}) = panelquality([adj.ranking for adj in panel])

"Returns the quality of a panel whose adjudicators have the given rankings."
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
# Regional representation
# ==============================================================================

"""
Returns a matrix of representation scores for regions, denoted βr.
- `feasiblepanels` is a list of feasible panels (see definition of
`FeasiblePanelsList`).
- `roundinfo` is a RoundInfo instance.

In rough terms, we expect regions in the debate to be represented in
adjudicators on the panel. This function returns zero if that is the case; a
negative number if any region in the debate is not on the panel.
"""
function regionalrepresentationmatrix(feasiblepanels::FeasiblePanelsList, roundinfo::RoundInfo)
    ndebates = length(roundinfo.debates)
    npanels = length(feasiblepanels)

    teamregions = Vector{Vector{Region}}(ndebates)
    for (i, debate) in enumerate(roundinfo.debates)
        teamregions[i] = Region[t.region for t in debate]
    end

    adjregions = Vector{Vector{Region}}(npanels)
    for (i, panel) in enumerate(feasiblepanels)
        adjregions[i] = vcat(Vector{Region}[roundinfo.adjudicators[adj].regions for adj in panel]...)
    end

    βr = Matrix{Float64}(ndebates, npanels)
    for ((d, tr), (p, ar)) in product(enumerate(teamregions), enumerate(adjregions))
        βr[d,p] = panelregionalrepresentationscore(tr, ar)
    end
    return βr
end

@enum DebateRegionClass RegionClassA RegionClassB RegionClassC RegionClassD RegionClassE

debateregionclass(teams::Vector{Team}) = debateregionclass(Region[t.region for t in teams])

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

"Returns the regional representation score for a debate whose teams have the given
regions, and whose adjudicators have the given regions."
function panelregionalrepresentationscore(teamregions::Vector{Region}, adjregions::Vector{Region})
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

# ==============================================================================
# Language representation
# ==============================================================================

"""
Returns a matrix of representation scores for language, denoted βl. Elements
correspond to elements in `representation()`. Arguments are as for `representation()`.
"""
function languagerepresentationmatrix(feasiblepanels::FeasiblePanelsList, roundinfo::RoundInfo)
    ndebates = length(roundinfo.debates)
    npanels = length(feasiblepanels)
    return zeros(ndebates, npanels)
end

# ==============================================================================
# Gender representation
# ==============================================================================

"""
Returns a matrix of representation scores for gender, denoted βg. Elements
correspond to elements in `representation()`. Arguments are as for `representation()`.
"""
function genderrepresentationmatrix(feasiblepanels::FeasiblePanelsList, roundinfo::RoundInfo)
    ndebates = length(roundinfo.debates)
    npanels = length(feasiblepanels)
    return zeros(ndebates, npanels)
end

# ==============================================================================
# History and conflicts
# ==============================================================================

"""
For scores that can be modelled as the sum of scores between a team and an
adjudicator, `f(team,adj)`, returns a matrix of scores, one for each debate and
each panel, that is the sum of team-adjudicator scores among teams in that
debate and adjudicators in that panel:
    `Γ[debate,panel] = Σ{team∈debate} Σ{adj∈panel} f(team,adj)`
where Γ is the returned matrix and Σ denotes summation.

The returned matrix will be of size `ndebates = length(roundinfo.debates)` by
`npanels = length(feasiblepanels)`. The argument `teamadjscore` should be a
function that takes `(::RoundInfo, ::Team, ::Adjudicator)` and returns a score
for that team and adjudicator, denoted `f` above.
"""
function sumteamadjscoresmatrix(teamadjscore::Function,
        feasiblepanels::FeasiblePanelsList, roundinfo::RoundInfo)
    # First, find the score for each team/adj combination. We'll need all of
    # them at some point, so just do them all.
    ξ = Dict{Tuple{Team,Int64},Float64}()
    for (team, (adjindex, adj)) in product(roundinfo.teams, enumerate(roundinfo.adjudicators))
        ξ[(team,adjindex)] = teamadjscore(roundinfo, team, adj)
    end

    # Then, populate the history matrix.
    ndebates = length(roundinfo.debates)
    npanels = length(feasiblepanels)
    Γ = zeros(ndebates, npanels)
    for ((d, debate), (p, panel)) in product(enumerate(roundinfo.debates), enumerate(feasiblepanels))
        for (team, adjindex) in product(debate, panel)
            Γ[d,p] += ξ[(team,adjindex)]
        end
    end

    return Γ
end

"""
For scores that can be modelled as the sum of scores between a team and an
adjudicator, `f(team,adj)`, returns the sum of team-adjudicator scores among
teams in the given debate and adjudicators in the given panel:
    Σ{team∈debate} Σ{adj∈panel} f(team,adj)
where Σ denotes summation.
"""
function sumteamadjscores(teamadjscore::Function, roundinfo::RoundInfo,
        debate::Vector{Team}, adjudicators::Vector{Adjudicator})
    score = 0
    for (team, adj) in product(debate, adjudicators)
        score += teamadjscore(roundinfo, team, adj)
    end
    return score
end

"""
For scores that can be modelled as the sum of scores between each pair of
adjudicators on a panel, `f(adj1,adj2)`, returns a vector of scores, one for
each panel, that is the sum of pairwise scores among adjudicators on that panel:
    `γ[panel] = Σ{{adj1,adj2}⊆panel} f(adj1,adj2)`
where γ is the returned matrix and Σ denotes summation.

`f` is assumed to be commutative, so only one of `f(a,b)` and `f(b,a)` will be
evaluated.

The returned matrix will be `npanels` by `npanels`, where `npanels =
length(feasiblepanels). The argument `adjadjscore` should be a function that
takes `(::RoundInfo, ::Adjudicator, ::Adjudicator) and returns a score for that
pair of adjudicators, denoted `f` above.
"""
function sumadjadjscoresvector(adjadjscore::Function, feasiblepanels::FeasiblePanelsList,
        roundinfo::RoundInfo)
    # We won't necessarily need all pairs of adjudicators, so calculate them
    # as we go, but store them in a dict to avoid having to calculate multiple
    # times.
    ξ = Dict{Tuple{Int64,Int64},Float64}()
    npanels = length(feasiblepanels)
    γ = zeros(1, npanels)
    for (p, panel) in enumerate(feasiblepanels)
        for (a1, a2) in subsets(panel, 2) # a1, a2 are integer indices, not Adjudicators
            γ[p] += get!(ξ, (a1, a2)) do
                adj1 = roundinfo.adjudicators[a1]
                adj2 = roundinfo.adjudicators[a2]
                adjadjscore(roundinfo, adj1, adj2)
            end
        end
    end
    return γ
end

"""
For scores that can be modelled as the sum of scores betwene each pair of
adjudicators on a panel, `f(adj1,adj2)`, returns the sum of pairwise scores
among adjudicators on the given panel:
    Σ{{adj1,adj2}⊆panel} f(adj1,adj2)`
where Σ denotes summation.

`f` is assumed to be commutative, so only one of `f(a,b)` and `f(b,a)` will be
evaluated.
"""
function sumadjadjscores(adjadjscore::Function, roundinfo::RoundInfo, adjudicators::Vector{Adjudicator})
    score = 0
    for (a1, a2) in subsets(panel)
        score += adjadjscore(roundinfo, adj1, adj2)
    end
    return score
end

teamadjhistorymatrix(fp, rinfo) = sumteamadjscoresmatrix(historyscore, fp, rinfo)
teamadjhistoryscore(rinfo, debate, adjs) = sumteamadjscores(historyscore, rinfo, debate, adjs)
teamadjconflictsmatrix(fp, rinfo) = sumteamadjscoresmatrix(conflictsscore, fp, rinfo)
teamadjconflictsscore(rinfo, debate, adjs) = sumteamadjscores(conflictsscore, rinfo, debate, adjs)
adjadjhistoryvector(fp, rinfo) = sumadjadjscoresvector(historyscore, fp, rinfo)
adjadjhistoryscore(rinfo, adjs) = sumadjadjscores(historyscore, rinfo, adjs)
adjadjconflictsvector(fp, rinfo) = sumadjadjscoresvector(conflictsscore, fp, rinfo)
adjadjconflictsscore(rinfo, adjs) = sumadjadjscores(conflictsscore, rinfo, adjs)

"""The conflicts score is just -1 if they conflict or 0 if they don't."""
conflictsscore(rinfo, args...) = -conflicted(rinfo, args...)

"""The history score is given by
    `Σ{r∈roundsseen} 1/(currentround - r)`
where `roundsseen` is the set of all rounds where the arguments have seen each
other, `currentround` is the current round, and the difference between two
rounds is the number of rounds between them (e.g. round6 - round2 = 4).
"""
function historyscore(roundinfo::RoundInfo, args...)
    score = 0
    for round in roundsseen(roundinfo, args...)
        @assert round < roundinfo.currentround
        score -= 1 / (roundinfo.currentround - round)
    end
    return score
end
