# Function that imports a JSON file output by the Tabbie2 system.
#
# This code is specialized to extract just the info it requires from Tabbie2's
# output. The interface between Tabbie2 and Adjumo is designed more to make
# export easy for Tabbie2 than it is to represent the actual information that
# needs to traverse the interface.

using JSON

typealias JsonDict Dict{AbstractString,Any}

function importtabbiejson(io::IO)
    d = JSON.parse(io)
    return converttabbiejson(d)
end

function hasobjectwithid(v::Vector, id::Int)
    return findfirst(x -> x.id == id, v) > 0
end

function findobjectwithid(v::Vector, id::Int)
    return findfirst(x -> x.id == id, v)
end

function getobjectwithid{T}(v::Vector{T}, id::Int)
    index = findfirst(x -> x.id == id, v)
    if index == 0
        error("$T with ID $id does not exist")
    end
    return v[index]
end

function converttabbiejson(dict::Array{Any,1})
    ri = RoundInfo(99)
    for debate in dict
        addteamsanddebate!(ri, debate)
    end

    # We need to create all the adjudicators before we can add information about
    # conflicts and history, as they reference each other.
    for debate in dict
        addadjudicators!(ri, debate["panel"]["adjudicators"])
    end
    for debate in dict
        addadjudicatorrelationships!(ri, debate["panel"]["adjudicators"])
    end
end

function addteamsanddebate!(ri::RoundInfo, d::JsonDict)
    id = d["id"]
    if hasobjectwithid(ri.debates, id)
        error("Duplicate debate ID: $id")
    end

    # Add debate and teams (judges aren't part of "debates" in Adjumo)
    teams = Team[]
    for position in ["OG", "OO", "CG", "CO"] # we imply position by order
        teamdict = d["teams"][position]
        t = addteam!(ri, teamdict)
        push!(teams, t)
    end
    adddebate!(ri, id, teams)
end

function addteam!(ri::RoundInfo, d::JsonDict)
    id = d["id"]
    if hasobjectwithid(ri.teams, id)
        error("Duplicate team ID: $id")
    end
    name = d["name"]
    institution = getoraddinstitution!(ri, d["society"])
    gender = interpretteamgender(d["speaker"])
    region = interpretregion(d["region_id"], d["region_name"])
    language = interpretteamlanguage(TODO)
    points = d["points"]
    addteam!(ri, id, name, institution, gender, region, language, points)
end

function getoraddinstitution!(ri::RoundInfo, d::JsonDict)
    id = d["id"]
    existingindex = findobjectwithid(ri.institutions, id)
    if existingindex > 0
        return ri.institutions[existingindex]
    end
    name = "Institution $id"
    code = "Inst$id"
    region = NoRegion
    # region = interpretregion(d["region_id"], d["region_name"])
    return addinstitution!(ri, id, name, code, region)
end

function interpretteamgender(d::JsonDict)
    # TODO populate
    return TeamNoGender
end

function interpretregion(id::Int, name::AbstractString)
    # TODO populate
    return NoRegion
end

function interpretteamlanguage(TODO)
    return NoLanguage
end

function addadjudicators!(ri::RoundInfo, d::JsonDict)
    id = d["id"]
    if hasobjectwithid(ri.adjudicators, id)
        error("Duplicate adjudicator ID: $id")
    end
    name = d["name"]
    institution = getoraddinstitution!(ri, d["society"])
    # TODO complete
    ranking = TODO
    gender = TODO
    regions = TODO
    language = TODO
end

function addadjudicatorrelationships!(ri::RoundInfo, d::JsonDict)
    id = d["id"]
    adj = getobjectwithid(ri.adjudicators, id)
    for conflictadjidstr in d["strikedAdjudicators"]
        conflictadjid = parse(Int, conflictadjidstr)
        conflictadj = getobjectwithid(ri.adjudicators, conflictadjid)
        addadjadjconflict(ri, adj, conflictadj)
    end
    for conflictteamidstr in d["strikedTeams"]
        conflictteamid = parse(Int, conflictadjidstr)
        conflictteam = getobjectwithid(ri.teams, conflictteamid)
        addteamadjconflict(ri, conflictteam, adj)
    end
    for seenadjidstr in d["pastAdjudicatorIDs"]
        seenadjid = parse(Int, seenadjidstr)
        seenadj = getobjectwithid(ri.adjudicators, seenadjid)
        addadjadjhistory(ri, adj, seenadj, 1) # TODO round number
    end
    for seenteamidstr in d["pastTeamIDs"]
        seenteamid = parse(Int, seenteamidstr)
        seenteam = getobjectwithid(ri.teams, seenteamid)
        addteamadjhistory(ri, seenteam, adj, 1) # TODO round number
    end
end
