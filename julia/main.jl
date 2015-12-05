# Adjumo: Allocating Debate Judges Using Mathematical Optimization.
# Top-level file.
# allocateadjudicators() is the top-level function.

using JuMP
using Iterators
using Formatting
using ArgParse
include("types.jl")
include("score.jl")

# The solvers are imported below, after arguments are parsed.

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
function allocateadjudicators(roundinfo::RoundInfo)

    feasible = checkfeasibility(roundinfo)
    if !feasible
        println("Error: Incompatible constraints found.")
        return (Int[], AdjudicatorPanel[])
    end

    @time feasiblepanels = generatefeasiblepanels(roundinfo)
    println("Score matrix:")
    @time Σ = scorematrix(feasiblepanels, roundinfo)
    @profile scorematrix(feasiblepanels, roundinfo)

    Q = panelmembershipmatrix(feasiblepanels, roundinfo)
    adjson = convertconstraints(roundinfo.adjudicators, roundinfo.lockedadjs)
    adjsoff = convertconstraints(roundinfo.adjudicators, roundinfo.blockedadjs)
    @time debateindices, panelindices = solveoptimizationproblem(Σ, Q, adjson, adjsoff)

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
                printfmtln("Error: {} and {} are both forced to judge together and conflicted.",
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
    panels = AdjudicatorPanel[AdjudicatorPanel(c, p) for (c, p) in Iterators.product(chairs, panellistcombs)]

    # panels with judges that conflict with each other are not feasible
    filter!(panel -> !hasconflict(roundinfo, panel), panels) # remove panels with adj-adj conflicts

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
function panelmembershipmatrix(feasiblepanels::Vector{AdjudicatorPanel}, roundinfo::RoundInfo)
    npanels = length(feasiblepanels)
    nadjs = numadjs(roundinfo)
    Q = spzeros(Bool, npanels, nadjs)
    for (i, panel) in enumerate(feasiblepanels)
        Q[i, indices(roundinfo, panel)] = 1
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
function solveoptimizationproblem{T<:Real}(Σ::Matrix{T}, Q::AbstractMatrix{Bool}, adjson::Vector{Tuple{Int,Int}}, adjsoff::Vector{Tuple{Int,Int}})

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

function showdebatedetail(roundinfo::RoundInfo, debateindex::Int, panel::AdjudicatorPanel)
    debate = roundinfo.debates[debateindex]
    debateweight = roundinfo.debateweights[debateindex]
    println("== Debate $debateindex ==")

    println("Teams:")
    for team in debate
        printfmtln("   {:<22}     {:<20}  {:1} {:<3} {:<5}",
                team.name, team.institution.code, abbr(team.gender), abbr(team.language), abbr(team.region))
    end
    drc, teamregionsordered = debateregionclass(debate)
    printfmtln("   {}: {}", drc, join([abbr(r) for r in teamregionsordered], ", "))

    println("Adjudicators:")
    for (role, adj) in rolelist(panel)
        adjname = adj.name * role
        printfmtln("   {:<22}  {:<2} {:<20}  {:1} {:<3} {}",
                adjname, abbr(adj.ranking), adj.institution.code, abbr(adj.gender), abbr(adj.language), join([abbr(r) for r in adj.regions], ","))
    end

    println("Conflicts:")
    for (team, adj) in product(debate, adjlist(panel))
        if conflicted(roundinfo, team, adj)
            printfmtln("   {} conflicts with {}", adj.name, team.name)
        end
    end
    for (adj1, adj2) in subsets(adjlist(panel), 2)
        if conflicted(roundinfo, adj1, adj2)
            printfmtln("   {} conflicts with {}", adj1.name, adj2.name)
        end
    end

    println("History:")
    for (team, adj) in product(debate, adjlist(panel))
        history = roundsseen(roundinfo, team, adj)
        if length(history) > 0
            printfmtln("   {} saw {} in round{} {}", adj.name, team.name,
                    (length(history) > 1) ? "s" : "", join([string(r) for r in history], ", "))
        end
    end
    for (adj1, adj2) in subsets(adjlist(panel), 2)
        history = roundsseen(roundinfo, adj1, adj2)
        if length(history) > 0
            printfmtln("   {} was with {} in round{} {}", adj1.name, adj2.name,
                    (length(history) > 1) ? "s" : "", join([string(r) for r in history], ", "))
        end
    end

    println("Constraints:")
    for adj in lockedadjs(roundinfo, debateindex)
        println("   $(adj.name) is locked to this debate")
    end
    for adj in blockedadjs(roundinfo, debateindex)
        printfmtln("   $(adj.name) is blocked from this debate")
    end
    for adjs in groupedadjs(roundinfo, adjlist(panel))
        printfmtln("   {} are grouped together", join([adj.name for adj in adjs], ", "))
    end

    println("Scores:                          raw      weighted")
    components = [
        ("Panel quality", :quality, panelquality(panel)),
        ("Regional representation", :regional, panelregionalrepresentationscore(debate, panel)),
        ("Language representation", :language, panellanguagerepresentationscore(debate, panel)),
        ("Gender representation", :gender, panelgenderrepresentationscore(debate, panel)),
        ("Team-adj history", :teamhistory, teamadjhistoryscore(roundinfo, debate, panel)),
        ("Adj-adj history", :adjhistory, adjadjhistoryscore(roundinfo, panel)),
        ("Team-adj conflicts", :teamconflict, teamadjconflictsscore(roundinfo, debate, panel)),
        ("Adj-adj conflicts", :adjconflict, adjadjconflictsscore(roundinfo, panel)),
    ]
    for component in components
        name, weightfield, score = component
        weight = getfield(roundinfo.componentweights, weightfield)
        printfmtln("{:>25}: {:>9.3f}  {:>12.3f}", name, score, score * weight)
    end
    debatescore = score(roundinfo, debate, panel)
    printfmtln("{:>25}:            {:>12.3f}  ({:>6.3f})  {:>12.3f}", "Overall", debatescore, debateweight, debatescore * debateweight)
    println()
end

function showconstraints(roundinfo::RoundInfo)
    println("Adjudicator constraints:")
    for (adj1, adj2) in roundinfo.adjadjconflicts
        printfmtln("   {} and {} conflict with each other", adj1.name, adj2.name)
    end
    for (team, adj) in roundinfo.teamadjconflicts
        printfmtln("   {} conflicts with {}", adj.name, team.name)
    end
    for (adj, debateindex) in roundinfo.lockedadjs
        debatestr = join([team.name for team in roundinfo.debates[debateindex]], ", ")
        printfmtln("   {} is locked to debate [{}]", adj.name, debatestr)
    end
    for (adj, debateindex) in roundinfo.blockedadjs
        debatestr = join([team.name for team in roundinfo.debates[debateindex]], ", ")
        printfmtln("   {} is blocked from debate [{}]", adj.name, debatestr)
    end
    for adjs in roundinfo.groupedadjs
        printfmtln("   {} are grouped together", join([adj.name for adj in adjs], ", "))
    end
    println()
end
