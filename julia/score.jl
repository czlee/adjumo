# This file is part of the Adjumo module.

# Score matrix calculator.
# Contains functions that generate the score matrix, using information about the
# round.

using DataStructures
import Base.string

export scorematrix, score, 
    panelquality, panelregionalrepresentationscore, panellanguagerepresentationscore,
    panelgenderrepresentationscore, teamadjhistoryscore, adjadjhistoryscore,
    teamadjconflictsscore, adjadjconflictsscore

# ==============================================================================
# Top-level functions
# ==============================================================================

"""
Returns the score matrix using the round information.

The score matrix (denoted `Σ`) will be an `ndebates`-by-`npanels` matrix, where
`ndebates` is the number of debates in the round and `npanels` is the number of
feasible panels. The element `Σ[d,p]` is the score of allocating debate of index
`d` to the panel `feasiblepanels[p]`.
- `feasiblepanels` is a list of AdjudicatorPanel instances.
`roundinfo` is a RoundInfo instance.
"""
function scorematrix(feasiblepanels::Vector{AdjudicatorPanel}, roundinfo::RoundInfo)
    @assert length(roundinfo.debates) == length(roundinfo.debateweights)
    componentweights = roundinfo.componentweights
    Σ  = componentweights.quality      * matrixfromvector(qualityvector, feasiblepanels, roundinfo)
    Σ += componentweights.regional     * regionalrepresentationmatrix(feasiblepanels, roundinfo)
    Σ += componentweights.language     * languagerepresentationmatrix(feasiblepanels, roundinfo)
    Σ += componentweights.gender       * genderrepresentationmatrix(feasiblepanels, roundinfo)
    Σ += componentweights.teamhistory  * teamadjhistorymatrix(feasiblepanels, roundinfo)
    Σ += componentweights.adjhistory   * matrixfromvector(adjadjhistoryvector, feasiblepanels, roundinfo)
    Σ += componentweights.teamconflict * teamadjconflictsmatrix(feasiblepanels, roundinfo)
    Σ += componentweights.adjconflict  * matrixfromvector(adjadjconflictsvector, feasiblepanels, roundinfo)
    Σ = spdiagm(roundinfo.debateweights) * Σ
    return Σ
end

function matrixfromvector(f::Function, feasiblepanels::Vector{AdjudicatorPanel}, roundinfo::RoundInfo)
    v = f(feasiblepanels, roundinfo)
    ndebates = numdebates(roundinfo)
    return repmat(v, ndebates, 1)
end

"""
Returns the score for the given panel and debate, using the round information.
This score does *not* account for the weight of the debate.
"""
function score(roundinfo::RoundInfo, debate::Vector{Team}, panel::AdjudicatorPanel)
    componentweights = roundinfo.componentweights
    σ  = componentweights.quality      * panelquality(panel)
    σ += componentweights.regional     * panelregionalrepresentationscore(debate, panel)
    σ += componentweights.language     * panellanguagerepresentationscore(debate, panel)
    σ += componentweights.gender       * panelgenderrepresentationscore(debate, panel)
    σ += componentweights.teamhistory  * teamadjhistoryscore(roundinfo, debate, panel)
    σ += componentweights.adjhistory   * adjadjhistoryscore(roundinfo, panel)
    σ += componentweights.teamconflict * teamadjconflictsscore(roundinfo, debate, panel)
    σ += componentweights.adjconflict  * adjadjconflictsscore(roundinfo, panel)
    return σ
end


# ==============================================================================
# Quality
# ==============================================================================

"""
Returns a 1-by-`npanels` row vector of quality scores, denoted `α`. The element
`α[p]` is the quality of the panel given by `feasiblepanels[p]`. "Quality" means
the raw quality of the panel, not accounting for any sort of representation or
conflict considerations.
- `feasiblepanels` is a list of feasible panels (see definition of
`Vector{AdjudicatorPanel}`).
- `rankings` is a list of rankings, where `rankings[a]` is the ranking of
adjudicator at index `a`.
"""
qualityvector(feasiblepanels::Vector{AdjudicatorPanel}, roundinfo::RoundInfo) = qualityvector(feasiblepanels)
qualityvector(feasiblepanels::Vector{AdjudicatorPanel}) = Float64[panelquality(panel) for panel in feasiblepanels]'
panelquality(panel::AdjudicatorPanel) = panelquality(Wudc2015AdjudicatorRank[adj.ranking for adj in adjlist(panel)])

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
`Vector{AdjudicatorPanel}`).
- `roundinfo` is a RoundInfo instance.

In rough terms, we expect regions in the debate to be represented in
adjudicators on the panel. This function returns zero if that is the case; a
negative number if any region in the debate is not on the panel.
"""
function regionalrepresentationmatrix(feasiblepanels::Vector{AdjudicatorPanel}, roundinfo::RoundInfo)
    ndebates = numdebates(roundinfo)
    npanels = length(feasiblepanels)

    teamregions = Vector{Vector{Region}}(ndebates)
    for (i, debate) in enumerate(roundinfo.debates)
        teamregions[i] = Region[t.region for t in debate]
    end

    panelinfos = Vector{Tuple{Int, Vector{Region}}}(npanels)
    for (i, panel) in enumerate(feasiblepanels)
        panelinfos[i] = (numadjs(panel), vcat(Vector{Region}[adj.regions for adj in adjlist(panel)]...))
    end

    βr = Matrix{Float64}(ndebates, npanels)
    for (p, (nadjs, adjregions)) in enumerate(panelinfos), (d, tr) in enumerate(teamregions)
        βr[d,p] = panelregionalrepresentationscore(tr, adjregions, nadjs)
    end
    return βr
end

@enum DebateRegionClass RegionClassA RegionClassB RegionClassC RegionClassD RegionClassE

string(drc::DebateRegionClass) = "region class " * ["A", "B", "C", "D", "E"][Integer(drc)+1]

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
second is a list of regions in the debate in descending order of frequency.
"""
function debateregionclass(teamregions::Vector{Region})
    # A lot of work has been done to make this function faster. See
    # sandbox/debateregionclass.jl for alternative implementations.
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

function panelregionalrepresentationscore(debate::Vector{Team}, panel::AdjudicatorPanel)
    teamregions = Region[t.region for t in debate]
    adjregions = vcat(Vector{Region}[adj.regions for adj in adjlist(panel)]...)
    nadjs = numadjs(panel)
    return panelregionalrepresentationscore(teamregions, adjregions, nadjs)
end

"Returns the regional representation score for a debate whose teams have the given
regions, and whose adjudicators have the given regions."
function panelregionalrepresentationscore(teamregions::Vector{Region}, adjregions::Vector{Region}, nadjs::Int)
    regionclass, teamregionsordered = debateregionclass(teamregions)
    cost = 0

    if nadjs == 3

        if regionclass == RegionClassA
            # There must be at least two regions on the panel.
            costfactor = 10
            if length(unique(adjregions)) < 2
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
        return -0.1

    elseif nadjs == 4
        return -0.1


    elseif nadjs == 1
        return -0.1

    else
        return -0.1

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
function languagerepresentationmatrix(feasiblepanels::Vector{AdjudicatorPanel}, roundinfo::RoundInfo)
    ndebates = numdebates(roundinfo)
    npanels = length(feasiblepanels)
    return zeros(ndebates, npanels)
end

function panellanguagerepresentationscore(debate::Vector{Team}, panel::AdjudicatorPanel)
    return 0.0
end

# ==============================================================================
# Gender representation
# ==============================================================================

"""
Returns a matrix of representation scores for gender, denoted βg. Elements
correspond to elements in `representation()`. Arguments are as for `representation()`.
"""
function genderrepresentationmatrix(feasiblepanels::Vector{AdjudicatorPanel}, roundinfo::RoundInfo)
    ndebates = numdebates(roundinfo)
    npanels = length(feasiblepanels)
    return zeros(ndebates, npanels)
end

function panelgenderrepresentationscore(debate::Vector{Team}, panel::AdjudicatorPanel)
    return 0.0
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

The returned matrix will be of size `ndebates = numdebates(roundinfo)` by
`npanels = length(feasiblepanels)`. The argument `teamadjscore` should be a
function that takes `(::RoundInfo, ::Team, ::Adjudicator)` and returns a score
for that team and adjudicator, denoted `f` above.
"""
function sumteamadjscoresmatrix(teamadjscore::Function,
        feasiblepanels::Vector{AdjudicatorPanel}, roundinfo::RoundInfo)

    nteams = length(roundinfo.teams)
    nadjs = length(roundinfo.adjudicators)
    ndebates = length(roundinfo.debates)
    npanels = length(feasiblepanels)
    D = zeros(Bool, ndebates, nteams) # debate membership matrix
    Ξ = zeros(nteams, nadjs)          # matrix of team-adj scores
    Q = zeros(Bool, nadjs, npanels)   # panel membership matrix
    # TODO consider pre-doing D and Q outside this function and storing the result
    # TODO allocate D and Q without initialization, and test performance
    for (a, adj) in enumerate(roundinfo.adjudicators), (t, team) in enumerate(roundinfo.teams)
        Ξ[t,a] = teamadjscore(roundinfo, team, adj)
    end
    for (d, debate) in enumerate(roundinfo.debates)
        indices = Int64[findfirst(roundinfo.teams, team) for team in debate]
        D[d, indices] = true
    end
    for (p, panel) in enumerate(feasiblepanels)
        indices = Int64[findfirst(roundinfo.adjudicators, adj) for adj in adjlist(panel)]
        Q[indices, p] = true
    end
    return D*Ξ*Q
end

"""
For scores that can be modelled as the sum of scores between a team and an
adjudicator, `f(team,adj)`, returns the sum of team-adjudicator scores among
teams in the given debate and adjudicators in the given panel:
    Σ{team∈debate} Σ{adj∈panel} f(team,adj)
where Σ denotes summation.
"""
function sumteamadjscores(teamadjscore::Function, roundinfo::RoundInfo,
        debate::Vector{Team}, panel::AdjudicatorPanel)
    score = 0
    for team in debate, adj in adjlist(panel)
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
function sumadjadjscoresvector(adjadjscore::Function, feasiblepanels::Vector{AdjudicatorPanel},
        roundinfo::RoundInfo)
    # We won't necessarily need all pairs of adjudicators, so calculate them
    # as we go, but store them in a dict to avoid having to calculate multiple
    # times.
    # TODO profile this when calculated using matrix multiplication, like sumteamadjscoresmatrix
    ξ = Dict{Tuple{Adjudicator,Adjudicator},Float64}()
    npanels = length(feasiblepanels)
    γ = zeros(1, npanels)
    for (p, panel) in enumerate(feasiblepanels)
        for (adj1, adj2) in combinations(adjlist(panel), 2)
            γ[p] += get!(ξ, (adj1, adj2)) do
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
function sumadjadjscores(adjadjscore::Function, roundinfo::RoundInfo, panel::AdjudicatorPanel)
    score = 0
    for (adj1, adj2) in combinations(adjlist(panel), 2)
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
