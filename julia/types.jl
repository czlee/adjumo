# This file is part of the Adjumo module.

import Base.show
import Base.in

export Institution, Team, Adjudicator, AdjumoComponentWeights, AdjudicatorPanel,
    AdjumoComponentWeights, RoundInfo,
    TeamGender, TeamNoGender, TeamMale, TeamFemale, TeamMixed,
    PersonGender, PersonNoGender, PersonMale, PersonFemale, PersonOther,
    Region, NoRegion, NorthAsia, SouthEastAsia, MiddleEast, SouthAsia, Africa, Oceania, NorthAmerica, LatinAmerica, Europe, IONA,
    LanguageStatus, NoLanguage, EnglishPrimary, EnglishSecond, EnglishForeign,
    Wudc2015AdjudicatorRank, TraineeMinus, Trainee, TraineePlus, PanellistMinus, Panellist, PanellistPlus, ChairMinus, Chair, ChairPlus,
    abbr, numteamsfrominstitution, numteams, numdebates, numadjs, adjlist,
    conflicted, hasconflict, roundsseen,
    addinstitution!, addteam!, addadjudicator!, setdebates!, setdebateweights!,
    addadjadjconflict!, addteamadjconflict!, addadjadjhistory!, addteamadjhistory!,
    addlockedadj!, addblockedadj!, addgroupedadjs!

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
    id::Int
    name::UTF8String
    code::UTF8String
    region::Region
end

Institution(id::Int, name::UTF8String) = Institution(id, name, name[1:5], NoRegion)
Institution(id::Int, name::UTF8String, code::UTF8String) = Institution(id, name, code, NoRegion)
Institution(id::Int, name::AbstractString, code::AbstractString) = Institution(id, UTF8String(name), UTF8String(code), NoRegion)

type Team
    id::Int
    name::UTF8String
    institution::Institution
    gender::TeamGender
    region::Region
    language::LanguageStatus
end

Team(id::Int, name::UTF8String, institution::Institution) = Team(id, name, institution, TeamNoGender, institution.region, NoLanguage)
Team(id::Int, name::AbstractString, institution::Institution) = Team(id, UTF8String(name), institution, TeamNoGender, institution.region, NoLanguage)
Team(id::Int, name::UTF8String, institution::Institution, region::Region) = Team(id, name, institution, TeamNoGender, region, NoLanguage)
Team(id::Int, name::AbstractString, institution::Institution, region::Region) = Team(id, UTF8String(name), institution, TeamNoGender, region, NoLanguage)
show(io::Base.IO, team::Team) = print(io, "Team(\"$(team.name)\")")

type Adjudicator
    id::Int
    name::UTF8String
    institution::Institution
    ranking::Wudc2015AdjudicatorRank
    gender::PersonGender
    regions::Vector{Region}
    language::LanguageStatus
end

Adjudicator(id::Int, name::UTF8String, institution::Institution) = Adjudicator(id, name, institution, Panellist, PersonNoGender, Region[institution.region], NoLanguage)
Adjudicator(id::Int, name::AbstractString, institution::Institution) = Adjudicator(id, UTF8String(name), institution, Panellist, PersonNoGender, Region[institution.region], NoLanguage)
Adjudicator(id::Int, name::AbstractString, institution::Institution, gender::PersonGender) = Adjudicator(id, UTF8String(name), institution, Panellist, gender, Region[institution.region], NoLanguage)
Adjudicator(id::Int, name::AbstractString, institution::Institution, ranking::Wudc2015AdjudicatorRank) = Adjudicator(id, UTF8String(name), institution, ranking, PersonNoGender, Region[institution.region], NoLanguage)
show(io::Base.IO, adj::Adjudicator) = print(io, "Adjudicator(\"$(adj.name)\", \"$(adj.institution.code)\")")

# ==============================================================================
# Adjudicator panel
# ==============================================================================

# In algorithm code, these are created once (lots of them!) and never change.
immutable AdjudicatorPanel
    adjs::Vector{Adjudicator} # ordered: chair; [panellists...]; [trainees...]
    np::Integer # number of panellists
    # TODO: benchmark whether storing indices helps performance a lot
end

function AdjudicatorPanel(chair::Adjudicator, panellists::Vector{Adjudicator}, trainees::Vector{Adjudicator})
    np = length(panellists)
    nt = length(trainees)
    adjs = Vector{Adjudicator}(1+np+nt)
    adjs[1] = chair
    if np > 0
        adjs[2:np+1] = panellists
    end
    if nt > 0
        adjs[np+2:end] = trainees
    end
    return AdjudicatorPanel(adjs, np)
end

# AdjudicatorPanel(chair::Adjudicator, panellists::Tuple{Vararg{Adjudicator}}) = AdjudicatorPanel(chair, panellists, ())
AdjudicatorPanel(chair::Adjudicator, panellists::Vector{Adjudicator}) = AdjudicatorPanel(chair, panellists, Adjudicator[])
# AdjudicatorPanel(chair::Adjudicator, panellists::Vector{Adjudicator}, trainees::Vector{Adjudicator}) = AdjudicatorPanel(chair, (panellists...), (trainees...))
numadjs(panel::AdjudicatorPanel) = length(panel.adjs)

in(adj::Adjudicator, panel::AdjudicatorPanel) = in(adj, panel.adjs)
adjlist(panel::AdjudicatorPanel) = panel.adjs

# "Returns the adjudicators on the panel as a Vector{Adjudicator}"
# function adjlist(panel::AdjudicatorPanel)
#     np = length(panel.panellists)
#     nt = length(panel.trainees)
#     adjs = Vector{Adjudicator}(1+np+nt)
#     adjs[1] = panel.chair
#     adjs[2:np+1] = [panel.panellists...]
#     adjs[np+2:end] = [panel.trainees...]
#     return adjs
# end

function rolelist(panel::AdjudicatorPanel)
    n = length(panel.adjs)
    roles = Vector{UTF8String}(n)
    roles[1] = " (c)"
    if panel.np > 0
        roles[2:panel.np+1] = ""
    end
    if n > panel.np+1
        roles[panel.np+2:n] = " (t)"
    end
    return zip(roles, panel.adjs)
end

function show(io::Base.IO, panel::AdjudicatorPanel)
    names = [adj.name * role for (role, adj) in rolelist(panel)]
    print(io, "Panel[" * join(names, ", ") * "]")
end

# ==============================================================================
# Factor weightings
# ==============================================================================

type AdjumoComponentWeights
    panelsize::Float64
    quality::Float64
    regional::Float64
    language::Float64
    gender::Float64
    teamhistory::Float64
    adjhistory::Float64
    teamconflict::Float64
    adjconflict::Float64
end

AdjumoComponentWeights() = AdjumoComponentWeights(1,1,1,1,1,1,1,1,1)
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
    lockedadjs::Vector{Tuple{Adjudicator,Int}}
    blockedadjs::Vector{Tuple{Adjudicator,Int}}
    groupedadjs::Vector{Vector{Adjudicator}}

    # Weights
    componentweights::AdjumoComponentWeights
    debateweights::Vector{Float64}
    currentround::Int
end

RoundInfo(currentround) = RoundInfo([],[],[],[],[],[],Dict(),Dict(),[],[],[],AdjumoComponentWeights(),[],currentround)
RoundInfo(institutions, teams, adjudicators, debates, currentround) = RoundInfo(institutions, teams, adjudicators, debates, [],[],Dict(),Dict(),[],[],[].AdjumoComponentWeights(), ones(length(debates)), currentround)
RoundInfo(institutions, teams, adjudicators, debates, debateweights, currentround) = RoundInfo(institutions, teams, adjudicators, debates, [],[],Dict(),Dict(),[],[],[],AdjumoComponentWeights(), debateweights, currentround)

conflicted(rinfo::RoundInfo, adj1::Adjudicator, adj2::Adjudicator) = (adj1, adj2) ∈ rinfo.adjadjconflicts || (adj2, adj1) ∈ rinfo.adjadjconflicts || adj1.institution == adj2.institution
conflicted(rinfo::RoundInfo, team::Team, adj::Adjudicator) = (team, adj) ∈ rinfo.teamadjconflicts || team.institution == adj.institution
hasconflict(rinfo::RoundInfo, adjs::Vector{Adjudicator}) = any(pair -> conflicted(rinfo, pair...), combinations(adjs, 2))
roundsseen(rinfo::RoundInfo, adj1::Adjudicator, adj2::Adjudicator) = unique([get(rinfo.adjadjhistory, (adj1, adj2), Int[]); get(rinfo.adjadjhistory, (adj2, adj1), Int[])])
roundsseen(rinfo::RoundInfo, team::Team, adj::Adjudicator) = get(rinfo.teamadjhistory, (team, adj), Int[])

numteams(rinfo::RoundInfo) = length(rinfo.teams)
numdebates(rinfo::RoundInfo) = length(rinfo.debates)
numadjs(rinfo::RoundInfo) = length(rinfo.adjudicators)

addinstitution!(rinfo::RoundInfo, args...) = push!(rinfo.institutions, Institution(args...))
addteam!(rinfo::RoundInfo, args...) = push!(rinfo.teams, Team(args...))
addadjudicator!(rinfo::RoundInfo, args...) = push!(rinfo.adjudicators, Adjudicator(args...))

function setdebates!(rinfo::RoundInfo, debates)
    rinfo.debates = debates
end
function setdebateweights!(rinfo::RoundInfo, debateweights)
    rinfo.debateweights = debateweights
end

numteamsfrominstitution(rinfo::RoundInfo, inst::Institution) = count(x -> x.institution == inst, rinfo.teams)

# These functions don't check for validity; that is, they don't check to see
# that the teams and adjudicators in question are actually in rinfo.teams
# and rinfo.adjudicators. It is the responsibility of the caller to make sure
# this is the case.
addadjadjconflict!(rinfo::RoundInfo, adj1::Adjudicator, adj2::Adjudicator) = push!(rinfo.adjadjconflicts, (adj1, adj2))
addteamadjconflict!(rinfo::RoundInfo, team::Team, adj::Adjudicator) = push!(rinfo.teamadjconflicts, (team, adj))
addadjadjhistory!(rinfo::RoundInfo, adj1::Adjudicator, adj2::Adjudicator, round::Int) = push!(get!(rinfo.adjadjhistory, (adj1, adj2), Int[]), round)
addteamadjhistory!(rinfo::RoundInfo, team::Team, adj::Adjudicator, round::Int) = push!(get!(rinfo.teamadjhistory, (team, adj), Int[]), round)
addlockedadj!(rinfo::RoundInfo, adj::Adjudicator, debateindex::Int) = push!(rinfo.lockedadjs, (adj, debateindex))
addblockedadj!(rinfo::RoundInfo, adj::Adjudicator, debateindex::Int) = push!(rinfo.blockedadjs, (adj, debateindex))
addgroupedadjs!(rinfo::RoundInfo, adjs::Vector{Adjudicator}) = push!(rinfo.groupedadjs, adjs)

lockedadjs(rinfo::RoundInfo, debateindex::Int) = Adjudicator[x[1] for x in filter(y -> y[2] == debateindex, rinfo.lockedadjs)]
blockedadjs(rinfo::RoundInfo, debateindex::Int) = Adjudicator[x[1] for x in filter(y -> y[2] == debateindex, rinfo.blockedadjs)]
groupedadjs(rinfo::RoundInfo, adjs::Vector{Adjudicator}) = filter(x -> x ⊆ adjs, rinfo.groupedadjs)

hasconflict(roundinfo::RoundInfo, panel::AdjudicatorPanel) = hasconflict(roundinfo, adjlist(panel))
