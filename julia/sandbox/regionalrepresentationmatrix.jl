# Performance profiling of panel membership matrix function
# panelmembershipmatrix2 requires an "index" member of Adjudicator to exist and
# be populated such that roundinfo.adjudicators[adj.index] == adj

push!(LOAD_PATH, joinpath(Base.source_dir(), ".."))
using ArgParse
using Adjumo
import Adjumo: DebateRegionClass, debateregionclass, RegionClassA, RegionClassB, RegionClassC, RegionClassD, RegionClassE
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

function regionalrepresentationmatrix1(feasiblepanels::Vector{AdjudicatorPanel}, roundinfo::RoundInfo)
    ndebates = numdebates(roundinfo)
    npanels = length(feasiblepanels)

    teamregions = Vector{Vector{Region}}(ndebates)
    for (i, debate) in enumerate(roundinfo.debates)
        teamregions[i] = Region[t.region for t in debate.teams]
    end

    panelinfos = Vector{Tuple{Int, Vector{Region}}}(npanels)
    for (i, panel) in enumerate(feasiblepanels)
        panelinfos[i] = (numadjs(panel), vcat(Vector{Region}[adj.regions for adj in accreditedadjs(panel)]...))
    end

    βr = Matrix{Float64}(ndebates, npanels)
    for (p, (nadjs, adjregions)) in enumerate(panelinfos), (d, tr) in enumerate(teamregions)
        βr[d,p] = panelregionalrepresentationscore1(tr, adjregions, nadjs)
    end
    return βr
end

function regionalrepresentationmatrix2(feasiblepanels::Vector{AdjudicatorPanel}, roundinfo::RoundInfo)
    ndebates = numdebates(roundinfo)
    npanels = length(feasiblepanels)

    debateinfos = Vector{Tuple{DebateRegionClass, Vector{Region}}}(ndebates)
    for (i, debate) in enumerate(roundinfo.debates)
        teamregions = Region[t.region for t in debate.teams]
        debateinfos[i] = debateregionclass(teamregions)
    end

    panelinfos = Vector{Tuple{Int, Vector{Region}}}(npanels)
    for (i, panel) in enumerate(feasiblepanels)
        panelinfos[i] = (numadjs(panel), vcat(Vector{Region}[adj.regions for adj in accreditedadjs(panel)]...))
    end

    βr = Matrix{Float64}(ndebates, npanels)
    for (p, (nadjs, ar)) in enumerate(panelinfos), (d, (drc, tr)) in enumerate(debateinfos)
        βr[d,p] = panelregionalrepresentationscore2(drc, tr, ar, nadjs)
    end
    return βr
end

function panelregionalrepresentationscore1(teamregions::Vector{Region}, adjregions::Vector{Region}, nadjs::Int)
    regionclass, teamregionsordered = debateregionclass(teamregions)
    cost = 0

    if nadjs == 3

        if regionclass == RegionClassA
            # There must be at least two regions on the panel.
            costfactor = 10
            if length(unique(adjregions)) < 2
                cost += 20
            end

        elseif regionclass == RegionClassB
            costfactor = 100
            for tr in teamregionsordered
                if tr ∉ adjregions
                    cost += 20
                end
            end
            if all([ar ∈ teamregionsordered for ar in adjregions])
                cost += 100
            end

        elseif regionclass == RegionClassC
            costfactor = 80
            for tr in teamregionsordered
                if tr ∉ adjregions
                    cost += 10
                end
            end
            if all([ar ∈ teamregionsordered for ar in adjregions])
                cost += 80
            end

        elseif regionclass == RegionClassD
            costfactor = 60
            for tr in teamregionsordered
                if tr ∉ adjregions
                    cost += 40
                end
            end

        elseif regionclass == RegionClassE
            costfactor =  60
            externaladjs = count(ar -> ar ∉ teamregionsordered, adjregions)
            if externaladjs == 0
                cost += 30
            elseif externaladjs == 1
                cost += 10
            end
            if length(teamregionsordered) < 2
                cost += 5
            end

        end


    elseif nadjs == 2
        return -0.1

    elseif nadjs == 4
        return -0.1


    elseif nadjs == 1
        return -0.1

    else
        return -0.1

    end

    return -costfactor * cost

end

function panelregionalrepresentationscore2(regionclass::DebateRegionClass, teamregionsordered::Vector{Region}, adjregions::Vector{Region}, nadjs::Int)
    cost = 0

    if nadjs == 3

        if regionclass == RegionClassA
            # There must be at least two regions on the panel.
            costfactor = 10
            if length(unique(adjregions)) < 2
                cost += 20
            end

        elseif regionclass == RegionClassB
            costfactor = 100
            for tr in teamregionsordered
                if tr ∉ adjregions
                    cost += 20
                end
            end
            if all([ar ∈ teamregionsordered for ar in adjregions])
                cost += 100
            end

        elseif regionclass == RegionClassC
            costfactor = 80
            for tr in teamregionsordered
                if tr ∉ adjregions
                    cost += 10
                end
            end
            if all([ar ∈ teamregionsordered for ar in adjregions])
                cost += 80
            end

        elseif regionclass == RegionClassD
            costfactor = 60
            for tr in teamregionsordered
                if tr ∉ adjregions
                    cost += 40
                end
            end

        elseif regionclass == RegionClassE
            costfactor =  60
            externaladjs = count(ar -> ar ∉ teamregionsordered, adjregions)
            if externaladjs == 0
                cost += 30
            elseif externaladjs == 1
                cost += 10
            end
            if length(teamregionsordered) < 2
                cost += 5
            end

        end


    elseif nadjs == 2
        return -0.1

    elseif nadjs == 4
        return -0.1


    elseif nadjs == 1
        return -0.1

    else
        return -0.1

    end

    return -costfactor * cost

end


ndebates = args["ndebates"]
currentround = args["currentround"]
roundinfo = randomroundinfo(ndebates, currentround)
feasiblepanels = generatefeasiblepanels(roundinfo)

funcs = [
    regionalrepresentationmatrix1,
    regionalrepresentationmatrix2
]

A = [f(feasiblepanels, roundinfo) for f in funcs]

for i = 1:5
    for f in shuffle(funcs)
        println(f)
        @time f(feasiblepanels, roundinfo)
    end
end

for (i, a) in enumerate(A)
    @show funcs[i] sumabs(A[i])
end
for (i, j) in combinations(1:length(funcs), 2)
    @show (funcs[i], funcs[j]) sumabs(A[i] - A[j])
end
