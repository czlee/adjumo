# Performance profiling of panel membership matrix function
# panelmembershipmatrix2 and 4 require an "index" member of Adjudicator to exist
# and be populated such that roundinfo.adjudicators[adj.index] == adj
#
push!(LOAD_PATH, joinpath(Base.source_dir(), ".."))
using ArgParse
using Adjumo
using AdjumoDataTools

function panelmembershipmatrix1(roundinfo::RoundInfo, feasiblepanels::Vector{AdjudicatorPanel})
    npanels = length(feasiblepanels)
    nadjs = numadjs(roundinfo)
    Q = zeros(npanels, nadjs)
    for (p, panel) in enumerate(feasiblepanels)
        indices = Int64[findfirst(roundinfo.adjudicators, adj) for adj in accreditedadjs(panel)]
        Q[p, indices] = true
    end
    return Q
end

function panelmembershipmatrix2(roundinfo::RoundInfo, feasiblepanels::Vector{AdjudicatorPanel})
    npanels = length(feasiblepanels)
    nadjs = numadjs(roundinfo)
    Q = zeros(npanels, nadjs)
    for (p, panel) in enumerate(feasiblepanels)
        indices = Int64[adj.index for adj in panel.adjs]
        Q[p, indices] = 1.0
    end
    return Q
end

function panelmembershipmatrix3(roundinfo::RoundInfo, feasiblepanels::Vector{AdjudicatorPanel})
    npanels = length(feasiblepanels)
    nadjs = numadjs(roundinfo)
    Q = spzeros(npanels, nadjs)
    for (p, panel) in enumerate(feasiblepanels)
        indices = Int64[findfirst(roundinfo.adjudicators, adj) for adj in accreditedadjs(panel)]
        Q[p, indices] = 1.0
    end
    return Q
end

function panelmembershipmatrix4(roundinfo::RoundInfo, feasiblepanels::Vector{AdjudicatorPanel})
    npanels = length(feasiblepanels)
    nadjs = numadjs(roundinfo)
    Q = spzeros(npanels, nadjs)
    for (p, panel) in enumerate(feasiblepanels)
        indices = Int64[adj.index for adj in panel.adjs]
        Q[p, indices] = 1.0
    end
    return Q
end

function panelmembershipmatrix5(roundinfo::RoundInfo, feasiblepanels::Vector{AdjudicatorPanel})
    npanels = length(feasiblepanels)
    nadjs = numadjs(roundinfo)
    Q = zeros(npanels, nadjs)
    for (p, panel) in enumerate(feasiblepanels)
        indices = Int64[findfirst(roundinfo.adjudicators, adj) for adj in accreditedadjs(panel)]
        Q[p, indices] = 1.0
    end
    return sparse(Q)
end

function panelmembershipmatrix6(roundinfo::RoundInfo, feasiblepanels::Vector{AdjudicatorPanel})
    npanels = length(feasiblepanels)
    nadjs = numadjs(roundinfo)
    Q = spzeros(npanels, nadjs)
    for (p, panel) in enumerate(feasiblepanels)
        for index in Int64[findfirst(roundinfo.adjudicators, adj) for adj in accreditedadjs(panel)]
            Q[p, index] = 1.0
        end
    end
    return Q
end

function panelmembershipmatrix7(roundinfo::RoundInfo, feasiblepanels::Vector{AdjudicatorPanel})
    npanels = length(feasiblepanels)
    nadjs = numadjs(roundinfo)
    Q = zeros(npanels, nadjs)
    for (p, panel) in enumerate(feasiblepanels)
        for index in Int64[findfirst(roundinfo.adjudicators, adj) for adj in accreditedadjs(panel)]
            Q[p, index] = 1.0
        end
    end
    return sparse(Q)
end

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
roundinfo = randomroundinfo(ndebates, currentround)
feasiblepanels = generatefeasiblepanels(roundinfo)

funcs = [
    panelmembershipmatrix1, # returns full matrix
    # panelmembershipmatrix2,
    # panelmembershipmatrix3, # really slow
    # panelmembershipmatrix4,
    panelmembershipmatrix5,
    # panelmembershipmatrix6, # slow
    panelmembershipmatrix7,
]

# panelmembershipmatrix1(roundinfo, feasiblepanels)
# @profile panelmembershipmatrix1(roundinfo, feasiblepanels)

# Profile.print()

A = [f(roundinfo, feasiblepanels) for f in funcs]

for i = 1:5
    for f in shuffle(funcs)
        println(f)
        @time f(roundinfo, feasiblepanels)
    end
end

for (i, a) in enumerate(A)
    @show funcs[i] sumabs(A[i])
end
for (i, j) in combinations(1:length(funcs), 2)
    @show (funcs[i], funcs[j]) sumabs(A[i] - A[j])
end
