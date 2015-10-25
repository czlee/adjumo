# ==============================================================================
# Models
# ==============================================================================

@enum Gender NoGender GenderMale GenderFemale GenderOther
@enum Region NoRegion NorthAsia SouthEastAsia MiddleEast SouthAsia Africa Oceania NorthAmerica LatinAmerica Europe IONA
@enum LanguageStatus NoLanguage EnglishPrimary EnglishSecond EnglishForeign
@enum Wudc2015AdjudicatorRank TraineeMinus Trainee TraineePlus PanellistMinus Panellist PanellistPlus ChairMinus Chair ChairPlus

type Institution
    name::UTF8String
end

type Team
    name::UTF8String
    institution::Institution
    gender::Gender
    region::Region
    language::LanguageStatus
end

Team(name::UTF8String, institution::Institution) = Team(name, institution, NoGender, NoRegion, NoLanguage)
Team(name::AbstractString, institution::Institution) = Team(UTF8String(name), institution, NoGender, NoRegion, NoLanguage)

type Adjudicator
    name::UTF8String
    institution::Institution
    ranking::Wudc2015AdjudicatorRank
    gender::Gender
    regions::Vector{Region}
    language::LanguageStatus
end

Adjudicator(name::UTF8String, institution::Institution) = Adjudicator(name, institution, Panellist, NoGender, Region[], NoLanguage)
Adjudicator(name::AbstractString, institution::Institution) = Adjudicator(UTF8String(name), institution, Panellist, NoGender, Region[], NoLanguage)
Adjudicator(name::AbstractString, institution::Institution, ranking::Wudc2015AdjudicatorRank) = Adjudicator(UTF8String(name), institution, ranking, NoGender, Region[], NoLanguage)

"A list of \"feasible panels\" is a list of lists of integers. Each (inner) list
contains the indices of adjudicators on a feasible panel."
typealias FeasiblePanelsList{T<:Integer} Vector{Vector{Int64}}

# ==============================================================================
# Round information
# ==============================================================================

"Container type for all information about a round."
type RoundInfo
    # For institutions and teams, these collections aren't that important, they
    # just provide a convenient means of accessing all institutions/teams.
    institutions::Vector{Institution}
    teams::Vector{Team}

    # For adjudicators and debates, indices are important to the solver.
    adjudicators::Vector{Adjudicator}
    debates::Vector{Tuple{Team,Team,Team,Team}}

    # Conflicts are considered hard: test for presence or absence only
    # Note: (adj1, adj2) and (adj2, adj1) mean the same thing, need to check for both
    adjadjconflicts::Vector{Tuple{Adjudicator,Adjudicator}}
    adjteamconflicts::Vector{Tuple{Adjudicator,Team}}

    # For history, the integer refers to the round of the conflict
    adjadjhistory::Dict{Tuple{Adjudicator,Adjudicator},Vector{Int}}
    adjteamhistory::Dict{Tuple{Adjudicator,Team},Vector{Int}}
end

RoundInfo() = RoundInfo([],[],[],[],[],[],Dict(),Dict())
RoundInfo(institutions, teams, adjudicators, debates) = RoundInfo(institutions, teams, adjudicators, debates, [], [], Dict(), Dict())

conflicted(rinfo::RoundInfo, adj1::Adjudicator, adj2::Adjudicator) = (adj1, adj2) ∈ rinfo.adjadjconflicts || (adj2, adj1) ∈ rinfo.adjadjconflicts
conflicted(rinfo::RoundInfo, adj::Adjudicator, team::Team) = (adj, team) ∈ rinfo.adjteamconflicts
seen(rinfo::RoundInfo, adj1::Adjudicator, adj2::Adjudicator) = [get(rinfo.adjadjhistory, (adj1, adj2), Int[]); get(rinfo.adjadjhistory, (adj2, adj1), Int[])]
seen(rinfo::RoundInfo, adj::Adjudicator, team::Adjudicator) = get(rinfo.adjadjhistory, (adj1, adj2), Int[])

numdebates(rinfo::RoundInfo) = length(rinfo.debates)
numadjs(rinfo::RoundInfo) = length(rinfo.adjudicators)

;