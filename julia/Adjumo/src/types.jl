# This file is part of the Adjumo module.

import Base.show
import Base.in
import Base.convert

export Institution, Team, Adjudicator, AdjumoComponentWeights, AdjudicatorPanel,
    Debate, AdjumoComponentWeights, RoundInfo, PanelAllocation,
    TeamGender, TeamNoGender, TeamMale, TeamFemale, TeamMixed,
    PersonGender, PersonNoGender, PersonMale, PersonFemale,
    Region, NoRegion, NorthAsia, SouthEastAsia, MiddleEast, SouthAsia, Africa, Oceania, NorthAmerica, LatinAmerica, Europe, IONA,
    LanguageStatus, NoLanguage, EnglishPrimary, EnglishSecond, EnglishForeign,
    Wudc2015AdjudicatorRank, TraineeMinus, Trainee, TraineePlus, PanellistMinus, Panellist, PanellistPlus, ChairMinus, Chair, ChairPlus,
    numteamsfrominstitution, numteams, numdebates, numadjs, adjlist,
    chair, panellists, trainees,
    conflicted, hasconflict, roundsseen,
    addinstitution!, addteam!, addadjudicator!, adddebate!,
    addadjadjconflict!, addteamadjconflict!, addinstadjconflict!, addadjadjhistory!, addteamadjhistory!,
    addlockedadj!, addblockedadj!, addgroupedadjs!,
    lockedadjs, blockedadjs, groupedadjs, aggregategender

# ==============================================================================
# Models
# ==============================================================================

@enum TeamGender TeamNoGender TeamMale TeamFemale TeamMixed
@enum PersonGender PersonNoGender PersonMale PersonFemale
@enum Region NoRegion NorthAsia SouthEastAsia MiddleEast SouthAsia Africa Oceania NorthAmerica LatinAmerica Europe IONA
@enum LanguageStatus NoLanguage EnglishPrimary EnglishSecond EnglishForeign
@enum Wudc2015AdjudicatorRank TraineeMinus Trainee TraineePlus PanellistMinus Panellist PanellistPlus ChairMinus Chair ChairPlus

type Institution
    id::Int
    name::UTF8String
    code::UTF8String
    region::Region
end

Institution(id::Int, name::UTF8String) = Institution(id, name, name[1:5], NoRegion)
Institution(id::Int, name::AbstractString) = Institution(id, UTF8String(name), name[1:5], NoRegion)
Institution(id::Int, name::UTF8String, code::UTF8String) = Institution(id, name, code, NoRegion)
Institution(id::Int, name::AbstractString, code::AbstractString) = Institution(id, UTF8String(name), UTF8String(code), NoRegion)

type Team
    id::Int
    name::UTF8String
    institution::Institution
    region::Region
    language::LanguageStatus
    gender::TeamGender
    points::Int
    qualitydeficit::Float64
    regionaldeficit::Float64
    languagedeficit::Float64
    genderdeficit::Float64
end

Team(id::Int, name::UTF8String, institution::Institution) =
        Team(id, name, institution, institution.region, NoLanguage, TeamNoGender, 0)
Team(id::Int, name::AbstractString, institution::Institution) =
        Team(id, UTF8String(name), institution, institution.region, NoLanguage, TeamNoGender, 0)
Team(id::Int, name::UTF8String, institution::Institution, region::Region) =
        Team(id, name, institution, region, NoLanguage, TeamNoGender, 0)
Team(id::Int, name::AbstractString, institution::Institution, region::Region) =
        Team(id, UTF8String(name), institution, region, NoLanguage, TeamNoGender, 0)
Team(id::Int, name::UTF8String, institution::Institution, region::Region, language::LanguageStatus, gender::TeamGender) =
        Team(id, name, institution, region, language, gender, 0)
Team(id::Int, name::AbstractString, institution::Institution, region::Region, language::LanguageStatus, gender::TeamGender) =
        Team(id, UTF8String(name), institution, region, language, gender, 0)
Team(id::Int, name::UTF8String, institution::Institution, region::Region, language::LanguageStatus, gender::TeamGender, points::Int) =
        Team(id, name, institution, region, language, gender, points, 0, 0, 0, 0)
Team(id::Int, name::AbstractString, institution::Institution, region::Region, language::LanguageStatus, gender::TeamGender, points::Int) =
        Team(id, UTF8String(name), institution, region, language, gender, points, 0, 0, 0, 0)
show(io::Base.IO, team::Team) = print(io, "Team($(team.id), \"$(team.name)\")")

type Adjudicator
    id::Int
    name::UTF8String
    institution::Institution
    ranking::Wudc2015AdjudicatorRank
    regions::Vector{Region}
    language::LanguageStatus
    gender::PersonGender
end

Adjudicator(id::Int, name::UTF8String, institution::Institution) =
        Adjudicator(id, name, institution, Panellist, Region[institution.region], NoLanguage, PersonNoGender)
Adjudicator(id::Int, name::AbstractString, institution::Institution) =
        Adjudicator(id, UTF8String(name), institution, Panellist, Region[institution.region], NoLanguage, PersonNoGender)
Adjudicator(id::Int, name::AbstractString, institution::Institution, gender::PersonGender) =
        Adjudicator(id, UTF8String(name), institution, Panellist, Region[institution.region], NoLanguage, gender)
Adjudicator(id::Int, name::AbstractString, institution::Institution, ranking::Wudc2015AdjudicatorRank) =
        Adjudicator(id, UTF8String(name), institution, ranking, Region[institution.region], NoLanguage, PersonNoGender)
show(io::Base.IO, adj::Adjudicator) = print(io, "Adjudicator($(adj.id), \"$(adj.name)\", \"$(adj.institution.code)\")")

type Debate
    id::Int
    weight::Float64
    teams::Vector{Team}
    qualitydeficit::Float64
    regionaldeficit::Float64
    languagedeficit::Float64
    genderdeficit::Float64
end

Debate(id::Int, weight::Real, teams::Vector{Team}) = Debate(id, Float64(weight), teams, 0, 0, 0, 0)
Debate(id::Int, teams::Vector{Team}) = Debate(id, 1, teams, 0, 0, 0, 0)
show(io::Base.IO, debate::Debate) = print(io, "Debate($(debate.id), $(debate.weight), $(debate.teams))")

# ==============================================================================
# Immutable relationship types
# ==============================================================================

immutable AdjudicatorDebate
    adjudicator::Adjudicator
    debate::Debate
end

immutable TeamAdjudicator
    team::Team
    adjudicator::Adjudicator
end

immutable AdjudicatorPair
    adj1::Adjudicator
    adj2::Adjudicator
end

immutable InstitutionAdjudicator
    institution::Institution
    adjudicator::Adjudicator
end

# ==============================================================================
# Adjudicator panels
# ==============================================================================

abstract AbstractPanel

# In algorithm code, these are created once (lots of them!) and never change.
immutable AdjudicatorPanel <: AbstractPanel
    adjs::Vector{Adjudicator} # ordered: chair; [panellists...]; [trainees...]
    np::Integer # number of panellists
end

immutable PanelAllocation <: AbstractPanel
    debate::Debate
    score::Float64
    chair::Adjudicator
    panellists::Vector{Adjudicator}
    trainees::Vector{Adjudicator}
end

function AdjudicatorPanel(chair::Adjudicator, panellists::Vector{Adjudicator}, trainees::Vector{Adjudicator})
    np = length(panellists)
    nt = length(trainees)
    adjs = Vector{Adjudicator}(1+np+nt)
    adjs[1] = chair
    adjs[2:np+1] = panellists
    adjs[np+2:end] = trainees
    return AdjudicatorPanel(adjs, np)
end

AdjudicatorPanel(chair::Adjudicator, panellists::Vector{Adjudicator}) = AdjudicatorPanel(chair, panellists, Adjudicator[])
convert(::Type{AdjudicatorPanel}, a::PanelAllocation) = AdjudicatorPanel(a.chair, a.panellists, a.trainees)
numadjs(panel::AdjudicatorPanel) = length(panel.adjs)
chair(panel::AdjudicatorPanel) = panel.adjs[1]
panellists(panel::AdjudicatorPanel) = panel.adjs[2:panel.np+1]
trainees(panel::AdjudicatorPanel) = panel.adjs[panel.np+2:end]

in(adj::Adjudicator, panel::AdjudicatorPanel) = in(adj, panel.adjs)
adjlist(panel::AdjudicatorPanel) = panel.adjs
accreditedadjs(panel::AdjudicatorPanel) = panel.adjs[1:panel.np+1]
show(io::Base.IO, panel::AdjudicatorPanel) = print(io, "Panel[" * join(namewithrolelist(panel), ", ") * "]")

function adjlist(alloc::PanelAllocation)
    np = length(alloc.panellists)
    nt = length(alloc.trainees)
    adjs = Vector{Adjudicator}(1+np+nt)
    adjs[1] = alloc.chair
    adjs[2:np+1] = [alloc.panellists...]
    adjs[np+2:end] = [alloc.trainees...]
    return adjs
end

function adjlist(alloc::PanelAllocation)
    np = length(alloc.panellists)
    adjs = Vector{Adjudicator}(1+np)
    adjs[1] = alloc.chair
    adjs[2:np+1] = [alloc.panellists...]
    return adjs
end

numadjs(alloc::PanelAllocation) = 1 + length(alloc.panellists) + length(alloc.trainees)
chair(alloc::PanelAllocation) = alloc.chair
panellists(alloc::PanelAllocation) = alloc.panellists
trainees(alloc::PanelAllocation) = alloc.trainees

"""
Returns a list of strings, each being an Adjudicator's name annotated by \"(c)\"
if they are a chair and \"(t)\" if they are a trainee (and nothing if they are
a panellist).
"""
function namewithrolelist(panel::AbstractPanel)
    # This function is not efficiently written and is not performance-critical.
    names = Vector{UTF8String}(1)
    names[1] = chair(panel).name * " (c)"
    append!(names, [adj.name for adj in panellists(panel)])
    append!(names, [adj.name * " (t)" for adj in trainees(panel)])
    return names
end

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
    α::Float64
    qualitydeficit::Float64
    regionaldeficit::Float64
    languagedeficit::Float64
    genderdeficit::Float64
end

AdjumoComponentWeights(v::Vector) = AdjumoComponentWeights(v...)
AdjumoComponentWeights() = AdjumoComponentWeights(ones(nfields(AdjumoComponentWeights)))

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
    debates::Vector{Debate}

    # Conflicts are considered hard: test for presence or absence only
    # Note: (adj1, adj2) and (adj2, adj1) mean the same thing, need to check for both
    adjadjconflicts::Vector{AdjudicatorPair}
    teamadjconflicts::Vector{TeamAdjudicator}
    instadjconflicts::Vector{InstitutionAdjudicator}

    # For history, the integer refers to the round of the conflict
    adjadjhistory::Dict{AdjudicatorPair,Vector{Int}}
    teamadjhistory::Dict{TeamAdjudicator,Vector{Int}}

    # Special constraints
    lockedadjs::Vector{AdjudicatorDebate}
    blockedadjs::Vector{AdjudicatorDebate}
    groupedadjs::Vector{Vector{Adjudicator}}

    # Weights
    componentweights::AdjumoComponentWeights
    currentround::Int
end

RoundInfo(currentround) = RoundInfo([],[],[],[],[],[],[],Dict(),Dict(),[],[],[],
        AdjumoComponentWeights(), currentround)
RoundInfo(institutions, teams, adjudicators, debates, currentround) =
        RoundInfo(institutions, teams, adjudicators, debates,
        [],[],[],Dict(),Dict(),[],[],[],
        AdjumoComponentWeights(), currentround)

function conflicted(rinfo::RoundInfo, adj1::Adjudicator, adj2::Adjudicator)
    AdjudicatorPair(adj1, adj2) ∈ rinfo.adjadjconflicts ||
    AdjudicatorPair(adj2, adj1) ∈ rinfo.adjadjconflicts ||
    adj1.institution == adj2.institution ||
    InstitutionAdjudicator(adj1.institution, adj2) ∈ rinfo.instadjconflicts ||
    InstitutionAdjudicator(adj2.institution, adj1) ∈ rinfo.instadjconflicts
end

function conflicted(rinfo::RoundInfo, team::Team, adj::Adjudicator)
    TeamAdjudicator(team, adj) ∈ rinfo.teamadjconflicts ||
    team.institution == adj.institution ||
    InstitutionAdjudicator(team.institution, adj) ∈ rinfo.instadjconflicts
end

hasconflict(rinfo::RoundInfo, adjs::Vector{Adjudicator}) =
        any(pair -> conflicted(rinfo, pair...), combinations(adjs, 2))

roundsseen(rinfo::RoundInfo, adj1::Adjudicator, adj2::Adjudicator) =
        unique([get(rinfo.adjadjhistory, AdjudicatorPair(adj1, adj2), Int[]); get(rinfo.adjadjhistory, AdjudicatorPair(adj2, adj1), Int[])])
roundsseen(rinfo::RoundInfo, team::Team, adj::Adjudicator) =
        get(rinfo.teamadjhistory, TeamAdjudicator(team, adj), Int[])

numteams(rinfo::RoundInfo) = length(rinfo.teams)
numdebates(rinfo::RoundInfo) = length(rinfo.debates)
numadjs(rinfo::RoundInfo) = length(rinfo.adjudicators)

function addinstitution!(rinfo::RoundInfo, args...)
    institution = Institution(args...)
    push!(rinfo.institutions, institution)
    return institution
end

function addteam!(rinfo::RoundInfo, args...)
    team = Team(args...)
    push!(rinfo.teams, team)
    return team
end

function addadjudicator!(rinfo::RoundInfo, args...)
    adjudicator = Adjudicator(args...)
    push!(rinfo.adjudicators, adjudicator)
    return adjudicator
end

function adddebate!(rinfo::RoundInfo, args...)
    debate = Debate(args...)
    push!(rinfo.debates, debate)
    return debate
end

getdebateweights(rinfo::RoundInfo) = Float64[d.weight for d in rinfo.debates]
numteamsfrominstitution(rinfo::RoundInfo, inst::Institution) = count(x -> x.institution == inst, rinfo.teams)

# These functions don't check for validity; that is, they don't check to see
# that the teams and adjudicators in question are actually in rinfo.teams
# and rinfo.adjudicators. It is the responsibility of the caller to make sure
# this is the case.

function addadjadjconflict!(rinfo::RoundInfo, adj1::Adjudicator, adj2::Adjudicator)
    newobj = AdjudicatorPair(adj1, adj2)
    if newobj ∉ rinfo.adjadjconflicts
        push!(rinfo.adjadjconflicts, newobj)
    end
end

function addteamadjconflict!(rinfo::RoundInfo, team::Team, adj::Adjudicator)
    newobj = TeamAdjudicator(team, adj)
    if newobj ∉ rinfo.teamadjconflicts
        push!(rinfo.teamadjconflicts, newobj)
    end
end

function addinstadjconflict!(rinfo::RoundInfo, inst::Institution, adj::Adjudicator)
    newobj = InstitutionAdjudicator(inst, adj)
    if newobj ∉ rinfo.instadjconflicts
        push!(rinfo.instadjconflicts, newobj)
    end
end

function addadjadjhistory!(rinfo::RoundInfo, adj1::Adjudicator, adj2::Adjudicator, round::Int)
    history = get!(rinfo.adjadjhistory, AdjudicatorPair(adj1, adj2), Int[])
    if round ∉ history
        push!(history, round)
    end
end

function addteamadjhistory!(rinfo::RoundInfo, team::Team, adj::Adjudicator, round::Int)
    history = get!(rinfo.teamadjhistory, TeamAdjudicator(team, adj), Int[])
    if round ∉ history
        push!(history, round)
    end
end

function addlockedadj!(rinfo::RoundInfo, adj::Adjudicator, debate::Debate)
    newobj = AdjudicatorDebate(adj, debate)
    if newobj ∉ rinfo.lockedadjs
        push!(rinfo.lockedadjs, newobj)
    end
end

function addblockedadj!(rinfo::RoundInfo, adj::Adjudicator, debate::Debate)
    newobj = AdjudicatorDebate(adj, debate)
    if newobj ∉ rinfo.blockedadjs
        push!(rinfo.blockedadjs, newobj)
    end
end

function addgroupedadjs!(rinfo::RoundInfo, adjs::Vector{Adjudicator})
    push!(rinfo.groupedadjs, adjs)
end

lockedadjs(rinfo::RoundInfo, debate::Debate) = Adjudicator[x.adjudicator for x in filter(y -> y.debate == debate, rinfo.lockedadjs)]
blockedadjs(rinfo::RoundInfo, debate::Debate) = Adjudicator[x.adjudicator for x in filter(y -> y.debate == debate, rinfo.blockedadjs)]
groupedadjs(rinfo::RoundInfo, adjs::Vector{Adjudicator}) = filter(x -> x ⊆ adjs, rinfo.groupedadjs)

hasconflict(roundinfo::RoundInfo, panel::AdjudicatorPanel) = hasconflict(roundinfo, adjlist(panel))

function aggregategender(genderA::PersonGender, genderB::PersonGender)
    if genderA == PersonMale && genderB == PersonMale
        return TeamMale
    elseif genderA == PersonFemale && genderB == PersonFemale
        return TeamFemale
    else
        return TeamMixed
    end
end

