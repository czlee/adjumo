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
using Formatting
include("types.jl")
include("score.jl")

"""
Top-level adjudicator allocation function.
`roundinfo` is a RoundInfo instance.
"""
function allocateadjudicators(roundinfo::RoundInfo)
    feasiblepanels = generatefeasiblepanels(roundinfo)
    @time Σ = scorematrix(feasiblepanels, roundinfo)

    @time Q = panelmembershipmatrix(feasiblepanels, numadjs(roundinfo))
    debateindices, panelindices = solveoptimizationproblem(Σ, Q)

    panels = Vector{Vector{Adjudicator}}()
    for p in panelindices
        adjindices = feasiblepanels[p]
        push!(panels, adjudicatorsfromindices(roundinfo, adjindices))
    end

    return debateindices, panels
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
    filter!(panel -> !hasconflict(roundinfo, Adjudicator[roundinfo.adjudicators[a] for a in panel]), panels) # remove panels with adj-adj conflicts
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

    # TODO add team-adj conflict constraint

    @printf("There are %d panels to choose from.\n", npanels)

    @time status = solve(m)

    println("Objective value: ", getObjectiveValue(m))
    allocation = findn(getValue(X))
    return allocation
end

function showdebatedetail(roundinfo::RoundInfo, debate::Vector{Team}, panel::Vector{Adjudicator})
    println("Teams:")
    for team in debate
        printfmtln("   {:<20}     {:<10}  {:1} {:<3} {:<6}",
                team.name, team.institution.code, abbr(team.gender), abbr(team.language), abbr(team.region))
    end
    println("Adjudicators:")
    for adj in panel
        printfmtln("   {:<20}  {:<2} {:<10}  {:1} {:<3} {}",
                adj.name, abbr(adj.ranking), adj.institution.code, abbr(adj.gender), abbr(adj.language), join([abbr(r) for r in adj.regions], ","))
    end
    println("Conflicts:")
    for (team, adj) in product(debate, panel)
        if conflicted(roundinfo, team, adj)
            printfmtln("   {} conflicts with {}", adj.name, team.name)
        end
    end
    for (adj1, adj2) in subsets(panel, 2)
        if conflicted(roundinfo, adj1, adj2)
            printfmtln("   {} conflicts with {}", adj1.name, adj2.name)
        end
    end
    println("History:")
    for (team, adj) in product(debate, panel)
        history = roundsseen(roundinfo, team, adj)
        if length(history) > 0
            printfmtln("   {} saw {} in round{} {}", adj.name, team.name,
                    (length(history) > 1) ? "s" : "", join([string(r) for r in history], ", "))
        end
    end
    for (adj1, adj2) in subsets(panel, 2)
        history = roundsseen(roundinfo, adj1, adj2)
        if length(history) > 0
            printfmtln("   {} was with {} in round{} {}", adj1.name, adj2.name,
                    (length(history) > 1) ? "s" : "", join([string(r) for r in history], ", "))
        end
    end
    println("Scores:")
    components = [
        ("Panel quality", :quality, panelquality(panel)),
        ("Regional representation", :regional, panelregionalrepresentationscore(debate, panel)),
        ("Team-adj history", :teamhistory, teamadjhistoryscore(roundinfo, debate, panel)),
        ("Adj-adj history", :adjhistory, adjadjhistoryscore(roundinfo, panel)),
        ("Team-adj conflicts", :teamconflict, teamadjconflictsscore(roundinfo, debate, panel)),
        ("Adj-adj conflicts", :adjconflict, adjadjconflictsscore(roundinfo, panel)),
    ]
    for component in components
        name, weightfield, score = component
        weight = getfield(roundinfo.weights, weightfield)
        printfmtln("{:>25}: {:>9.3f}  {:>12.3f}", name, score, score * weight)
    end
    printfmtln("{:>25}:            {:>12.3f}", "Overall", score(roundinfo, debate, panel))
    println()
end
showdebatedetail(roundinfo::RoundInfo, debateindex::Int, panel::Vector{Adjudicator}) = showdebatedetail(roundinfo, roundinfo.debates[debateindex], panel)

# Start here

include("random.jl")
@time begin
    ndebates = 10
    currentround = 5
    weights = AdjumoWeights()
    weights.quality = 1
    weights.regional = 1
    weights.language = 1
    weights.gender = 1
    weights.teamhistory = 100
    weights.adjhistory = 100
    weights.teamconflict = 1e6
    weights.adjconflict = 1e6
    roundinfo = randomroundinfo(ndebates, currentround)
    roundinfo.weights = weights
end

debateindices, panels = allocateadjudicators(roundinfo)

println("Result:")
for (d, panel) in zip(debateindices, panels)
    showdebatedetail(roundinfo, d, panel)
end
