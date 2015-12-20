# Performance profiling for computation of team-adj matrices

# In order for the data structure comparison tests to work, these must be
# members of type Adjudicator in types.jl:
#    teamhistory::Dict{Team,Vector{Int}}
#    teamconflicts::Vector{Team}
# and these must be members of type RoundInfo in types.jl:
#    teamadjconflicts::Vector{Tuple{Team,Adjudicator}}
#    teamadjhistory::Dict{Tuple{Team,Adjudicator},Vector{Int}}
# The members of Adjudicator relate to conflicted2, roundsseen2, etc., and the
# members of RoundInfo relate to conflicted1, roundsseen1, etc.

push!(LOAD_PATH, joinpath(Base.source_dir(), ".."))
using ArgParse
using Adjumo
import Adjumo: historyscore, conflictsscore
using AdjumoDataTools

# ==============================================================================
# Functions that go in types.jl
# ==============================================================================

conflicted1(rinfo::RoundInfo, team::Team, adj::Adjudicator) = (team, adj) ∈ rinfo.teamadjconflicts || team.institution == adj.institution
roundsseen1(rinfo::RoundInfo, team::Team, adj::Adjudicator) = get(rinfo.teamadjhistory, (team, adj), Int[])
addteamadjconflict1!(rinfo::RoundInfo, team::Team, adj::Adjudicator) = push!(rinfo.teamadjconflicts, (team, adj))
addteamadjhistory1!(rinfo::RoundInfo, team::Team, adj::Adjudicator, round::Int) = push!(get!(rinfo.teamadjhistory, (team, adj), Int[]), round)

conflicted2(team::Team, adj::Adjudicator) = team ∈ adj.teamconflicts || team.institution == adj.institution
roundsseen2(team::Team, adj::Adjudicator) = get(adj.teamhistory, team, Int[])
addteamadjconflict2!(team::Team, adj::Adjudicator) = push!(adj.teamconflicts, team)
addteamadjhistory2!(team::Team, adj::Adjudicator, round::Int) = push!(get!(adj.teamhistory, team, Int[]), round)

# ==============================================================================
# Helper functions that go in score.jl
# ==============================================================================

function historyscoreasym(roundinfo::RoundInfo, args...)
    score = 0
    for round in roundsseenasym(roundinfo, args...)
        @assert round < roundinfo.currentround
        score -= 1 / (roundinfo.currentround - round)
    end
    return score
end

conflictsscore1(rinfo, args...) = -conflicted1(rinfo, args...)

function historyscore1(roundinfo::RoundInfo, args...)
    score = 0
    for round in roundsseen1(roundinfo, args...)
        @assert round < roundinfo.currentround
        score -= 1 / (roundinfo.currentround - round)
    end
    return score
end

conflictsscore2(rinfo, args...) = -conflicted2(args...)

function historyscore2(roundinfo::RoundInfo, args...)
    score = 0
    for round in roundsseen2(args...)
        @assert round < roundinfo.currentround
        score -= 1 / (roundinfo.currentround - round)
    end
    return score
end


# ==============================================================================
# Functions which might go in types.jl, if they're useful
# ==============================================================================

"""
Returns the panel membership matrix for a list of feasible panels.

The panel membership matrix (denoted `Q`) will be an `npanels` by `nadjs`
matrix, where `npanels` is the total number of feasible panels, and `nadjs` is
the number of adjudicators. The element `Q[p,a]` will be 1 if adjudicator `a` is
in panel `p`, and 0 otherwise.
"""
function panelmembershipmatrix(roundinfo::RoundInfo, feasiblepanels::Vector{AdjudicatorPanel})
    npanels = length(feasiblepanels)
    nadjs = numadjs(roundinfo)
    Q = zeros(Bool, npanels, nadjs)
    for (p, panel) in enumerate(feasiblepanels)
        indices = Int64[findfirst(roundinfo.adjudicators, adj) for adj in adjlist(panel)]
        Q[p, indices] = true
    end
    return Q
end

"""
Returns the debate membership matrix for a RoundInfo.

The debate membership matrix (denoted `D`) will be an `ndebates` by `nteams`
matrix, where `ndebates` is the number of debates and `nteams` is the number
of teams. The element `D[d,t]` will be 1 if team `t` is in debate `d`, and 0
otherwise.
"""
function debatemembershipmatrix(roundinfo::RoundInfo)
    nteams = numteams(roundinfo)
    ndebates = numdebates(roundinfo)
    D = zeros(Bool, ndebates, nteams)
    for (d, debate) in enumerate(roundinfo.debates)
        indices = Int64[findfirst(roundinfo.teams, team) for team in debate]
        D[d, indices] = true
    end
    return D
end


# ==============================================================================
# Candidate functions, which go in score.jl
# ==============================================================================

function sumteamadjscoresmatrix1(teamadjscore::Function,
        feasiblepanels::Vector{AdjudicatorPanel}, roundinfo::RoundInfo)
    # First, find the score for each team/adj combination. We'll need all of
    # them at some point, so just do them all.
    ξ = Dict{Tuple{Team,Adjudicator},Float64}()
    for team in roundinfo.teams, adj in roundinfo.adjudicators
        ξ[(team,adj)] = teamadjscore(roundinfo, team, adj)
    end

    # Then, populate the history matrix.
    ndebates = numdebates(roundinfo)
    npanels = length(feasiblepanels)
    Γ = zeros(ndebates, npanels)
    for (d, debate) in enumerate(roundinfo.debates)
        for (p, panel) in enumerate(feasiblepanels)
            for team in debate
                for adj in adjlist(panel)
                    Γ[d,p] += ξ[(team,adj)]
                end
            end
        end
    end

    return Γ
end

function sumteamadjscoresmatrix2(teamadjscore::Function,
        feasiblepanels::Vector{AdjudicatorPanel}, roundinfo::RoundInfo)

    nteams = length(roundinfo.teams)
    nadjs = length(roundinfo.adjudicators)
    ndebates = length(roundinfo.debates)
    npanels = length(feasiblepanels)
    D = zeros(Bool, ndebates, nteams) # debate membership matrix
    Ξ = zeros(nteams, nadjs)          # matrix of team-adj scores
    Q = zeros(Bool, nadjs, npanels)   # panel membership matrix
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

function sumteamadjscoresmatrix3(teamadjscore::Function,
        feasiblepanels::Vector{AdjudicatorPanel}, roundinfo::RoundInfo)

    nteams = length(roundinfo.teams)
    nadjs = length(roundinfo.adjudicators)
    ndebates = length(roundinfo.debates)
    npanels = length(feasiblepanels)
    D = zeros(Bool, ndebates, nteams) # debate membership matrix
    Ξ = Array{Float64}(nteams, nadjs) # matrix of team-adj scores
    Q = zeros(Bool, nadjs, npanels)   # panel membership matrix
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

function sumteamadjscoresmatrix4(teamadjscore::Function,
        feasiblepanels::Vector{AdjudicatorPanel}, roundinfo::RoundInfo)
    # This one was picked in the end.

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
        indices = Int64[findfirst(roundinfo.teams, team) for team in debate]
        D[d, indices] = true
    end
    for (p, panel) in enumerate(feasiblepanels)
        indices = Int64[findfirst(roundinfo.adjudicators, adj) for adj in adjlist(panel)]
        Q[indices, p] = true
    end
    return D*Ξ*Q
end

function sumteamadjscoresmatrix5(teamadjscore::Function,
        feasiblepanels::Vector{AdjudicatorPanel}, roundinfo::RoundInfo)

    nteams = numteams(roundinfo)
    nadjs = numadjs(roundinfo)
    D = debatemembershipmatrix(roundinfo)
    Ξ = Array{Float64}(nteams, nadjs) # matrix of team-adj scores
    Q = panelmembershipmatrix(roundinfo, feasiblepanels).'
    for (a, adj) in enumerate(roundinfo.adjudicators), (t, team) in enumerate(roundinfo.teams)
        Ξ[t,a] = teamadjscore(roundinfo, team, adj)
    end
    return D*Ξ*Q
end

argsettings = ArgParseSettings()
@add_arg_table argsettings begin
    "-n", "--ndebates"
        help = "Number of debates in round"
        arg_type = Int
        default = 5
    "-r", "--currentround"
        help = "Current round number"
        arg_type = Int
        default = 5
end
args = parse_args(ARGS, argsettings)

ndebates = args["ndebates"]
currentround = args["currentround"]
roundinfo = randomroundinfo(ndebates, currentround)
feasiblepanels = generatefeasiblepanels(roundinfo)

# Populate the "other" type of data structure
for (team, adj) in roundinfo.teamadjconflicts
    addteamadjconflict2!(team, adj)
end
for ((team, adj), history) in roundinfo.teamadjhistory
    for round in history
        addteamadjhistory2!(team, adj, round)
    end
end

funcs = [
    # (sumteamadjscoresmatrix1, historyscore1);
    # (sumteamadjscoresmatrix2, historyscore1);
    # (sumteamadjscoresmatrix3, historyscore1);
    (sumteamadjscoresmatrix4, historyscore1); # chosen
    (sumteamadjscoresmatrix4, conflictsscore1); # chosen
    (sumteamadjscoresmatrix4, historyscore2); # chosen
    (sumteamadjscoresmatrix4, conflictsscore2); # chosen
    # (sumteamadjscoresmatrix5, historyscore1);
]

A = [f(g, feasiblepanels, roundinfo) for (f, g) in funcs]

for i = 1:5
    for (f, g) in shuffle(funcs)
        println("$f $g")
        @time [f(g, feasiblepanels, roundinfo) for j in 1:1]
    end
end

for (i, a) in enumerate(A)
    @show funcs[i] sumabs(A[i])
end
for (i, j) in combinations(1:length(funcs), 2)
    @show (funcs[i], funcs[j]) sumabs(A[i] - A[j])
end
