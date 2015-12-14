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

function convertteamadjconflicts(roundinfo::RoundInfo)
    converted = Vector{Tuple{Int,Int}}(length(roundinfo.teamadjconflicts))
    for (i, (team, adj)) in enumerate(roundinfo.teamadjconflicts)
        debateindex = findfirst(debate -> team ∈ debate, roundinfo.debates)
        converted[i] = (findfirst(roundinfo.adjudicators, adj), debateindex)
    end
    for inst in roundinfo.institutions
        teamindices = find(team -> team.institution == inst, roundinfo.teams)
        adjindices = find(adj -> adj.institution == inst, roundinfo.adjudicators)
        toappend = Array{Tuple{Int,Int}}(length(adjindices), length(teamindices))
        for (j, teamindex) in enumerate(teamindices)
            team = roundinfo.teams[teamindex]
            debateindex = findfirst(debate -> team ∈ debate, roundinfo.debates)
            for (i, adjindex) in enumerate(adjindices)
                toappend[i,j] = (adjindex, debateindex)
            end
        end
        append!(converted, toappend[:])
    end
    @show size(converted)
    @show converted
    return converted
end

"Top-level adjudicator allocation function."
function allocateadjudicators(roundinfo::RoundInfo; solver="default", enforceteamconflicts=false)

    println("panels and score:")
    @time feasiblepanels = generatefeasiblepanels(roundinfo)
    @time Σ = scorematrix(roundinfo, feasiblepanels)
    @time Q = panelmembershipmatrix(roundinfo, feasiblepanels)
    @time istrainee = [adj.ranking <= TraineePlus for adj in roundinfo.adjudicators]

    println("constraints:")
    @time lockedadjs = convertconstraints(roundinfo.adjudicators, roundinfo.lockedadjs)
    @time blockedadjs = convertconstraints(roundinfo.adjudicators, roundinfo.blockedadjs)

    if enforceteamconflicts
        @time teamadjconflicts = convertteamadjconflicts(roundinfo)
        @time append!(blockedadjs, teamadjconflicts) # these are the same to the solver
    end

    @time status, debateindices, panelindices = solveoptimizationproblem(Σ, Q, lockedadjs, blockedadjs, istrainee; solver=solver)

    if status != :Optimal
        println("Error: Problem was not solved to optimality. Status was: $status")
        checkincompatibleconstraints(roundinfo)
    end

    panels = AdjudicatorPanel[feasiblepanels[p] for p in panelindices]
    return debateindices, panels
end


"""Checks the given round information for conditions that would definitely
make the problem infeasible."""
function checkincompatibleconstraints(roundinfo::RoundInfo)
    feasible = true
    for adjs in roundinfo.groupedadjs
        for (adj1, adj2) in combinations(adjs, 2)
            if conflicted(roundinfo, adj1, adj2)
                println("Error: $(adj1.name) and $(adj2.name) are both grouped and conflicted.")
                feasible = false
            end
        end
    end
    return feasible
end

"""
Generates a list of feasible panels using the information about the round.
Returns a list of AdjudicatorPanel instances.
"""
function generatefeasiblepanels(roundinfo::RoundInfo)
    nchairs = numdebates(roundinfo)

    adjssorted = sort(roundinfo.adjudicators, by=adj->adj.ranking, rev=true)
    chairs = adjssorted[1:nchairs]
    panellists = adjssorted[nchairs+1:end]
    panellistcombs = combinations(panellists, 2)
    panels = AdjudicatorPanel[AdjudicatorPanel(c, [p...]) for c in chairs, p in panellistcombs][:]

    accreditedadjs = filter(x -> x.ranking >= PanellistMinus, adjssorted)
    chairs = accreditedadjs[1:nchairs]
    panellists = accreditedadjs[nchairs+1:end]
    accreditedpairs = AdjudicatorPanel[AdjudicatorPanel(c, [p]) for c in chairs, p in panellists][:]
    append!(panels, accreditedpairs)

    # panels with judges that conflict with each other are not feasible
    panels = filter(panel -> !hasconflict(roundinfo, panel), panels) # remove panels with adj-adj conflicts

    # panels with some but not all of a list of judges that must judge together are not feasible
    for adjs in roundinfo.groupedadjs
        filter!(panel -> count(a -> a ∈ adjlist(panel), adjs) ∈ [0, length(adjs)], panels)
    end

    println("There are $(length(panels)) panels to choose from.")

    return panels
end

"""
Returns the panel membership matrix for a list of feasible panels.

The returned matrix `Q` will have one row for each panel and one column for each
adjudicator. `Q[p,a]` is 1 if adjudicator `a` is in panel `p`, 0 otherwise.
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

"Given a user option, returns a solver for use in solving the optimization problem."
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
`Σ` has one row for each debate and one column for each panel, and `Σ[d,p]` is
    the score achieved when allocating panel `p` to debate `d`.
`Q` has one row for each panel and one column for each adjudicator, and `Q[p,a]`
    indicates whether adjudicator `a` is in panel `p` (true or false).
`lockedadjs` and `blockedadjs` are lists of tuples `(a, d)`, each element
    indicating that adjudicator `a` is locked to or blocked from (respectively)
    debate `d`.
`istrainee` has one element for each adjudicator, and `istrainee[a]` indicates
    whether adjudicator `a` has a trainee ranking (true or false).

Returns a list of 2-tuples, `(d, p)`, where `d` is the column number of the
    debate and `p` is the row number of the panel in `Σ`.
"""
function solveoptimizationproblem{T<:Real}(Σ::Matrix{T}, Q::AbstractMatrix{Bool},
        lockedadjs::Vector{Tuple{Int,Int}}, blockedadjs::Vector{Tuple{Int,Int}},
        istrainee::Vector{Bool}; solver="default")

    (ndebates, npanels) = size(Σ)

    modelsolver = choosesolver(solver)
    m = Model(solver=modelsolver)

    @defVar(m, X[1:ndebates,1:npanels], Bin)
    @setObjective(m, Max, sum(Σ.*X))
    @addConstraint(m, X*ones(npanels) .== 1)          # each debate has exactly one panel
    @addConstraint(m, sum(X*Q[:,~istrainee],1) .== 1) # each accredited adjudicator is allocated once
    @addConstraint(m, sum(X*Q[:, istrainee],1) .<= 1) # each trainee adjudicator is allocated at most once

    # adjudicator constraints
    for (a, d) in lockedadjs
        @addConstraint(m, X[d,:]*Q[:,a] .== 1)
    end
    for (a, d) in blockedadjs
        @addConstraint(m, X[d,:]*Q[:,a] .== 0)
    end


    @time status = solve(m)

    if status == :Optimal
        println("Objective value: ", getObjectiveValue(m))
        debates, panels = findn(getValue(X))
    else
        debates = Int[]
        panels = Int[]
    end

    return (status, debates, panels)
end

end # module