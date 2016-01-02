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
            (:MIPGap=>:gap, :Threads=>:solverthreads, :LogToConsole=>1, :MIPFocus=>1, :TimeLimit=>:timelimit)),
    ("cbc", :Cbc, :CbcSolver,
            (:ratioGap=>:gap, :threads=>:solverthreads, :logLevel=>1, :SolveType=>1)),
    ("glpk", :GLPKMathProgInterface, :GLPKSolverMIP,
            (:tol_obj=>:gap, :msg_lev=>3)),
]

include("types.jl")
include("feasiblepanels.jl")
include("score.jl")
include("importjson.jl")
include("exportjson.jl")
include("importtabbie2.jl")
include("exporttabbie2.jl")
include("deficit.jl")
include("frontendinterface.jl")
include("debateweights.jl")

export allocateadjudicators, generatefeasiblepanels

"Top-level adjudicator allocation function."
function allocateadjudicators(roundinfo::RoundInfo; options...)
    println("feasible panels:")
    @time feasiblepanels = generatefeasiblepanels(roundinfo; options...)
    return allocateadjudicators(roundinfo, feasiblepanels; options...)
end

"Top-level adjudicator allocation function, but takes in a pre-generated set of
feasible panels."
function allocateadjudicators(roundinfo::RoundInfo, feasiblepanels::Vector{AdjudicatorPanel}; options...)

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

    if get(Dict(options), :enforceteamconflicts, false)
        println("team-adjudicator conflict conversion:")
        @time teamadjconflicts = convertteamadjconflicts(roundinfo)

        println("team-adjudicator conflict conversion (append):")
        @time append!(blockedadjs, teamadjconflicts) # these are the same to the solver
    end

    @time status, debateindices, panelindices, scores, duplicateadjindices = solveoptimizationproblem(Σ, Q, lockedadjs, blockedadjs, istrainee; options...)

    duplicateadjs = [roundinfo.adjudicators[i].id for i in duplicateadjindices]
    println("Duplicate adjudicator IDs after optimization (no trainees): $duplicateadjs")

    if status != :Optimal
        warn(STDOUT, "Problem was not solved to optimality. Status was: $status")
    end
    if status == :Infeasible
        println("Checking for incompatible constraints...")
        checkincompatibleconstraints(roundinfo)
    end

    println("conversion:")
    @time allocations = convertallocations(roundinfo.debates, feasiblepanels, debateindices, panelindices, scores)

    # println("allocate trainees:")
    # @time allocatetrainees!(allocations, roundinfo)

    return allocations
end

"""Checks the given round information for conditions that would definitely
make the problem infeasible."""
function checkincompatibleconstraints(roundinfo::RoundInfo)
    feasible = true
    for adjs in roundinfo.groupedadjs
        for (adj1, adj2) in combinations(adjs, 2)
            if conflicted(roundinfo, adj1, adj2)
                println("Incompatible constraint: $(adj1.name) and $(adj2.name) are both grouped and conflicted.")
                feasible = false
            end
        end
    end
    return feasible
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

"Resolves user options into argument for the solver."
function resolvesolveroptions(solveroptions, useroptions)
    completeuseroptions = Dict(:gap=>1.2e-2, :solverthreads=>nothing, :timelimit=>nothing) # defaults
    merge!(completeuseroptions, Dict(useroptions))
    solverargs = Tuple{Symbol,Any}[]
    for (name, value) in solveroptions
        optionvalue = isa(value, Symbol) ? completeuseroptions[value] : value
        if optionvalue == nothing
            continue
        end
        push!(solverargs, (name, optionvalue))
    end
    println("Solver arguments: $solverargs")
    return solverargs
end

"Given a user option, returns a solver for use in solving the optimization problem."
function choosesolver(solver::AbstractString; kwargs...)

    # Gurobi Cloud gets special treatment, to deal with the password bit
    if startswith(solver, "gurobicloud/")
        solver, host, password = split(solver, "/"; limit=3)
        solveroptions = SUPPORTED_SOLVERS[1][4]
        try
            @eval using Gurobi
        catch
            error("Gurobi does not appear to be installed.")
        end
        @show isdefined(:GurobiCloudSolver)
        println("Using solver: GurobiCloudSolver at $host (password $password)")
        solverargs = resolvesolveroptions(solveroptions, kwargs)
        return :GurobiCloudSolver, GurobiCloudSolver(host, password; solverargs...)
    end

    for (solvername, solvermod, solversym, solveroptions) in SUPPORTED_SOLVERS
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
            solverargs = resolvesolveroptions(solveroptions, kwargs)
            return solversym, eval(solversym)(;solverargs...)
        end
    end
    if solver == "default"
        error("None of Gurobi, Cbc and GLPKMathProgInterface appear to be installed.")
    else
        error("Solver must be \"gurobi\", \"gurobicloud/host/password\", \"cbc\" or \"glpk\" (or \"default\").")
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
        options...)

    optionsdict = Dict(options)
    (ndebates, npanels) = size(Σ)

    solver = get(optionsdict, :solver, "default")
    modeltype, modelsolver = choosesolver(solver; options...)
    m = Model(solver=modelsolver)

    println("define variables:")
    @time @defVar(m, X[1:ndebates,1:npanels], Bin)
    println("set objective:")
    @time @setObjective(m, Max, sum(Σ.*X))
    println("every debate has one panel:")
    @time @addConstraint(m, X*ones(npanels) .== 1)

    if get(optionsdict, :enforceallocateall, false)
        println("accredited adjudicators should be allocated once:")
        @time @addConstraint(m, ones(1,ndebates)*X*Q[:,~istrainee] .== 1)
        println("trainee adjudicators should be allocated at most once:")
        @time @addConstraint(m, ones(1,ndebates)*X*Q[:, istrainee] .<= 1)
    else
        println("all adjudicators should be allocated at most once:")
        @time @addConstraint(m, ones(1,ndebates)*X*Q .<= 1)
    end

    # adjudicator constraints
    println("locked adjudicators ($(length(lockedadjs))):")
    @time for (a, d) in lockedadjs
        @addConstraint(m, X[d,:]*Q[:,a] .== 1)
    end
    println("blocked adjudicators ($(length(blockedadjs))):")
    @time for (a, d) in blockedadjs
        @addConstraint(m, X[d,:]*Q[:,a] .== 0)
    end

    println("solveoptimizationproblem: Starting solver at $(now())")
    @time status = solve(m)
    println("solveoptimizationproblem: Solver done at $(now())")

    println("solveoptimizationproblem: Objective value: ", getObjectiveValue(m))
    Xval = Array{Bool}(getValue(X))
    debates, panels = findn(Xval)
    scores = Σ[Xval]

    println("solveoptimizationproblem: Checking for duplicate adjudicators:")
    @time adjoccurrences = ones(1,ndebates) * Xval * Q
    duplicateadjindices = find(x -> x > 1, adjoccurrences)

    return (status, debates, panels, scores, duplicateadjindices)
end

function anyconflict(roundinfo::RoundInfo, trainee::Adjudicator, alloc::PanelAllocation)
    for adj in adjlist(alloc)
        if conflicted(roundinfo, adj, trainee)
            return true
        end
    end
    for team in alloc.debate.teams
        if conflicted(roundinfo, team, trainee)
            return true
        end
    end
    return false
end

function allocatetrainees!(allocations::Vector{PanelAllocation}, roundinfo::RoundInfo)
    allocatedadjudicators = vcat([adjlist(alloc) for alloc in allocations]...)
    unallocatedtrainees = filter(adj -> adj.ranking <= TraineePlus && adj ∉ allocatedadjudicators, roundinfo.adjudicators)

    unallocatedpanellists = filter(adj -> adj.ranking >= PanellistMinus && adj ∉ allocatedadjudicators, roundinfo.adjudicators)
    for p in unallocatedpanellists
        @show p
        println("Unac: $(p.name)")
    end

    shuffle!(unallocatedtrainees)
    sort!(unallocatedtrainees, by=adj -> adj.ranking, rev=true) # best to worst

    # split by room size, cut rooms then merge
    bigroomallocations = filter(alloc -> numadjs(alloc) >= 5, allocations)
    smallroomallocations = filter(alloc -> numadjs(alloc) == 4, allocations)
    reallysmallroomallocations = filter(alloc -> numadjs(alloc) <= 3, allocations)

    nreallysmall = length(reallysmallroomallocations)
    println("allocatetrainees: There are $nreallysmall really small rooms (3 people).")
    if nreallysmall > 20
        nreallysmalltopick = nreallysmall - 20
        println("allocatetrainees: ... Choosing $nreallysmalltopick of them.")
        reallysmallroomallocations = sample(reallysmallroomallocations, nreallysmalltopick; replace=false)
    else
        reallysmallroomallocations = PanelAllocation[]
    end

    nsmall = length(smallroomallocations)
    println("allocatetrainees: There are $nsmall small rooms (4 people).")
    if nsmall > 37
        nsmalltopick = nsmall - 37
        println("allocatetrainees: ... Choosing $nsmalltopick of them.")
        smallroomallocations = sample(reallysmallroomallocations, nsmalltopick; replace=false)
    else
        smallroomallocations = PanelAllocation[]
    end

    allocationsgettingtrainees = [bigroomallocations; smallroomallocations; reallysmallroomallocations]
    println("allocatetrainees: There are $(length(allocations)) rooms, of which $(length(allocationsgettingtrainees)) will be allocated $(length(unallocatedtrainees)) trainees.")

    chairplusallocs = filter(alloc -> alloc.chair.ranking == ChairPlus, allocationsgettingtrainees)
    nonchairplusallocs = filter(alloc -> alloc.chair.ranking != ChairPlus, allocationsgettingtrainees)
    sort!(nonchairplusallocs, by=alloc -> alloc.chair.ranking)

    for alloc in [nonchairplusallocs; nonchairplusallocs; chairplusallocs; chairplusallocs; nonchairplusallocs; chairplusallocs]
        if length(unallocatedtrainees) == 0
            break
        end
        shelvedtrainees = Adjudicator[]
        nexttrainee = pop!(unallocatedtrainees)
        traineefound = true
        while anyconflict(roundinfo, nexttrainee, alloc)
            push!(shelvedtrainees, nexttrainee)
            if length(unallocatedtrainees) == 0
                traineefound = false
                break
            end
            nexttrainee = pop!(unallocatedtrainees)
        end
        append!(unallocatedtrainees, shelvedtrainees) # put shelved trainees back
        if traineefound
            push!(alloc.trainees, nexttrainee)
        end
    end

    finalallocatedadjudicators = vcat([adjlist(alloc) for alloc in allocations]...)
    duplicateadjs = filter(adj -> count(x -> x == adj, finalallocatedadjudicators) > 1, finalallocatedadjudicators)
    println("allocatetrainees: Duplicate adjudicators (with trainees): $duplicateadjs")
end

end # module