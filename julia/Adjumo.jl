# Adjumo: Allocating Debate Judges Using Mathematical Optimization.
# Top-level file.
# allocateadjudicators() is the top-level function.

__precompile__()

module Adjumo

using JuMP
using Formatting

SUPPORTED_SOLVERS = [
    ("gurobi", :Gurobi,                :GurobiSolver,  :MIPGap),
    ("cbc",    :Cbc,                   :CbcSolver,     :ratioGap),
    ("glpk",   :GLPKMathProgInterface, :GLPKSolverMIP, :tol_obj),
]

include("types.jl")
include("score.jl")
include("display.jl")

export allocateadjudicators, generatefeasiblepanels

function convertconstraints(adjudicators::Vector{Adjudicator}, original::Vector{Tuple{Adjudicator,Int}})
    converted = Vector{Tuple{Int,Int}}(length(original))
    for (i, (adj, debateindex)) in enumerate(original)
        converted[i] = (findfirst(adjudicators, adj), debateindex)
    end
    return converted
end

"""
Top-level adjudicator allocation function.
`roundinfo` is a RoundInfo instance.
"""
function allocateadjudicators(roundinfo::RoundInfo; solver="default")

    feasible = checkfeasibility(roundinfo)
    if !feasible
        println("Error: Incompatible constraints found.")
        return (Int[], AdjudicatorPanel[])
    end

    @time feasiblepanels = generatefeasiblepanels(roundinfo)
    @time Σ = scorematrix(roundinfo, feasiblepanels)

    Q = panelmembershipmatrix(roundinfo, feasiblepanels)
    adjson = convertconstraints(roundinfo.adjudicators, roundinfo.lockedadjs)
    adjsoff = convertconstraints(roundinfo.adjudicators, roundinfo.blockedadjs)
    @time debateindices, panelindices = solveoptimizationproblem(Σ, Q, adjson, adjsoff; solver=solver)

    panels = AdjudicatorPanel[feasiblepanels[p] for p in panelindices]
    return debateindices, panels
end


"""Checks the given round information for conditions that would definitely
make the problem infeasible."""
function checkfeasibility(roundinfo::RoundInfo)
    feasible = true
    for adjs in roundinfo.groupedadjs
        for (adj1, adj2) in combinations(adjs, 2)
            if conflicted(roundinfo, adj1, adj2)
                printfmtln("Error: {} and {} are both grouped and conflicted.",
                        adj1.name, adj2.name)
                feasible = false
            end
        end
    end
    return feasible
end

"""
Generates a list of feasible panels using the information about the round.
`roundinfo` is a RoundInfo instance.

Returns a list of AdjudicatorPanel instances.
"""
function generatefeasiblepanels(roundinfo::RoundInfo)
    nchairs = numdebates(roundinfo)

    chairs = roundinfo.adjudicators[1:nchairs]
    panellists = roundinfo.adjudicators[nchairs+1:end]
    panellistcombs = combinations(panellists, 2)
    panels = AdjudicatorPanel[AdjudicatorPanel(c, [p...]) for c in chairs, p in panellistcombs]

    # panels with judges that conflict with each other are not feasible
    panels = filter(panel -> !hasconflict(roundinfo, panel), panels) # remove panels with adj-adj conflicts

    # panels with some but not all of a list of judges that must judge together are not feasible
    for adjs in roundinfo.groupedadjs
        filter!(panel -> count(a -> a ∈ adjlist(panel), adjs) ∈ [0, length(adjs)], panels)
    end

    return panels
end

"""
Returns the panel membership matrix for a list of feasible panels.

The panel membership matrix (denoted `Q`) will be an `npanels` by `nadjs`
matrix, where `npanels` is the total number of feasible panels, and `nadjs` is
the number of adjudicators. The element `Q[p,a]` will be 1 if adjudicator `a` is
in panel `p`, and 0 otherwise.

`feasiblepanels` is a list of AdjudicatorPanel instances.
`nadjs` is the number of adjudicators.
"""
function panelmembershipmatrix(roundinfo::RoundInfo, feasiblepanels::Vector{AdjudicatorPanel})
    npanels = length(feasiblepanels)
    nadjs = numadjs(roundinfo)
    Q = spzeros(Bool, npanels, nadjs)
    for (p, panel) in enumerate(feasiblepanels)
        indices = Int64[findfirst(roundinfo.adjudicators, adj) for adj in adjlist(panel)]
        Q[p, indices] = true
    end
    return Q
end

function choosesolver(solver::AbstractString)
    for (solvername, solvermod, solversym, gapsym) in SUPPORTED_SOLVERS
        if (solver == "default" || solver == solvername)
            try
                @eval using $solvermod
            catch ArgumentError
                if solver == solvername
                    error("$solversym does not appear to be installed.")
                    break
                else
                    continue
                end

            end
            println("Using solver: $solversym")
            return eval(solversym)(;gapsym=>1e-2)
        end
    end
    if solver == "default"
        error("None of Gurobi, Cbc and GLPKMathProgInterface appear to be installed.")
    else
        error("Solver must be \"gurobi\", \"cbc\" or \"glpk\" (or \"default\").")
    end
end

"""
Solves the optimization problem for score matrix `Σ` and panel membership
    matrix `Q`.
`Σ` is a matrix with `ndebates` rows and `npanels` columns, where `ndebates` is
    the number of debates and `npanels` is the number of feasible panels.
`Q` is a matrix with `npanels` rows and `nadjs` columns, where `npanels` is the
    number of feasible panels and `nadjs` is the number of adju
    ators, and
    where `Q[p,a] == 1` if panel `p` contains adjudicator `a`, and 0 if not.

Returns a list of 2-tuples, `(debate, panel)`, where `debate` is the column
    number of the debate and `panel` is the row number of the panel.
"""
function solveoptimizationproblem{T<:Real}(Σ::Matrix{T}, Q::AbstractMatrix{Bool},
        adjson::Vector{Tuple{Int,Int}}, adjsoff::Vector{Tuple{Int,Int}};
        solver="default")

    (ndebates, npanels) = size(Σ)

    modelsolver = choosesolver(solver)
    m = Model(solver=modelsolver)

    @defVar(m, X[1:ndebates,1:npanels], Bin)
    @setObjective(m, Max, sum(Σ.*X))
    @addConstraint(m, X*ones(npanels) .== 1)
    @addConstraint(m, ones(1,ndebates)*X*Q .== 1)
    for (a, d) in adjson
        @addConstraint(m, (X*Q)[d,a] == 1)
    end
    for (a, d) in adjsoff
        @addConstraint(m, (X*Q)[d,a] == 0)
    end

    @printf("There are %d panels to choose from.\n", npanels)

    @time status = solve(m)

    if status != :Optimal
        println("Error: Problem was not solved to optimality. Status was: $status")
        return (Int[], Int[])
    end

    println("Objective value: ", getObjectiveValue(m))
    allocation = findn(getValue(X))
    return allocation
end

end # module