# Functions to import from the Node.js part.
# This file is part of the Adjumo module.

export importcomponentweightsjsonintoroundinfo!, importcomponentweightsjson,
    importfeasiblepanels, parsedebatepaneljson

function importcomponentweightsjsonintoroundinfo!(rinfo::RoundInfo, io::IO)
    weights = importcomponentweightsjson(io)
    rinfo.componentweights = weights
end

function importcomponentweightsjson(io::IO)
    d = JSON.parse(io)
    return convertcomponentweightsdict(d)
end

function convertcomponentweightsdict(dict::JsonDict)
    weights = AdjumoComponentWeights()
    for (key, value) in dict
        sym = symbol(key)
        valuefloat = parse(Float64, value)
        setfield!(weights, sym, valuefloat)
    end
    return weights
end

function importfeasiblepanels(io::IO, roundinfo::RoundInfo)
    paneldicts = JSON.parse(io)
    feasiblepanels = Array{AdjudicatorPanel}(length(paneldicts))
    for (i, paneldict) in enumerate(paneldicts)
        adjs = [getobjectwithid(roundinfo.adjudicators, adjid) for adjid in paneldict["adjs"]]
        feasiblepanels[i] = AdjudicatorPanel(adjs, paneldict["np"])
    end
    return feasiblepanels
end

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
        region = [Region(r) for r in adjdict["regions"]]
        language = LanguageStatus(adjdict["language"])
        gender = PersonGender(adjdict["gender"])
        adj = Adjudicator(1, "", dudinst, ranking, region, language, gender)
        push!(adjs, adj)
    end
    panel = AdjudicatorPanel(adjs, length(adjs)-1)

    return (debate, panel)
end