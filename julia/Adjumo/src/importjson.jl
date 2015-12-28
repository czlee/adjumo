# Functions to import from the Node.js part.
# This file is part of the Adjumo module.

export importsupplementaryinfofromjson!, importfeasiblepanels, parsedebatepaneljson,
    importcomponentweightsjson!, importblockedadjs!, importlockedadjs!, importgroupedadjs!

function importsupplementaryinfofromjson!(rinfo::RoundInfo, directory::AbstractString)
    importjsonfile!(importdebateweights!, "debate-importances.json", rinfo, directory)
    importjsonfile!(importcomponentweights!, "allocation-config.json", rinfo, directory)
    importjsonfile!(importlockedadjs!, "lockedadjs.json", rinfo, directory)
    importjsonfile!(importblockedadjs!, "blockedadjs.json", rinfo, directory)
    importjsonfile!(importgroupedadjs!, "grouped-adjs.json", rinfo, directory)
end

function importjsonfile!(func::Function, filename::AbstractString, rinfo::RoundInfo, directory::AbstractString)
    filename = joinpath(directory, filename)
    file = try
        open(filename)
    catch e
        if isa(e, SystemError)
            warn(STDOUT, "Could not open $filename, skipping: $(Libc.strerror(e.errnum))")
        else
            throw(e)
        end
    end
    if isa(file, IO)
        func(rinfo, file)
        close(file)
    end
end

function importcomponentweights!(rinfo::RoundInfo, io::IO)
    weights = importcomponentweights(io)
    rinfo.componentweights = weights
end

function importcomponentweights(io::IO)
    d = JSON.parse(io)
    weights = AdjumoComponentWeights()
    for (key, value) in d
        sym = symbol(key)
        valuefloat = parse(Float64, value)
        setfield!(weights, sym, valuefloat)
    end
    return weights
end

function importdebateweights!(rinfo::RoundInfo, io::IO)
    d = JSON.parse(io)
    for (kstr, vstr) in d
        debateid = parse(Int, kstr)
        weight = parse(Float64, vstr)
        debate = getobjectwithid(rinfo.debates, debateid)
        debate.weight = weight
    end
end

function importfeasiblepanels(io::IO, rinfo::RoundInfo)
    paneldicts = JSON.parse(io)
    feasiblepanels = Array{AdjudicatorPanel}(length(paneldicts))
    for (i, paneldict) in enumerate(paneldicts)
        adjs = [getobjectwithid(rinfo.adjudicators, adjid) for adjid in paneldict["adjs"]]
        feasiblepanels[i] = AdjudicatorPanel(adjs, paneldict["np"])
    end
    return feasiblepanels
end

function importadjudicatordebates!(f::Function, name::AbstractString, rinfo::RoundInfo, io::IO)
    d = JSON.parse(io)
    data = d["data"]
    for datum in data
        datatype = datum["type"]
        if datatype != "adjudicatordebate"
            warn(STDOUT, "Object of wrong type in $name file: $datatype, expected adjudicatordebate")
            continue
        end
        debatedict = datum["relationships"]["debate"]["data"]
        debatetype = debatedict["type"]
        if debatetype != "debate"
            warn(STDOUT, "$name file: adjudicatordebate's debate has wrong type: $debatetype")
            continue
        end
        adjdict = datum["relationships"]["adjudicator"]["data"]
        adjtype = adjdict["type"]
        if adjtype != "adjudicator"
            warn(STDOUT, "$name file: adjudicatordebate's adjudicator has wrong type: $adjtype")
            continue
        end
        debateid = parse(Int, debatedict["id"])
        adjid = parse(Int, adjdict["id"])
        debate = getobjectwithid(rinfo.debates, debateid)
        adj = getobjectwithid(rinfo.adjudicators, adjid)
        f(rinfo, adj, debate)
    end
end

"Updates the given RoundInfo with grouped adjudicators from the given JSON file."
function importgroupedadjs!(rinfo::RoundInfo, io::IO)
    d = JSON.parse(io)
    data = d["data"]
    for datum in data
        datatype = datum["type"]
        if datatype != "groupedadjudicators"
            warn(STDOUT, "Object of wrong type in grouped adjudicators file: $datatype, expected groupedadjudicators")
            continue
        end
        adjdicts = datum["relationships"]["adjudicators"]["data"]
        adjs = Adjudicator[]
        for adjdict in adjdicts
            adjtype = adjdict["type"]
            if adjtype != "adjudicator"
                warn(STDOUT, "groupedadjudicators's adjudicator has wrong type: $adjtype, expected adjudicator")
                continue
            end
            adjid = parse(Int, adjdict["id"])
            adj = getobjectwithid(rinfo.adjudicators, adjid)
            push!(adjs, adj)
        end
        addgroupedadjs!(rinfo, adjs)
    end
end

importblockedadjs!(rinfo::RoundInfo, io::IO) = importadjudicatordebates!(addblockedadj!, "blocked adjudicators", rinfo, io)
importlockedadjs!(rinfo::RoundInfo, io::IO) = importadjudicatordebates!(addlockedadj!, "locked adjudicators", rinfo, io)

"""Parses a JSON string designed to generate quickly quality and representation
scores. Returns a mock Debate and mock AdjudicatorPanel, which will have the
correct ranking (for adjudicators), region, langauge and gender, but nothing
else."""
function parsedebatepaneljson(s::AbstractString)
    d = JSON.parse(s)
    dudinst = Institution(1, "", "", NoRegion)

    teams = Team[]
    for teamdict in d["teams"]
        region = Region(teamdict["region"])
        language = LanguageStatus(teamdict["language"])
        gender = TeamGender(teamdict["gender"])
        team = Team(1, "", dudinst, region, language, gender)
        push!(teams, team)
    end
    debate = Debate(1, teams)

    adjs = Adjudicator[]
    for adjdict in d["adjudicators"]
        ranking = Wudc2015AdjudicatorRank(adjdict["ranking"])
        if haskey(adjdict, "regions")
            regions = [Region(r) for r in adjdict["regions"]]
        else
            # TODO remove this redundant one when node.js part is fixed
            regions = [Region(adjdict["region"])]
        end

        language = LanguageStatus(adjdict["language"])
        gender = PersonGender(adjdict["gender"])
        adj = Adjudicator(1, "", dudinst, ranking, regions, language, gender)
        push!(adjs, adj)
    end
    panel = AdjudicatorPanel(adjs, length(adjs)-1)

    return (debate, panel)
end