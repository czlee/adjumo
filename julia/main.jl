# Adjumo: Allocating Debate Judges Using Mathematical Optimization.
# Top-level file.
# allocateadjudicators() is the top-level function.

# Solvers. Comment in one of the following three lines, depending on which
# solver you want to use.
using Gurobi
# using Cbc
# using GLPKMathProgInterface

using JuMP
using Iterators
include("types.jl")
include("score.jl")

"""
Top-level adjudicator allocation function.
`roundinfo` is a RoundInfo instance.
"""
function allocateadjudicators(roundinfo::RoundInfo)
    feasiblepanels = generatefeasiblepanels(roundinfo)
    Σ = scorematrix(feasiblepanels, roundinfo)

    Q = panelmembershipmatrix(feasiblepanels, numadjs(roundinfo))
    allocation = solveoptimizationproblem(Σ, Q)

    println("Result:")
    panelsc = collect(feasiblepanels)
    for (d, p) in zip(allocation...)
        @printf("Debate %2d gets panel %5d, comprising %s\n", d, p, panelsc[p])
    end
end

"""
Generates a list of feasible panels using the information about the round.
`roundinfo` is a RoundInfo instance.

Returns a list of tuples of adjudicator indices, e.g.,
    [(4, 10, 56), (35, 13, 28), (45, 13, 39), (4, 10, 57), ...]
"""
function generatefeasiblepanels(roundinfo::RoundInfo)
    nchairs = numdebates(roundinfo)
    nadjs = numadjs(roundinfo)
    chairs = 1:nchairs
    panellists = nchairs+1:nadjs
    panellistcombs = combinations(panellists, 2)
    panels = Vector{Int64}[[c; p] for (c, p) in Iterators.product(chairs, panellistcombs)]
    return panels
end


"""
Returns the panel membership matrix for a list of feasible panels.

The panel membership matrix (denoted `Q`) will be an `npanels` by `nadjs`
matrix, where `npanels` is the total number of feasible panels, and `nadjs` is
the number of adjudicators. The element `Q[p,a]` will be 1 if adjudicator `a` is
in panel `p`, and 0 otherwise.

`feasiblepanels` is a list of lists of integers, each tuple containing the indices of
    adjudicators on a panel. Each adjudicator index must be in `1:nadjs`.
`nadjs` is the number of adjudicators.
"""
function panelmembershipmatrix(feasiblepanels::FeasiblePanelsList, nadjs::Integer)
    npanels = length(feasiblepanels)
    Q = zeros(Bool, npanels, nadjs)
    for (i, panel) in enumerate(feasiblepanels)
        Q[i, panel] = 1
    end
    return Q
end

"""
Solves the optimization problem for score matrix `Σ` and panel membership
    matrix.
`Σ` is a matrix with `ndebates` rows and `npanels` columns, where `ndebates` is
    the number of debates and `npanels` is the number of feasible panels.
`Q` is a matrix with `npanels` rows and `nadjs` columns, where `npanels` is the
    number of feasible panels and `nadjs` is the number of adju
    ators, and
    where `Q[p,a] == 1` if panel `p` contains adjudicator `a`, and 0 if not.

Returns a list of 2-tuples, `(debate, panel)`, where `debate` is the column
    number of the debate and `panel` is the row number of the panel.
"""
function solveoptimizationproblem{T<:Real}(Σ::Matrix{T}, Q::Matrix{Bool})

    (ndebates, npanels) = size(Σ)

    if isdefined(:GurobiSolver)
        m = Model(solver=GurobiSolver(MIPGap=1e-2))
    elseif isdefined(:CbcSolver)
        m = Model(solver=CbcSolver(ratioGap=1e-2))
    elseif isdefined(:GLPKSolverMIP)
        m = Model(solver=GLPKSolverMIP(tol_obj=1e-2))
    else
        error("Either Gurobi, Cbc or GLPK should be used.")
    end

    @defVar(m, X[1:ndebates,1:npanels], Bin)
    @setObjective(m, Max, sum(Σ.*X))
    @addConstraint(m, X*ones(npanels) .== 1)
    @addConstraint(m, ones(1,ndebates)*X*Q .== 1)

    @printf("There are %d panels to choose from.\n", npanels)

    @time status = solve(m)

    println("Objective value: ", getObjectiveValue(m))
    allocation = findn(getValue(X))
    return allocation
end

ndebates = 10
nadjs = 3ndebates
nteams = 4ndebates
ninstitutions = 30

institutions = [Institution("Institution $(i)") for i = 1:ninstitutions]
teams = [Team("Team $(i)", rand(institutions)) for i = 1:nteams]
adjudicators = [Adjudicator("Adjudicator $(i)", rand(institutions), rand([instances(Wudc2015AdjudicatorRank)...]))
        for i = 1:nadjs]
sort!(adjudicators, by=adj->adj.ranking, rev=true)
teams_shuffled = reshape(shuffle(teams), (4, ndebates))
debates = [(teams_shuffled[:,i]...) for i in 1:ndebates]

roundinfo = RoundInfo(institutions, teams, adjudicators, debates)
allocateadjudicators(roundinfo)