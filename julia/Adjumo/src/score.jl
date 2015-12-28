# Score matrix calculator.
# This file is part of the Adjumo module.
#
# Contains functions that generate the score matrix, using information about the
# round.

using DataStructures
import Base.string

export scorematrix, score, scoresfordisplay, panelquality,
    panelregionalrepresentationscore, panellanguagerepresentationscore,
    panelgenderrepresentationscore, teamadjhistoryscore, adjadjhistoryscore,
    teamadjconflictsscore, adjadjconflictsscore, weightedαfairness

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
function scorematrix(roundinfo::RoundInfo, feasiblepanels::Vector{AdjudicatorPanel})
    componentweights = roundinfo.componentweights
    debateweights = getdebateweights(roundinfo)
    @time Σ  = componentweights.quality      * matrixfromvector(qualityvector, feasiblepanels, roundinfo)
    @time Σ += componentweights.regional     * regionalrepresentationmatrix(feasiblepanels, roundinfo)
    @time Σ += componentweights.language     * languagerepresentationmatrix(feasiblepanels, roundinfo)
    @time Σ += componentweights.gender       * genderrepresentationmatrix(feasiblepanels, roundinfo)
    @time Σ += componentweights.teamhistory  * teamadjhistorymatrix(feasiblepanels, roundinfo)
    @time Σ += componentweights.adjhistory   * matrixfromvector(adjadjhistoryvector, feasiblepanels, roundinfo)
    @time Σ += componentweights.teamconflict * teamadjconflictsmatrix(feasiblepanels, roundinfo)
    @time Σ += componentweights.adjconflict  * matrixfromvector(adjadjconflictsvector, feasiblepanels, roundinfo)
    return weightedαfairness(debateweights, Σ, componentweights.α)
    return Σ
end

function matrixfromvector(f::Function, feasiblepanels::Vector{AdjudicatorPanel}, roundinfo::RoundInfo)
    v = f(feasiblepanels, roundinfo).'
    ndebates = numdebates(roundinfo)
    return repmat(v, ndebates, 1)
end

"""
Returns the score for the given panel and debate, using the round information.
This score does *not* account for the weight of the debate, nor does it account
for weighted α-fairness.
"""
function score(roundinfo::RoundInfo, debate::Debate, panel::AdjudicatorPanel)
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

function scoresfordisplay(debate::Debate, panel::AdjudicatorPanel)
    return panelquality(panel), panelregionalrepresentationscore(debate, panel),
            panellanguagerepresentationscore(debate, panel), panelgenderrepresentationscore(debate, panel)
        end

# ==============================================================================
# Weighted α-fairness
# ==============================================================================

"""
Returns the weighted α-fairness value for the given weight w, score σ and α.
This will return -Inf if σ is 0 or negative.
"""
function weightedαfairness(w::Float64, σ::Float64, α::Float64)
    if α < 1.0
        σ = max(σ, zero(σ))
        σ = w^α * σ^(1.0-α)
    elseif α == 1.0
        σ = max(σ, eps())
        σ = w * log(σ)
    else
        σ = max(σ, eps())
        σ = - w^α * σ^(1.0-α)
    end
end

"""
Returns the weighted α-fairness values for the given weights w, score matrix Σ
and α. This will return log(eps()) if Σ is 0 or negative.
"""
function weightedαfairness(w::Vector{Float64}, Σ::Matrix{Float64}, α::Float64)
    if α < 1.0
        Σ = max(Σ, zeros(Σ))
        return spdiagm(w.^α) * Σ.^(1.0-α)
    elseif α == 1.0
        Σ = max(Σ, eps()*ones(Σ))
        return spdiagm(w) * log(Σ)
        # return max(Σ, nextfloat(-Inf)*ones(Σ))
    else
        Σ = max(Σ, eps()*ones(Σ))
        return -spdiagm(w.^α) * Σ.^(1.0-α)
    end
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
qualityvector(feasiblepanels::Vector{AdjudicatorPanel}) = Float64[panelquality(panel) for panel in feasiblepanels]
panelquality(adjs::Vector{Adjudicator}) = panelquality(Wudc2015AdjudicatorRank[adj.ranking for adj in adjs])
panelquality(panel::AdjudicatorPanel) = panelquality(Wudc2015AdjudicatorRank[adj.ranking for adj in accreditedadjs(panel)])

const JUDGE_SCORES = Float64[
#  T-    T0    T+    P-    P0   P+  C-  C0  C+
  -50   -50   -20     5    10   30  20  40  50
  -50   -50   -20     5    10   30  20  40  50
 -200  -200  -200  -100  -100   20  10  30  40
 -200  -200  -200  -200  -200   15   5  25  35
]
const CHAIR_SCORES = Float64[
 -200  -200  -200  -200  -100  -20  10  15  20
]
const NUM_RANKS = length(instances(Wudc2015AdjudicatorRank))

"Returns the quality of a panel whose adjudicators have the given rankings."
function panelquality(rankings::Vector{Wudc2015AdjudicatorRank})
    score = 0
    counts = zeros(Int, NUM_RANKS)

    # General value of judges
    for rank in rankings
        rankindex = Integer(rank)+1
        count = counts[rankindex] += 1
        if count > 4
            count = 4
        end
        score += JUDGE_SCORES[count, rankindex]
    end

    # Bonus for chair
    chairrankindex = findlast(x -> x > 0, counts)
    score += CHAIR_SCORES[chairrankindex]
    return score
end

# ==============================================================================
# Regional representation
# ==============================================================================

"""
Returns a matrix of representation scores for regions, denoted Πα (περιφερειακή
αντιπροσώπευση).

In rough terms, we expect regions in the debate to be represented in
adjudicators on the panel. This function returns zero if that is the case; a
negative number if any region in the debate is not on the panel.
"""
function regionalrepresentationmatrix(feasiblepanels::Vector{AdjudicatorPanel}, roundinfo::RoundInfo)
    ndebates = numdebates(roundinfo)
    npanels = length(feasiblepanels)

    debateinfos = Vector{Tuple{DebateRegionClass, Vector{Region}}}(ndebates)
    for (i, debate) in enumerate(roundinfo.debates)
        teamregions = Region[t.region for t in debate.teams]
        debateinfos[i] = debateregionclass(teamregions)
    end

    Πα = Matrix{Float64}(ndebates, npanels)
    for (p, panel) in enumerate(feasiblepanels), (d, dinfo) in enumerate(debateinfos)
        Πα[d,p] = panelregionalrepresentationscore(dinfo..., panel)
    end
    return Πα
end

@enum DebateRegionClass RegionClassA RegionClassB RegionClassC RegionClassD RegionClassE

string(drc::DebateRegionClass) = "region class " * ["A", "B", "C", "D", "E"][Integer(drc)+1]

debateregionclass(debate::Debate) = debateregionclass(Region[t.region for t in debate.teams])

"""
Infers the 'region class' of a debate whose teams have the given regions.
The 'region class' is:
    - RegionClassA if all four teams are from the same region
    - RegionClassB if three teams are from one region
    - RegionClassC if two teams are from each of two regions
    - RegionClassD if two teams are from one region, and the other two are from different regions
    - RegionClassE if all four teams are from different regions

Returns a tuple with two elements. The first is the class a DebateRegionClass,
and the second is a list of regions in no particular order (not in descending
order of frequency).
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
    regions = [rc.first for rc in regioncounts]
    counts = [rc.second for rc in regioncounts]
    maxcount = maximum(counts)
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

function panelregionalrepresentationscore(debate::Debate, panel::AdjudicatorPanel)
    teamregions = Region[t.region for t in debate.teams]
    drc, teamregions = debateregionclass(teamregions)
    return panelregionalrepresentationscore(drc, teamregions, panel)
end

function panelregionbreakdown(teamregions::Vector{Region}, panel::AdjudicatorPanel)
    externalregions = Region[]
    internalcounts = zeros(Int, length(teamregions))
    externaladjscount = 0
    uniqueexternaladjscount = 0
    for adj in accreditedadjs(panel)
        internalfound = false

        # If any region matches, the judge is an internal judge for every region
        # they are from (so they count more than once).
        for region in adj.regions
            index = findfirst(teamregions, region)
            if index != 0 # i.e., if region is internal
                internalfound = true
                internalcounts[index] += 1
            end
        end

        # If no regions match, the judge is an external judge, and only one
        # external judge, but counts as another "unique" external judge if
        # any one region matches one not already on the panel.
        if !internalfound # i.e., all regions are external
            externaladjscount += 1
            uniqueexternalfound = false
            for region in adj.regions
                if region ∉ externalregions
                    push!(externalregions, region)
                    uniqueexternalfound = true
                end
            end
            if uniqueexternalfound
                uniqueexternaladjscount += 1
            end
        end
    end
    return internalcounts, externaladjscount, uniqueexternaladjscount
end

REGION_CLASS_WEIGHTS = [1, 5, 4, 4.5, 4]

"Returns the regional representation score for a debate whose teams have the given
regions, and whose adjudicators have the given regions."
function panelregionalrepresentationscore(regionclass::DebateRegionClass, teamregions::Vector{Region}, panel::AdjudicatorPanel)
    internalcounts, externaladjscount, uniqueexternaladjscount = panelregionbreakdown(teamregions, panel)
    score = 0

    # Per external and per unique external, applies to all classes
    score += 1.5 * externaladjscount
    score += 0.25 * uniqueexternaladjscount

    # Less than two or three regions, applies to class A
    if regionclass == RegionClassA
        numregions = countnz(internalcounts) + uniqueexternaladjscount
        if numregions < 2
            score -= 3
        elseif numregions < 3
            score -= 1
        end

    # Per internal region absent, applies to classes B, C, D and E
    else
        numregionsabsent = count(x -> x == 0, internalcounts)
        score += numregionsabsent * -4

        nadjs = numadjs(panel)
        majority = nadjs - (nadjs // 2)
        balancedruleapplies = false

        # Single internal region majority, applies to classes B and C
        if regionclass == RegionClassB || regionclass == RegionClassC
            if any(x -> x >= majority, internalcounts)
                score += -10
            end
            if nadjs == 3
                balancedruleapplies = true
            end
            # All external, applies to classes B4, C4 (instead of the balanced rule)
            if nadjs == 4 && externaladjscount == 4
                score += 7
            end

        # Majority are internal (interested majority), applies to classes D and E
        else
            if sum(internalcounts) >= majority
                score += -10
            end
            balancedruleapplies = true
        end

        # Balanced, applies to classes B3, C3, D3, E3, D4, E4
        if balancedruleapplies && maximum(internalcounts) == minimum(internalcounts)
            score += 7
        end

    end

    score *= REGION_CLASS_WEIGHTS[Integer(regionclass)+1]
    return score
end

# ==============================================================================
# Language representation
# ==============================================================================

"""
Returns a matrix of representation scores for language, denoted Γα (γλώσσα
αντιπροσώπευση).
"""
function languagerepresentationmatrix(feasiblepanels::Vector{AdjudicatorPanel}, roundinfo::RoundInfo)
    ndebates = numdebates(roundinfo)
    npanels = length(feasiblepanels)

    classweights = Array{Float64}(ndebates)
    for (i, debate) in enumerate(roundinfo.debates)
        classweights[i] = debatelanguageclassweight(debate)
    end

    γα = Array{Float64}(1,npanels)
    for (i, panel) in enumerate(feasiblepanels)
        γα[i] = panellanguagescore(panel)
    end

    Γα = classweights * γα
    return Γα
end

function panellanguagerepresentationscore(debate::Debate, panel::AdjudicatorPanel)
    return debatelanguageclassweight(debate) * panellanguagescore(panel)
end

"""
Returns the debate language class weight for the debate.
Here's the table:
   EPL 4 3 3 2 2 2 1 1 1 1 0 0 0 0 0
   ESL 0 1 0 2 1 0 3 2 1 0 4 3 2 1 0
   EFL 0 0 1 0 1 2 0 1 2 3 0 1 2 3 4
Weight 0 3 3 4 4 4 3 3 3 3 1 2 2 2 1
"""
function debatelanguageclassweight(debate::Debate)
    nprimary = count(t -> t.language == EnglishPrimary, debate.teams)
    if nprimary == 4
        return 0.0
    elseif nprimary == 2
        return 4.0
    elseif nprimary != 0
        return 3.0
    elseif length(unique(debate.teams)) == 1
        return 1.0
    else
        return 2.0
    end
end

"""
Returns part 1 of the panel language score for the panel.
Here's the table:
Number of EPL judges 0   1 2 3 4
               Score 3 2.5 2 1 0
"""
function panellanguagescore(panel::AdjudicatorPanel)
    nnonprimary = count(a -> a.language != EnglishPrimary, accreditedadjs(panel))
    if nnonprimary == 0
        return -1.5
    elseif nnonprimary == 1
        return 0
    elseif nnonprimary == 2
        return 1
    elseif nnonprimary == 3
        return 1.5
    else
        return 2
    end
end

# ==============================================================================
# Gender representation
# ==============================================================================

"""
Returns a matrix of representation scores for gender, denoted Φα (φύλο
αντιπροσώπευση).
"""
function genderrepresentationmatrix(feasiblepanels::Vector{AdjudicatorPanel}, roundinfo::RoundInfo)
    ndebates = numdebates(roundinfo)
    npanels = length(feasiblepanels)

    classweights = Array{Float64}(ndebates)
    for (i, debate) in enumerate(roundinfo.debates)
        classweights[i] = debategenderclassweight(debate)
    end

    φα = Array{Float64}(1,npanels)
    for (i, panel) in enumerate(feasiblepanels)
        φα[i] = panelgenderscore(panel)
    end

    Φα = classweights * φα
    return Φα
end

function panelgenderrepresentationscore(debate::Debate, panel::AdjudicatorPanel)
    return debategenderclassweight(debate) * panelgenderscore(panel)
end


GENDER_WEIGHTS = [
    0.5     1.75    2.5     2.25    1.0
    3.25    5.0     5.75    4.0   NaN
    4.5     6.25    5.0   NaN     NaN
    3.75    4.0   NaN     NaN     NaN
    1.0   NaN     NaN     NaN     NaN
]

"""
Returns the debate gender class weight for the debate.
Here's the table:
Female   0    0   0    0 0    1 1    1 1   2    2 2    3 3 4
 Mixed   0    1   2    3 4    0 1    2 3   0    1 2    0 1 0
Weight 0.5 1.75 2.5 2.25 1 3.25 5 5.75 4 4.5 6.25 5 3.75 4 1
"""
function debategenderclassweight(debate::Debate)
    nfemale = 0
    nmixed = 0
    for team in debate.teams
        if team.gender == TeamFemale
            nfemale += 1
        elseif team.gender == TeamMixed
            nmixed += 1
        end
    end
    return GENDER_WEIGHTS[nfemale+1, nmixed+1]
end

"""
Returns the gender score for the panel.
"""
function panelgenderscore(panel::AdjudicatorPanel)
    nfemale = count(a -> a.gender == PersonFemale, accreditedadjs(panel))
    proportion = nfemale / numadjs(panel)
    return proportion - 0.5
end

# ==============================================================================
# History and conflicts
# ==============================================================================

"""
For scores that can be modelled as the sum of scores between a team and an
adjudicator, `f(team,adj)`, returns a matrix of scores, one for each debate and
each panel, that is the sum of team-adjudicator scores among teams in that
debate and adjudicators in that panel:
    `Γ[debate,panel] = ∑{team∈debate} ∑{adj∈panel} f(team,adj)`
where Γ is the returned matrix and ∑ denotes summation.

The returned matrix will be of size `ndebates = numdebates(roundinfo)` by
`npanels = length(feasiblepanels)`. The argument `teamadjscore` should be a
function that takes `(::RoundInfo, ::Team, ::Adjudicator)` and returns a score
for that team and adjudicator, denoted `f` above.
"""
function sumteamadjscoresmatrix(teamadjscore::Function,
        feasiblepanels::Vector{AdjudicatorPanel}, roundinfo::RoundInfo)

    nteams = numteams(roundinfo)
    nadjs = numadjs(roundinfo)
    ndebates = numdebates(roundinfo)
    npanels = length(feasiblepanels)
    D = zeros(Bool, ndebates, nteams) # debate membership matrix
    Ξ = Array{Float64}(nteams, nadjs) # matrix of team-adj scores
    Q = zeros(Bool, nadjs, npanels)   # panel membership matrix
    for (a, adj) in enumerate(roundinfo.adjudicators), (t, team) in enumerate(roundinfo.teams)
        Ξ[t,a] = teamadjscore(roundinfo, team, adj)
    end
    for (d, debate) in enumerate(roundinfo.debates)
        indices = Int64[findfirst(roundinfo.teams, team) for team in debate.teams]
        D[d, indices] = true
    end
    for (p, panel) in enumerate(feasiblepanels)
        indices = Int64[findfirst(roundinfo.adjudicators, adj) for adj in accreditedadjs(panel)]
        Q[indices, p] = true
    end
    return D*Ξ*Q
end

"""
For scores that can be modelled as the sum of scores between a team and an
adjudicator, `f(team,adj)`, returns the sum of team-adjudicator scores among
teams in the given debate and adjudicators in the given panel:
    ∑{team∈debate} ∑{adj∈panel} f(team,adj)
where ∑ denotes summation.
"""
function sumteamadjscores(teamadjscore::Function, roundinfo::RoundInfo, debate::Debate, panel::AdjudicatorPanel)
    score = 0
    for team in debate.teams, adj in accreditedadjs(panel)
        score += teamadjscore(roundinfo, team, adj)
    end
    return score
end

"""
For scores that can be modelled as the sum of scores between each pair of
adjudicators on a panel, `f(adj1,adj2)`, returns a vector of scores, one for
each panel, that is the sum of pairwise scores among adjudicators on that panel:
    `γ[panel] = ∑{{adj1,adj2}⊆panel} f(adj1,adj2)`
where γ is the returned matrix and ∑ denotes summation.

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
    # times. I tried lots of ways, this is the fastest I've found -- see
    # the file sandbox/adjadjvector.jl.
    ξ = Dict{Tuple{Adjudicator,Adjudicator},Float64}()
    npanels = length(feasiblepanels)
    γ = zeros(npanels)
    for (p, panel) in enumerate(feasiblepanels)
        for (adj1, adj2) in combinations(accreditedadjs(panel), 2)
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
    ∑{{adj1,adj2}⊆panel} f(adj1,adj2)`
where ∑ denotes summation.

`f` is assumed to be commutative, so only one of `f(a,b)` and `f(b,a)` will be
evaluated.
"""
function sumadjadjscores(adjadjscore::Function, roundinfo::RoundInfo, panel::AdjudicatorPanel)
    score = 0
    for (adj1, adj2) in combinations(accreditedadjs(panel), 2)
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
