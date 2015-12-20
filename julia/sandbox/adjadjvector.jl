# Performance profiling for computation of adj-adj vectors

# In order for the data structure comparison tests to work, these must be
# members of type Adjudicator in types.jl:
#    adjhistory::Dict{Team,Vector{Int}}
#    adjconflicts::Vector{Adjudicator}
# and these must be members of type RoundInfo in types.jl:
#    adjadjconflicts::Vector{Tuple{Adjudicator,Adjudicator}}
#    adjadjhistory::Dict{Tuple{Adjudicator,Adjudicator},Vector{Int}}
# The members of Adjudicator relate to conflicted2, roundsseen2, etc., and the
# members of RoundInfo relate to conflicted1, roundsseen1, etc.
#
# There must also be appropriate constructors. If it helps, here they are, though they might not be quite right:
# Adjudicator(id::Int, name::AbstractString, institution::Institution, ranking::Wudc2015AdjudicatorRank, language::LanguageStatus) = Adjudicator(id, UTF8String(name), institution, ranking, PersonNoGender, Region[institution.region], language, Dict{Team,Vector{Int}}(), Team[], Dict{Adjudicator,Vector{Int}}, Adjudicator[])
# RoundInfo(currentround) = RoundInfo([],[],[],[],[],[],Dict{Tuple{Adjudicator,Adjudicator},Vector{Int}}(),Dict{Tuple{Team,Adjudicator},Vector{Int}}(),[],[],[],AdjumoComponentWeights(),[],currentround)
# RoundInfo(institutions, teams, adjudicators, debates, currentround) = RoundInfo(institutions, teams, adjudicators, debates, [],[],Dict{Tuple{Adjudicator,Adjudicator},Vector{Int}}(),Dict{Tuple{Team,Adjudicator},Vector{Int}}(),[],[],[].AdjumoComponentWeights(), ones(length(debates)), currentround)
# RoundInfo(institutions, teams, adjudicators, debates, debateweights, currentround) = RoundInfo(institutions, teams, adjudicators, debates, [],[],Dict{Tuple{Adjudicator,Adjudicator},Vector{Int}}(),Dict{Tuple{Team,Adjudicator},Vector{Int}}(),[],[],[],AdjumoComponentWeights(), debateweights, currentround)


push!(LOAD_PATH, joinpath(Base.source_dir(), ".."))
using ArgParse
using Adjumo
import Adjumo: historyscore, conflictsscore
using AdjumoDataTools

# ==============================================================================
# Functions that go in types.jl
# ==============================================================================

conflicted1(rinfo::RoundInfo, adj1::Adjudicator, adj2::Adjudicator) = (adj1, adj2) ∈ rinfo.adjadjconflicts || (adj2, adj1) ∈ rinfo.adjadjconflicts || adj1.institution == adj2.institution
roundsseen1(rinfo::RoundInfo, adj1::Adjudicator, adj2::Adjudicator) = unique([get(rinfo.adjadjhistory, (adj1, adj2), Int[]); get(rinfo.adjadjhistory, (adj2, adj1), Int[])])
addadjadjconflict1!(rinfo::RoundInfo, adj1::Adjudicator, adj2::Adjudicator) = push!(rinfo.adjadjconflicts, (adj1, adj2))
addadjadjhistory1!(rinfo::RoundInfo, adj1::Adjudicator, adj2::Adjudicator, round::Int) = push!(get!(rinfo.adjadjhistory, (adj1, adj2), Int[]), round)

conflicted2(adj1::Adjudicator, adj2::Adjudicator) = adj1 ∈ adj2.adjconflicts || adj2 ∈ adj1.adjconflicts || adj1.institution == adj2.institution
roundsseen2(adj1::Adjudicator, adj2::Adjudicator) = unique([get(adj1.adjhistory, adj2, Int[]); get(adj2.adjhistory, adj1, Int[])])
addadjadjconflict2!(adj1::Adjudicator, adj2::Adjudicator) = push!(adj1.adjconflicts, adj2)
addadjadjhistory2!(adj1::Adjudicator, adj2::Adjudicator, round::Int) = push!(get!(adj1.adjhistory, adj2, Int[]), round)

roundsseenasym(rinfo::RoundInfo, adj1::Adjudicator, adj2::Adjudicator) = get(rinfo.adjadjhistory, (adj1, adj2), Int[])

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
# Candidate functions, which go in score.jl
# ==============================================================================

function sumadjadjscoresvector1(adjadjscore::Function, feasiblepanels::Vector{AdjudicatorPanel},
        roundinfo::RoundInfo)
    # This one was picked in the end.

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

# Populate the "other" type of data structure
for (adj1, adj2) in roundinfo.adjadjconflicts
    addadjadjconflict2!(adj1, adj2)
end
for ((adj1, adj2), history) in roundinfo.adjadjhistory
    for round in history
        addadjadjhistory2!(adj1, adj2, round)
    end
end

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
    (sumadjadjscoresvector1, historyscore1); # chosen
    (sumadjadjscoresvector1, historyscore2);
    # (sumadjadjscoresvector2, historyscore1); # slow
    # (sumadjadjscoresvector3, historyscore1); # slow
    # (sumadjadjscoresvector4, historyscore1); # runs out of memory
    # (sumadjadjscoresvector5, historyscore1); # runs out of memory
    # (sumadjadjscoresvector6, historyscore1); # runs out of memory
    # (sumadjadjscoresvector7, historyscore1);
    # (sumadjadjscoresvector8, historyscore1);
    # (sumadjadjscoresvector9, historyscore1);
    # (sumadjadjscoresvector10, historyscore1);
    # (sumadjadjscoresvector11, historyscore1);
    # (sumadjadjscoresvector12, historyscoreasym);
    # (sumadjadjscoresvector1, conflictsscore1);
    # (sumadjadjscoresvector1, conflictsscore2);
]

A = [f(g, feasiblepanels, roundinfo) for (f, g) in funcs]
# push!(A, sumadjadjscoresvector12(historyscoreasym, feasiblepanels, roundinfo))

for i = 1:5
    for (f, g) in shuffle(funcs)
        println("$f $g")
        @time f(g, feasiblepanels, roundinfo)
    end
    # @time sumadjadjscoresvector12(historyscoreasym, feasiblepanels, roundinfo)
end

# push!(funcs, sumadjadjscoresvector12)
for (i, a) in enumerate(A)
    @show funcs[i] sumabs(A[i])
end
for (i, j) in combinations(1:length(funcs), 2)
    @show (funcs[i], funcs[j]) sumabs(A[i] - A[j])
end
