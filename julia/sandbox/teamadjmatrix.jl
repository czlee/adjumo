# Performance profiling for computation of team-adj matrices

push!(LOAD_PATH, joinpath(Base.source_dir(), ".."))
using ArgParse
using Adjumo
import Adjumo: historyscore, conflictsscore
include("../random.jl")

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

funcs = [
    # sumteamadjscoresmatrix1;
    # sumteamadjscoresmatrix2;
    sumteamadjscoresmatrix3;
    sumteamadjscoresmatrix4;
    sumteamadjscoresmatrix5;
]

for f in funcs
    f(historyscore, feasiblepanels, roundinfo)
end

for i = 1:5
    for f in shuffle(funcs)
        println(f)
        @time [f(historyscore, feasiblepanels, roundinfo) for j in 1:1]
    end
end

A = [f(historyscore, feasiblepanels, roundinfo) for f in funcs]
for (i, a) in enumerate(A)
    @show funcs[i] sumabs(A[i])
end
for (i, j) in combinations(1:length(funcs), 2)
    @show (funcs[i], funcs[j]) sumabs(A[i] - A[j])
end
