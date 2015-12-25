# Adjumo: Allocating Debate Judges Using Mathematical Optimization.
# Top-level file.
# allocateadjudicators() is the top-level function.

__precompile__()

module Adjumo

using JuMP
using MathProgBase
using JSON
using StatsBase

typealias JsonDict Dict{AbstractString,Any}

SUPPORTED_SOLVERS = [
    ("gurobi", :Gurobi, :GurobiSolver,
            (:MIPGap=>:gap, :Threads=>:threads, :LogToConsole=>1, :MIPFocus=>1, :TimeLimit=>:timelimit)),
    ("cbc", :Cbc, :CbcSolver,
            (:ratioGap=>:gap, :threads=>:threads, :logLevel=>1, :SolveType=>1)),
    ("glpk", :GLPKMathProgInterface, :GLPKSolverMIP,
            (:tol_obj=>:gap, :msg_lev=>3)),
]

include("types.jl")
include("score.jl")
include("importjson.jl")
include("exportjson.jl")
include("importtabbie2.jl")
include("exporttabbie2.jl")
include("deficit.jl")

export allocateadjudicators, generatefeasiblepanels

"Top-level adjudicator allocation function."
function allocateadjudicators(roundinfo::RoundInfo; solver="default", enforceteamconflicts=false, gap=1e-2, threads=1, limitpanels=typemax(Int), timelimit=300)
    println("feasible panels:")
    @time feasiblepanels = generatefeasiblepanels(roundinfo; limitpanels=limitpanels)
    return allocateadjudicators(roundinfo, feasiblepanels; solver=solver, enforceteamconflicts=enforceteamconflicts, gap=gap, threads=threads)
end

"Top-level adjudicator allocation function, but takes in a pre-generated set of
feasible panels."
function allocateadjudicators(roundinfo::RoundInfo, feasiblepanels::Vector{AdjudicatorPanel}; solver="default", enforceteamconflicts=false, gap=1e-2, threads=1, timelimit=300)

    procstoadd = threads - nprocs()
    if procstoadd > 0
        println("Adding $procstoadd processes to make $threads processes in total")
        procsadded = addprocs(procstoadd)
    end

    println("score matrix:")
    @time Σ = scorematrix(roundinfo, feasiblepanels)

    println("panel membership matrix:")
    @time Q = panelmembershipmatrix(roundinfo, feasiblepanels)

    println("trainee indicators:")
    @time istrainee = [adj.ranking <= TraineePlus for adj in roundinfo.adjudicators]

    println("locked adjudicator constraint conversion:")
    @time lockedadjs = convertconstraints(roundinfo, roundinfo.lockedadjs)

    println("blocked adjudicator constraint conversion:")
    @time blockedadjs = convertconstraints(roundinfo, roundinfo.blockedadjs)

    if enforceteamconflicts
        println("team-adjudicator conflict conversion:")
        @time teamadjconflicts = convertteamadjconflicts(roundinfo)

        println("team-adjudicator conflict conversion (append):")
        @time append!(blockedadjs, teamadjconflicts) # these are the same to the solver
    end

    @time status, debateindices, panelindices, scores = solveoptimizationproblem(Σ, Q, lockedadjs, blockedadjs, istrainee; solver=solver, gap=gap, threads=threads)

    if status == :Infeasible
        println("Error: Problem was not solved to optimality. Status was: $status")
        checkincompatibleconstraints(roundinfo)
    end

    println("conversion:")
    @time allocations = convertallocations(roundinfo.debates, feasiblepanels, debateindices, panelindices, scores)

    if procstoadd > 0
        rmprocs(procsadded)
    end

    return allocations
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
function generatefeasiblepanels(roundinfo::RoundInfo; limitpanels::Int=typemax(Int))
    adjssorted = sort(roundinfo.adjudicators, by=adj->adj.ranking, rev=true)
    averagepanelsize = count(x -> x.ranking >= PanellistMinus, roundinfo.adjudicators) / numdebates(roundinfo)
    panels = AdjudicatorPanel[]

    if isinteger(averagepanelsize)
        panelsizes = Int[averagepanelsize]
    else
        panelsizes = Int[floor(averagepanelsize), ceil(averagepanelsize)]
    end

    function feasible(adjs)
        if panelquality(adjs) <= -20
            return false
        end
        if hasconflict(roundinfo, adjs)
            return false
        end
        for groupedadjs in roundinfo.groupedadjs
            overlap = length(adjs ∩ groupedadjs)
            if overlap != 0 && overlap != length(groupedadjs)
                return false
            end
        end
        return true
    end

    # Take a very brute force approach
    panels = AdjudicatorPanel[]
    for panelsize in panelsizes
        for adjs in combinations(adjssorted, panelsize)
            if !feasible(adjs)
                continue
            end
            possiblechairindices = find(adj -> adj.ranking == adjs[1].ranking, adjs)
            chairindex = rand(possiblechairindices)
            chair = adjs[chairindex]
            deleteat!(adjs, chairindex)
            panel = AdjudicatorPanel(chair, adjs)
            push!(panels, panel)
        end
    end

    if length(panels) > limitpanels
        println("There are $(length(panels)) feasible panels, but limiting to $limitpanels panels, picking at random.")
        panels = sample(panels, limitpanels; replace=false)
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
    Q = zeros(npanels, nadjs)
    for (p, panel) in enumerate(feasiblepanels)
        indices = Int64[findfirst(roundinfo.adjudicators, adj) for adj in adjlist(panel)]
        Q[p, indices] = 1.0
    end
    return sparse(Q)
end

"""
Converts locked/blocked adj constraints from AdjudicatorDebate to Tuple{Int,Int},
the first Int being an adjudicator index and the second Int being a debate
index.
"""
function convertconstraints(roundinfo::RoundInfo, original::Vector{AdjudicatorDebate})
    converted = Array{Tuple{Int,Int}}(length(original))
    for (i, ad) in enumerate(original)
        adjindex = findfirst(roundinfo.adjudicators, ad.adjudicator)
        debateindex = findfirst(roundinfo.debates, ad.debate)
        converted[i] = (adjindex, debateindex)
    end
    return converted
end

"""
Converts team-adj conflicts from TeamAdjudicator to Tuple{Int,Int},
the first Int being an adjudicator index, and the second Int being the debate
index of the debate that the given team is in.
"""
function convertteamadjconflicts(roundinfo::RoundInfo)
    converted = Array{Tuple{Int,Int}}(length(roundinfo.teamadjconflicts))
    for (i, ta) in enumerate(roundinfo.teamadjconflicts)
        adjindex = findfirst(roundinfo.adjudicators, ta.adjudicator)
        debateindex = findfirst(debate -> ta.team ∈ debate, roundinfo.debates)
        converted[i] = (adjindex, debateindex)
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
    return converted
end

"Converts panel allocations from indices to PanelAllocation objects"
function convertallocations(debates::Vector{Debate}, panels::Vector{AdjudicatorPanel}, debateindices::Vector{Int}, panelindices::Vector{Int}, scores::Vector{Float64})
    allocations = Array{PanelAllocation}(length(debateindices))
    for (i, (d, p, score)) in enumerate(zip(debateindices, panelindices, scores))
        debate = debates[d]
        panel = panels[p]
        allocations[i] = PanelAllocation(debate, score, chair(panel), panellists(panel), trainees(panel))
    end
    return allocations
end

"Given a user option, returns a solver for use in solving the optimization problem."
function choosesolver(solver::AbstractString; kwargs...)
    defaults = Dict(:gap=>1e-2, :threads=>1, :timelimit=>300)
    resolvedkwargs = merge(defaults, Dict(kwargs))
    for (solvername, solvermod, solversym, options) in SUPPORTED_SOLVERS
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
            solverargs = Tuple{Symbol,Any}[]
            for (name, value) in options
                push!(solverargs, (name, isa(value, Symbol) ? resolvedkwargs[value] : value))
            end
            return solversym, eval(solversym)(;solverargs...)
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
function solveoptimizationproblem{T1<:Real,T2<:Real}(Σ::Matrix{T1},
        Q::AbstractMatrix{T2}, lockedadjs::Vector{Tuple{Int,Int}},
        blockedadjs::Vector{Tuple{Int,Int}}, istrainee::Vector{Bool};
        solver="default", gap=1e-2, threads=1)

    (ndebates, npanels) = size(Σ)

    modeltype, modelsolver = choosesolver(solver; gap=gap, threads=threads)
    m = Model(solver=modelsolver)

    println("define variables:")
    @time @defVar(m, X[1:ndebates,1:npanels], Bin)
    println("set objective:")
    @time @setObjective(m, Max, sum(Σ.*X))
    println("every debate has one panel:")
    @time @addConstraint(m, X*ones(npanels) .== 1)          # each debate has exactly one panel
    println("accredited adjudicators should be allocated once:")
    @time @addConstraint(m, ones(1,ndebates)*X*Q[:,~istrainee] .== 1) # each accredited adjudicator is allocated once
    println("trainee adjudicators should be allocated at most once:")
    @time @addConstraint(m, ones(1,ndebates)*X*Q[:, istrainee] .<= 1) # each trainee adjudicator is allocated at most once

    # adjudicator constraints
    println("locked adjudicators ($(length(lockedadjs))):")
    @time for (a, d) in lockedadjs
        @addConstraint(m, X[d,:]*Q[:,a] .== 1)
    end
    println("blocked adjudicators ($(length(blockedadjs))):")
    @time for (a, d) in blockedadjs
        @addConstraint(m, X[d,:]*Q[:,a] .== 0)
    end

    println("Starting solver at $(now())")
    @time status = solve(m)
    println("Solver done at $(now())")

    if status != :Infeasible
        println("Objective value: ", getObjectiveValue(m))
        Xval = Array{Bool}(getValue(X))
        debates, panels = findn(Xval)
        scores = Σ[Xval]
    else
        debates = Int[]
        panels = Int[]
        scores = Float64[]
    end

    return (status, debates, panels, scores)
end

end # module