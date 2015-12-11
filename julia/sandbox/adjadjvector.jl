# Performance profiling for computation of adj-adj vectors

push!(LOAD_PATH, joinpath(Base.source_dir(), ".."))
using ArgParse
using Adjumo
import Adjumo: historyscore, conflictsscore
include("../random.jl")

roundsseenasym(rinfo::RoundInfo, adj1::Adjudicator, adj2::Adjudicator) = get(rinfo.adjadjhistory, (adj1, adj2), Int[])

function historyscoreasym(roundinfo::RoundInfo, args...)
    score = 0
    for round in roundsseenasym(roundinfo, args...)
        @assert round < roundinfo.currentround
        score -= 1 / (roundinfo.currentround - round)
    end
    return score
end

function sumadjadjscoresvector1(adjadjscore::Function, feasiblepanels::Vector{AdjudicatorPanel},
        roundinfo::RoundInfo)
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

function sumadjadjscoresvector2(adjadjscore::Function,
        feasiblepanels::Vector{AdjudicatorPanel}, roundinfo::RoundInfo)

    nadjs = numadjs(roundinfo)
    npanels = length(feasiblepanels)
    Ξ = Array{Float64}(nadjs, nadjs)  # matrix of adj-adj scores
    Q = zeros(Bool, nadjs, npanels)   # panel membership matrix
    for (a1, adj1) in enumerate(roundinfo.adjudicators), (a2, adj2) in enumerate(roundinfo.adjudicators)
        Ξ[a1,a2] = adjadjscore(roundinfo, adj1, adj2)
    end
    for (p, panel) in enumerate(feasiblepanels)
        indices = Int64[findfirst(roundinfo.adjudicators, adj) for adj in adjlist(panel)]
        Q[indices, p] = true
    end
    return (ones(1,nadjs)*((Ξ*Q).*Q))/2
end

function sumadjadjscoresvector3(adjadjscore::Function,
        feasiblepanels::Vector{AdjudicatorPanel}, roundinfo::RoundInfo)

    nadjs = numadjs(roundinfo)
    npanels = length(feasiblepanels)
    Ξ = zeros(nadjs, nadjs)  # matrix of adj-adj scores
    Q = zeros(Bool, nadjs, npanels)   # panel membership matrix
    for (a1, adj1) in enumerate(roundinfo.adjudicators), (a2, adj2) in enumerate(roundinfo.adjudicators[1:a1])
        Ξ[a1,a2] = adjadjscore(roundinfo, adj1, adj2)
    end
    for (p, panel) in enumerate(feasiblepanels)
        indices = Int64[findfirst(roundinfo.adjudicators, adj) for adj in adjlist(panel)]
        Q[indices, p] = true
    end
    return ones(1,nadjs)*((Ξ*Q).*Q)
end

# Runs out of memory -- npanels x npanels is too big
function sumadjadjscoresvector4(adjadjscore::Function,
        feasiblepanels::Vector{AdjudicatorPanel}, roundinfo::RoundInfo)

    nadjs = numadjs(roundinfo)
    npanels = length(feasiblepanels)
    Ξ = Array{Float64}(nadjs, nadjs)  # matrix of adj-adj scores
    Q = zeros(Bool, nadjs, npanels)   # panel membership matrix
    for (a1, adj1) in enumerate(roundinfo.adjudicators), (a2, adj2) in enumerate(roundinfo.adjudicators)
        Ξ[a1,a2] = adjadjscore(roundinfo, adj1, adj2)
    end
    for (p, panel) in enumerate(feasiblepanels)
        indices = Int64[findfirst(roundinfo.adjudicators, adj) for adj in adjlist(panel)]
        Q[indices, p] = true
    end
    return diag(Q'*Ξ*Q).'/2
end

# Runs out of memory -- npanels x npanels is too big
function sumadjadjscoresvector5(adjadjscore::Function,
        feasiblepanels::Vector{AdjudicatorPanel}, roundinfo::RoundInfo)

    nadjs = numadjs(roundinfo)
    npanels = length(feasiblepanels)
    Ξ = zeros(nadjs, nadjs)  # matrix of adj-adj scores
    Q = zeros(Bool, nadjs, npanels)   # panel membership matrix
    for (a1, adj1) in enumerate(roundinfo.adjudicators), (a2, adj2) in enumerate(roundinfo.adjudicators[1:a1])
        Ξ[a1,a2] = adjadjscore(roundinfo, adj1, adj2)
    end
    for (p, panel) in enumerate(feasiblepanels)
        indices = Int64[findfirst(roundinfo.adjudicators, adj) for adj in adjlist(panel)]
        Q[indices, p] = true
    end
    return diag(Q'*Ξ*Q).'
end

# Runs out of memory -- npanels x npanels is too big
function sumadjadjscoresvector6(adjadjscore::Function,
        feasiblepanels::Vector{AdjudicatorPanel}, roundinfo::RoundInfo)

    nadjs = numadjs(roundinfo)
    npanels = length(feasiblepanels)
    Ξ = Array{Float64}(nadjs, nadjs)  # matrix of adj-adj scores
    Q = zeros(Bool, nadjs, npanels)   # panel membership matrix
    for (a1, adj1) in enumerate(roundinfo.adjudicators), (a2, adj2) in enumerate(roundinfo.adjudicators[1:a1])
        Ξ[a1,a2] = adjadjscore(roundinfo, adj1, adj2)
    end
    Ξtri = LowerTriangular(Ξ)
    for (p, panel) in enumerate(feasiblepanels)
        indices = Int64[findfirst(roundinfo.adjudicators, adj) for adj in adjlist(panel)]
        Q[indices, p] = true
    end
    return diag(Q'*Ξtri*Q).'
end

function sumadjadjscoresvector7(adjadjscore::Function,
        feasiblepanels::Vector{AdjudicatorPanel}, roundinfo::RoundInfo)

    nadjs = numadjs(roundinfo)
    npanels = length(feasiblepanels)
    Ξ = Array{Float64}(nadjs, nadjs)  # matrix of adj-adj scores
    Q = zeros(Bool, nadjs, npanels)   # panel membership matrix
    for (a1, adj1) in enumerate(roundinfo.adjudicators), (a2, adj2) in enumerate(roundinfo.adjudicators[1:a1])
        Ξ[a1,a2] = adjadjscore(roundinfo, adj1, adj2)
    end
    Ξtri = LowerTriangular(Ξ)
    for (p, panel) in enumerate(feasiblepanels)
        indices = Int64[findfirst(roundinfo.adjudicators, adj) for adj in adjlist(panel)]
        Q[indices, p] = true
    end
    return ones(1,nadjs)*((Ξtri*Q).*Q)
end

function sumadjadjscoresvector8(adjadjscore::Function, feasiblepanels::Vector{AdjudicatorPanel},
        roundinfo::RoundInfo)
    nadjs = numadjs(roundinfo)
    npanels = length(feasiblepanels)
    Ξ = Array{Float64}(nadjs, nadjs)  # matrix of adj-adj scores
    q = Vector{Bool}(nadjs)
    γ = zeros(1, npanels)
    for (a1, adj1) in enumerate(roundinfo.adjudicators), (a2, adj2) in enumerate(roundinfo.adjudicators)
        Ξ[a1,a2] = adjadjscore(roundinfo, adj1, adj2)
    end
    for (p, panel) in enumerate(feasiblepanels)
        q[:] = false
        indices = Int64[findfirst(roundinfo.adjudicators, adj) for adj in adjlist(panel)]
        q[indices] = true
        γ[p] = q⋅(Ξ*q)
    end
    return γ/2
end

function sumadjadjscoresvector9(adjadjscore::Function, feasiblepanels::Vector{AdjudicatorPanel},
        roundinfo::RoundInfo)
    nadjs = numadjs(roundinfo)
    npanels = length(feasiblepanels)
    Ξ = Array{Float64}(nadjs, nadjs)  # matrix of adj-adj scores
    q = Vector{Bool}(nadjs)
    γ = zeros(1, npanels)
    for (a1, adj1) in enumerate(roundinfo.adjudicators), (a2, adj2) in enumerate(roundinfo.adjudicators[1:a1])
        Ξ[a1,a2] = adjadjscore(roundinfo, adj1, adj2)
    end
    Ξtri = LowerTriangular(Ξ)
    for (p, panel) in enumerate(feasiblepanels)
        q[:] = false
        indices = Int64[findfirst(roundinfo.adjudicators, adj) for adj in adjlist(panel)]
        q[indices] = true
        γ[p] = q⋅(Ξtri*q)
    end
    return γ
end

function sumadjadjscoresvector10(adjadjscore::Function, feasiblepanels::Vector{AdjudicatorPanel},
        roundinfo::RoundInfo)
    ξ = Dict{Tuple{Adjudicator,Adjudicator},Float64}()
    npanels = length(feasiblepanels)
    γ = zeros(1, npanels)
    for (p, panel) in enumerate(feasiblepanels)
        for (a1, adj1) in enumerate(adjlist(panel)), adj2 in adjlist(panel)[1:a1]
            γ[p] += get!(ξ, (adj1, adj2)) do
                adjadjscore(roundinfo, adj1, adj2)
            end
        end
    end
    return γ
end

function sumadjadjscoresvector11(adjadjscore::Function, feasiblepanels::Vector{AdjudicatorPanel},
        roundinfo::RoundInfo)
    ξ = Dict{Tuple{Adjudicator,Adjudicator},Float64}()
    npanels = length(feasiblepanels)
    γ = zeros(1, npanels)
    for (p, panel) in enumerate(feasiblepanels)
        for adj1 in adjlist(panel), adj2 in adjlist(panel)
            γ[p] += get!(ξ, (adj1, adj2)) do
                adjadjscore(roundinfo, adj1, adj2)
            end
        end
    end
    return γ/2
end

function sumadjadjscoresvector12(adjadjscore::Function, feasiblepanels::Vector{AdjudicatorPanel},
        roundinfo::RoundInfo)
    ξ = Dict{Tuple{Adjudicator,Adjudicator},Float64}()
    npanels = length(feasiblepanels)
    γ = zeros(1, npanels)
    for (p, panel) in enumerate(feasiblepanels)
        for adj1 in adjlist(panel), adj2 in adjlist(panel)
            γ[p] += get!(ξ, (adj1, adj2)) do
                adjadjscore(roundinfo, adj1, adj2)
            end
        end
    end
    return γ
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

# sumadjadjscoresvector1(historyscore, feasiblepanels, roundinfo)
# sumadjadjscoresvector7(historyscore, feasiblepanels, roundinfo)
# @profile sumadjadjscoresvector1(historyscore, feasiblepanels, roundinfo)
# Profile.print(maxdepth=6)
# Profile.clear()
# println("===================================")
# @profile sumadjadjscoresvector7(historyscore, feasiblepanels, roundinfo)
# Profile.print(maxdepth=6)
# exit()

funcs = [
    sumadjadjscoresvector1;
    # sumadjadjscoresvector2; # slow
    # sumadjadjscoresvector3; # slow
    # sumadjadjscoresvector4; # runs out of memory
    # sumadjadjscoresvector5; # runs out of memory
    # sumadjadjscoresvector6; # runs out of memory
    sumadjadjscoresvector7;
    # sumadjadjscoresvector8;
    # sumadjadjscoresvector9;
    sumadjadjscoresvector10;
    sumadjadjscoresvector11;
]

A = [f(historyscore, feasiblepanels, roundinfo) for f in funcs]
push!(A, sumadjadjscoresvector12(historyscoreasym, feasiblepanels, roundinfo))

for i = 1:5
    for f in shuffle(funcs)
        println(f)
        @time f(historyscore, feasiblepanels, roundinfo)
    end
    @time sumadjadjscoresvector12(historyscoreasym, feasiblepanels, roundinfo)
end

push!(funcs, sumadjadjscoresvector12)
for (i, a) in enumerate(A)
    @show funcs[i] sumabs(A[i])
end
for (i, j) in combinations(1:length(funcs), 2)
    @show (funcs[i], funcs[j]) sumabs(A[i] - A[j])
end
