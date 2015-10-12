"""Adjumo: Allocating Debate Judges Using Mathematical Optimization.
Top-level file.
allocate_adjudicators() is the top-level function.
"""

using JuMP
using Gurobi
using Iterators
include("score.jl")

"""
Top-level adjudicator allocation function.
`round_info` is a Dict containing all the information about the round
    (specifics to be determined)
"""
function allocate_adjudicators(round_info::Dict)
    feasible_panels = generate_feasible_panels(round_info)
    Σ = score_matrix(feasible_panels, round_info)
    Q = panel_membership_matrix(feasible_panels, round_info["nadjs"])
    allocation = solve_optimization_problem(Σ, Q)

    println("Result:")
    panelsc = collect(feasible_panels)
    for (d, p) in zip(allocation...)
        @printf("Debate %2d gets panel %5d, comprising %s\n", d, p, panelsc[p])
    end
end

"""
Generates a list of feasible panels using the information about the round.
`round_info` is a round information Dict (see above definition).

Returns a list of tuples of adjudicator indices, e.g.,
    [(4, 10, 56), (35, 13, 28), (45, 13, 39), (4, 10, 57), ...]
"""
function generate_feasible_panels(round_info::Dict)
    nchairs = round_info["ndebates"]
    nadjs = round_info["nadjs"]
    chairs = 1:nchairs
    panellists = nchairs+1:nadjs
    panellist_combs = combinations(panellists, 2)
    panels = Vector{Int64}[[c; p] for (c, p) in Iterators.product(chairs, panellist_combs)]
    return panels
end


"""
Returns the panel membership matrix for a list of feasible panels.

The panel membership matrix (denoted `Q`) will be an `npanels` by `nadjs`
matrix, where `npanels` is the total number of feasible panels, and `nadjs` is
the number of adjudicators. The element `Q[p,a]` will be 1 if adjudicator `a` is
in panel `p`, and 0 otherwise.

`feasible_panels` is a list of lists of integers, each tuple containing the indices of
    adjudicators on a panel. Each adjudicator index must be in `1:nadjs`.
`nadjs` is the number of adjudicators.
"""
function panel_membership_matrix(feasible_panels::FeasiblePanelsList, nadjs::Integer)
    npanels = length(feasible_panels)
    Q = zeros(Bool, npanels, nadjs)
    for (i, panel) in enumerate(feasible_panels)
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
    number of feasible panels and `nadjs` is the number of adjudicators, and
    where `Q[p,a] == 1` if panel `p` contains adjudicator `a`, and 0 if not.

Returns a list of 2-tuples, `(debate, panel)`, where `debate` is the column
    number of the debate and `panel` is the row number of the panel.
"""
function solve_optimization_problem{T<:Real}(Σ::Matrix{T}, Q::Matrix{Bool})

    (ndebates, npanels) = size(Σ)

    m = Model(solver=GurobiSolver(MIPGap=1e-2))
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

round_info = Dict("ndebates"=>20, "nadjs"=>60)
allocate_adjudicators(round_info)