using Iterators
import Base.show

# ==============================================================================
# Models
# ==============================================================================

@enum TeamGender TeamNoGender TeamMale TeamFemale TeamMixed
@enum PersonGender PersonNoGender PersonMale PersonFemale PersonOther
@enum Region NoRegion NorthAsia SouthEastAsia MiddleEast SouthAsia Africa Oceania NorthAmerica LatinAmerica Europe IONA
@enum LanguageStatus NoLanguage EnglishPrimary EnglishSecond EnglishForeign
@enum Wudc2015AdjudicatorRank TraineeMinus Trainee TraineePlus PanellistMinus Panellist PanellistPlus ChairMinus Chair ChairPlus

abbr(g::TeamGender) = ["-", "M", "F", "X"][Integer(g)+1]
abbr(g::PersonGender) = ["-", "m", "f", "o"][Integer(g)+1]
abbr(r::Region) = ["-", "NAsia", "SEAsi", "MEast", "SAsia", "Afric", "Ocean", "NAmer", "LAmer", "Europ", "IONA"][Integer(r)+1]
abbr(l::LanguageStatus) = ["-", "EPL", "ESL", "EFL"][Integer(l)+1]
abbr(r::Wudc2015AdjudicatorRank) = ["T-", "T", "T+", "P-", "P", "P+", "C-", "C", "C+"][Integer(r)+1]

type Institution
    name::UTF8String
    code::UTF8String
    region::Region
end

Institution(name::UTF8String) = Institution(name, name[1:5], NoRegion)
Institution(name::UTF8String, code::UTF8String) = Institution(name, code, NoRegion)
Institution(name::AbstractString, code::AbstractString) = Institution(UTF8String(name), UTF8String(code), NoRegion)

type Team
    name::UTF8String
    institution::Institution
    gender::TeamGender
    region::Region
    language::LanguageStatus
end

Team(name::UTF8String, institution::Institution) = Team(name, institution, TeamNoGender, institution.region, NoLanguage)
Team(name::AbstractString, institution::Institution) = Team(UTF8String(name), institution, TeamNoGender, institution.region, NoLanguage)
Team(name::UTF8String, institution::Institution, region::Region) = Team(name, institution, TeamNoGender, region, NoLanguage)
Team(name::AbstractString, institution::Institution, region::Region) = Team(UTF8String(name), institution, TeamNoGender, region, NoLanguage)
show(io::Base.IO, team::Team) = print(io, "Team(\"$(team.name)\")")

type Adjudicator
    name::UTF8String
    institution::Institution
    ranking::Wudc2015AdjudicatorRank
    gender::PersonGender
    regions::Vector{Region}
    language::LanguageStatus
end

Adjudicator(name::UTF8String, institution::Institution) = Adjudicator(name, institution, Panellist, PersonNoGender, Region[institution.region], NoLanguage)
Adjudicator(name::AbstractString, institution::Institution) = Adjudicator(UTF8String(name), institution, Panellist, PersonNoGender, Region[institution.region], NoLanguage)
Adjudicator(name::AbstractString, institution::Institution, ranking::Wudc2015AdjudicatorRank) = Adjudicator(UTF8String(name), institution, ranking, PersonNoGender, Region[institution.region], NoLanguage)
show(io::Base.IO, adj::Adjudicator) = print(io, "Adjudicator(\"$(adj.name)\", \"$(adj.institution.code)\")")

"A list of \"feasible panels\" is a list of lists of integers. Each (inner) list
contains the indices of adjudicators on a feasible panel."
typealias FeasiblePanelsList{T<:Integer} Vector{Vector{Int64}}

# ==============================================================================
# Factor weightings
# ==============================================================================

type AdjumoComponentWeights
    quality::Float64
    regional::Float64
    language::Float64
    gender::Float64
    teamhistory::Float64
    adjhistory::Float64
    teamconflict::Float64
    adjconflict::Float64
end

AdjumoComponentWeights() = AdjumoComponentWeights(1,1,1,1,1,1,1,1)
AdjumoComponentWeights(v::Vector) = AdjumoComponentWeights(v...)

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
    debates::Vector{Vector{Team}}

    # Conflicts are considered hard: test for presence or absence only
    # Note: (adj1, adj2) and (adj2, adj1) mean the same thing, need to check for both
    adjadjconflicts::Vector{Tuple{Adjudicator,Adjudicator}}
    teamadjconflicts::Vector{Tuple{Team,Adjudicator}}

    # For history, the integer refers to the round of the conflict
    adjadjhistory::Dict{Tuple{Adjudicator,Adjudicator},Vector{Int}}
    teamadjhistory::Dict{Tuple{Team,Adjudicator},Vector{Int}}

    # Special constraints
    adjondebate::Vector{Tuple{Adjudicator,Int}}
    adjoffdeate::Vector{Tuple{Adjudicator,Int}}

    # Weights
    componentweights::AdjumoComponentWeights
    debateweights::Vector{Float64}
    currentround::Int
end

RoundInfo(currentround) = RoundInfo([],[],[],[],[],[],Dict(),Dict(),[],[],AdjumoComponentWeights(),[],currentround)
RoundInfo(institutions, teams, adjudicators, debates, currentround) = RoundInfo(institutions, teams, adjudicators, debates, [],[],Dict(),Dict(),[],[],AdjumoComponentWeights(), ones(length(debates)), currentround)
RoundInfo(institutions, teams, adjudicators, debates, debateweights, currentround) = RoundInfo(institutions, teams, adjudicators, debates, [],[],Dict(),Dict(),[],[],AdjumoComponentWeights(), debateweights, currentround)

conflicted(rinfo::RoundInfo, adj1::Adjudicator, adj2::Adjudicator) = (adj1, adj2) ∈ rinfo.adjadjconflicts || (adj2, adj1) ∈ rinfo.adjadjconflicts
conflicted(rinfo::RoundInfo, team::Team, adj::Adjudicator) = (team, adj) ∈ rinfo.teamadjconflicts
hasconflict(rinfo::RoundInfo, adjs::Vector{Adjudicator}) = any(pair -> conflicted(roundinfo, pair...), subsets(adjs, 2))
roundsseen(rinfo::RoundInfo, adj1::Adjudicator, adj2::Adjudicator) = [get(rinfo.adjadjhistory, (adj1, adj2), Int[]); get(rinfo.adjadjhistory, (adj2, adj1), Int[])]
roundsseen(rinfo::RoundInfo, team::Team, adj::Adjudicator) = get(rinfo.teamadjhistory, (team, adj), Int[])

numdebates(rinfo::RoundInfo) = length(rinfo.debates)
numadjs(rinfo::RoundInfo) = length(rinfo.adjudicators)

addinstitution!(rinfo::RoundInfo, args...) = push!(rinfo.institutions, Institution(args...))
addteam!(rinfo::RoundInfo, args...) = push!(rinfo.teams, Team(args...))
addadjudicator!(rinfo::RoundInfo, args...) = push!(rinfo.adjudicators, Adjudicator(args...))

# These functions don't check for validity; that is, they don't check to see
# that the teams and adjudicators in question are actually in rinfo.teams
# and rinfo.adjudicators. It is the responsibility of the caller to make sure
# this is the case.
addadjadjconflict!(rinfo::RoundInfo, adj1::Adjudicator, adj2::Adjudicator) = push!(rinfo.adjadjconflicts, (adj1, adj2))
addteamadjconflict!(rinfo::RoundInfo, team::Team, adj::Adjudicator) = push!(rinfo.teamadjconflicts, (team, adj))
addadjadjhistory!(rinfo::RoundInfo, adj1::Adjudicator, adj2::Adjudicator, round::Int) = push!(get!(rinfo.adjadjhistory, (adj1, adj2), Int[]), round)
addteamadjhistory!(rinfo::RoundInfo, team::Team, adj::Adjudicator, round::Int) = push!(get!(rinfo.teamadjhistory, (team, adj), Int[]), round)

adjudicatorsfromindices(roundinfo::RoundInfo, indices::Vector{Int64}) = Adjudicator[roundinfo.adjudicators[a] for a in indices]
