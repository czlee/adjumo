# Function that imports a JSON file output by the Tabbie2 system.
# This file is part of the Adjumo module.
#
# This code is specialized to extract just the info it requires from Tabbie2's
# output. The interface between Tabbie2 and Adjumo is designed more to make
# export easy for Tabbie2 than it is to represent the actual information that
# needs to traverse the interface.
#
# This code also isn't very robust: if there are any errors in the file, it
# will crash.

export importtabbiejson, converttabbiedicttoroundinfo

# These are set by the adjudicator core. Tabbie2's regions are ignored.
REGIONS = [
    NorthAsia     => ["cn","jp","kr"],
    SouthEastAsia => ["my","id","ph","sg"],
    MiddleEast    => ["il","lb"],
    SouthAsia     => ["in","pk","bd"],
    Africa        => ["za","bw","na"],
    Oceania       => ["au","nz"],
    NorthAmerica  => ["ca","us"],
    LatinAmerica  => ["mx","br"],
    Europe        => ["fr","de","it","at","hr","gr","rs","ro","kz","nl","se","az","pt","ee","tr","dk","mk","hu","ru","ua","cz","es","fi","pl","lv","si"],
    IONA          => ["gb","ie"],
]

# These are taken from tabbie2.git/common/models/User.php
const TABBIE_GENDER_NOTREVEALING = 0
const TABBIE_GENDER_MALE = 1
const TABBIE_GENDER_FEMALE = 2
const TABBIE_GENDER_OTHER = 3
const TABBIE_LANGUAGE_ENL = 1
const TABBIE_LANGUAGE_ESL = 2
const TABBIE_LANGUAGE_EFL = 3

function importtabbiejson(io::IO)
    d = JSON.parse(io)
    return converttabbiedicttoroundinfo(d)
end

function hasobjectwithid(v::Vector, id::Int)
    return findfirst(x -> x.id == id, v) > 0
end

function getobjectwithid{T}(v::Vector{T}, id::Int)
    index = findfirst(x -> x.id == id, v)
    if index == 0
        error("$T with ID $id does not exist")
    end
    return v[index]
end

# Calls f on the object with the given id if it is found; does nothing otherwise.
function onobjectwithid{T}(f::Function, v::Vector{T}, id::Int)
    index = findfirst(x -> x.id == id, v)
    if index != 0
        f(v[index])
    end
end

function converttabbiedicttoroundinfo(dict::JsonDict)
    ri = RoundInfo(99)

    for institution in values(dict["societies"])
        addinstitution!(ri, institution)
    end

    for debate in dict["draw"]
        addteamsanddebate!(ri, debate)
    end

    # We need to create all the adjudicators before we can add information about
    # conflicts and history, as they reference each other.
    for debate in dict["draw"]
        addadjudicators!(ri, debate["panel"]["adjudicators"])
    end
    for debate in dict["draw"]
        addadjudicatorsrelationships!(ri, debate["panel"]["adjudicators"])
    end

    return ri
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
    institution = getobjectwithid(ri.institutions, d["society_id"])
    gender = interpretteamgender(d["speakers"])
    language = interpretlanguage(d["language_status"])
    points = d["points"]
    addteam!(ri, id, name, institution, institution.region, language, gender, points)
end

function addinstitution!(ri::RoundInfo, d::JsonDict)
    id = d["id"]
    if hasobjectwithid(ri.institutions, id)
        error("Duplicate institution ID: $id")
    end
    name = d["fullname"]
    code = d["abr"]
    region = interpretregion(d["country"])
    addinstitution!(ri, id, name, code, region)
end

function interpretteamgender(speakersdict::JsonDict)
    genderA = interpretpersongender(speakersdict["A"]["gender"])
    genderB = interpretpersongender(speakersdict["B"]["gender"])
    return aggregategender(genderA, genderB)
end

function interpretpersongender(value::Integer)
    if value == TABBIE_GENDER_MALE || value == TABBIE_GENDER_NOTREVEALING
        return PersonMale
    elseif value == TABBIE_GENDER_FEMALE || value == TABBIE_GENDER_OTHER
        return PersonFemale
    else
        error("Unrecognised speaker gender value: $value")
    end
end

function interpretregion(countryalpha2::AbstractString)
    for (region, countries) in REGIONS
        if countryalpha2 ∈ countries
            return region
        end
    end
    warn("Country code $countryalpha2 has no region defined.")
    return NoRegion
end

function interpretlanguage(val::Int)
    if val == TABBIE_LANGUAGE_ENL
        return EnglishPrimary
    elseif val == TABBIE_LANGUAGE_ESL
        return EnglishSecond
    elseif val == TABBIE_LANGUAGE_EFL
        return EnglishForeign
    else
        return NoLanguage
    end
end

function addadjudicators!(ri::RoundInfo, adjdicts::Array)
    for adjdict in adjdicts
        addadjudicator!(ri, adjdict)
    end
end

function addadjudicator!(ri::RoundInfo, d::JsonDict)
    id = d["id"]
    if hasobjectwithid(ri.adjudicators, id)
        error("Duplicate adjudicator ID: $id")
    end
    name = d["name"]
    institution = getobjectwithid(ri.institutions, d["society_id"])
    ranking = interpretranking(d["strength"])
    # ranking = Panellist
    otherinstitutions = Institution[]
    for otherinstid in d["societies"]
        onobjectwithid(ri.institutions, parse(Int, otherinstid)) do inst
            push!(otherinstitutions, inst)
        end
    end
    regions = unique(Region[inst.region for inst in [institution; otherinstitutions]])
    gender = interpretpersongender(d["gender"])
    language = interpretlanguage(d["language_status"])
    adj = addadjudicator!(ri, id, name, institution, ranking, regions, language, gender)

    # Also add team conflicts for every society
    for otherinst in otherinstitutions
        addinstadjconflict!(ri, otherinst, adj)
    end
end

function addadjudicatorsrelationships!(ri::RoundInfo, adjdicts::Array)
    for adjdict in adjdicts
        addadjudicatorrelationships!(ri, adjdict)
    end
end

function addadjudicatorrelationships!(ri::RoundInfo, d::JsonDict)
    id = d["id"]
    adj = getobjectwithid(ri.adjudicators, id)
    for conflictadjidstr in d["strikedAdjudicators"]
        conflictadjid = parse(Int, conflictadjidstr)
        onobjectwithid(ri.adjudicators, conflictadjid) do conflictadj
            addadjadjconflict!(ri, adj, conflictadj)
        end
    end
    for conflictteamidstr in d["strikedTeams"]
        conflictteamid = parse(Int, conflictteamidstr)
        onobjectwithid(ri.teams, conflictteamid) do conflictteam
            addteamadjconflict!(ri, conflictteam, adj)
        end
    end
    for seenadjiddict in d["pastAdjudicatorIDs"]
        rd = parse(Int, seenadjiddict["label"])
        seenadjid = parse(Int, seenadjiddict["bid"])
        onobjectwithid(ri.adjudicators, seenadjid) do seenadj
            addadjadjhistory!(ri, adj, seenadj, rd)
        end
    end
    for seenteamiddict in d["pastTeamIDs"]
        rd = 0
        try
            rd = parse(Int, seenteamiddict["label"])
        catch e
            warn("Adj $(adj.id) $(adj.name), pastTeamIDs: $(e.msg)")
            continue
        end
        for pos in ["og", "oo", "cg", "co"]
            seenteamidkey = pos * "_team_id"
            seenteamid = parse(Int, seenteamiddict[seenteamidkey])
            onobjectwithid(ri.teams, seenteamid) do seenteam
                addteamadjhistory!(ri, seenteam, adj, rd)
            end
        end
    end
end

BOUNDARIES = [20, 30, 40, 50, 60, 70, 80, 90]

function interpretranking(val::Int)
    for (boundary, rank) in zip(BOUNDARIES, instances(Wudc2015AdjudicatorRank))
        if val < boundary
            return rank
        end
    end
    return ChairPlus
end