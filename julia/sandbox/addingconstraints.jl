push!(LOAD_PATH, joinpath(Base.source_dir(), ".."))
using ArgParse
using Adjumo
using JuMP
import Adjumo: panelmembershipmatrix, convertconstraints, choosesolver
using AdjumoDataTools


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
println("random round info:")
@time roundinfo = randomroundinfo(ndebates, currentround)

println("panels and score:")
@time feasiblepanels = generatefeasiblepanels(roundinfo)
@time Σ = scorematrix(roundinfo, feasiblepanels)
@time Q = panelmembershipmatrix(roundinfo, feasiblepanels)
@time istrainee = [adj.ranking <= TraineePlus for adj in roundinfo.adjudicators]

println("constraints:")
@time lockedadjs = convertconstraints(roundinfo.adjudicators, roundinfo.lockedadjs)
@time blockedadjs = convertconstraints(roundinfo.adjudicators, roundinfo.blockedadjs)

function solveoptimizationproblem1{T<:Real}(Σ::Matrix{T}, Q::AbstractMatrix{Bool},
        lockedadjs::Vector{Tuple{Int,Int}}, blockedadjs::Vector{Tuple{Int,Int}},
        istrainee::Vector{Bool};
        solver="default")

    (ndebates, npanels) = size(Σ)

    modelsolver = choosesolver(solver)
    m = Model(solver=modelsolver)

    @defVar(m, X[1:ndebates,1:npanels], Bin)
    @setObjective(m, Max, sum(Σ.*X))
    @time @addConstraint(m, X*ones(npanels) .== 1)                    # each debate has exactly one panel
    @time @addConstraint(m, ones(1,ndebates)*X*Q[:,~istrainee] .== 1) # each accredited adjudicator is allocated once
    @time @addConstraint(m, ones(1,ndebates)*X*Q[:, istrainee] .<= 1) # each trainee adjudicator is allocated at most once

    # adjudicator constraints
    for (a, d) in lockedadjs
        @addConstraint(m, X[d,:]*Q[:,a] .== 1)
    end
    for (a, d) in blockedadjs
        @addConstraint(m, X[d,:]*Q[:,a] .== 0)
    end


    @printf("There are %d panels to choose from.\n", npanels)

    # @time status = solve(m)

    # if status != :Optimal
    #     println("Error: Problem was not solved to optimality. Status was: $status")
    #     return (Int[], Int[])
    # end

    # println("Objective value: ", getObjectiveValue(m))
    # allocation = findn(getValue(X))
    # return allocation
end

function solveoptimizationproblem2{T<:Real}(Σ::Matrix{T}, Q::AbstractMatrix{Bool},
        lockedadjs::Vector{Tuple{Int,Int}}, blockedadjs::Vector{Tuple{Int,Int}},
        istrainee::Vector{Bool};
        solver="default")

    (ndebates, npanels) = size(Σ)

    modelsolver = choosesolver(solver)
    m = Model(solver=modelsolver)

    @defVar(m, X[1:ndebates,1:npanels], Bin)
    @setObjective(m, Max, sum(Σ.*X))
    @time @addConstraint(m, sum(X.*1,2) .== 1)                    # each debate has exactly one panel
    @time @addConstraint(m, sum(X*Q[:,~istrainee],1) .== 1) # each accredited adjudicator is allocated once
    @time @addConstraint(m, sum(X*Q[:, istrainee],1) .<= 1) # each trainee adjudicator is allocated at most once

    # adjudicator constraints
    for (a, d) in lockedadjs
        @addConstraint(m, X[d,:]*Q[:,a] .== 1)
    end
    for (a, d) in blockedadjs
        @addConstraint(m, X[d,:]*Q[:,a] .== 0)
    end


    @printf("There are %d panels to choose from.\n", npanels)

    # @time status = solve(m)

    # if status != :Optimal
    #     println("Error: Problem was not solved to optimality. Status was: $status")
    #     return (Int[], Int[])
    # end

    # println("Objective value: ", getObjectiveValue(m))
    # allocation = findn(getValue(X))
    # return allocation
end


println("version 1:")
@time solveoptimizationproblem1(Σ, Q, lockedadjs, blockedadjs, istrainee)

println("version 2:")
@time solveoptimizationproblem2(Σ, Q, lockedadjs, blockedadjs, istrainee)