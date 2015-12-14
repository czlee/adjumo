using JSON

function importtabbiejson(io::IO)
    d = JSON.parse(io)
    return converttabbiejson(d)
end

function hasobjectwithid{T}(v::Vector{T}, id::Int)
    return findfirst(x -> x.id == id, v) > 0
end

function findobjectwithid{T}(v::Vector{T}, id::Int)
    return findfirst(x -> x.id == id, v)
end

function converttabbiejson(dict::Array{Any,1})
    ri = RoundInfo(99)
    for debate in dict
        adddebate!(ri, debate)
    end
end

function adddebate!(ri::RoundInfo, d::Dict{AbstractString,Any})
    id = d["id"]
    if hasobjectwithid(ri.debates, id)
        error("Duplicate debate ID: $id")
    end
    teams = Team[]
    for teamdict in values(d["teams"]) # don't care about positions
        t = addteam!(ri, teamdict)
        push!(teams, t)
    end
    adddebate!(ri, id, teams)
end

function addteam!(ri::RoundInfo, d::Dict{AbstractString,Any})
    id = d["id"]
    if hasobjectwithid(ri.teams, id)
        error("Duplicate team ID: $id")
    end
    name = d["name"]
    institution = getoraddinstitution!(ri, d["society"])
    gender = interpretgender(d["speaker"])
    region = interpretregion(d["region_id"], d["region_name"])

end

function getoraddinstitution!(ri::RoundInfo, d::Dict{AbstractString,Any})
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

