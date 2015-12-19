# Function that imports a JSON file output by the Tabbie2 system.
#
# This code is specialized to extract just the info it requires from Tabbie2's
# output. The interface between Tabbie2 and Adjumo is designed more to make
# export easy for Tabbie2 than it is to represent the actual information that
# needs to traverse the interface.
#
# This code also isn't very robust: if there are any errors in the file, it
# will crash.

using JSON

typealias JsonDict Dict{AbstractString,Any}

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
        addadjudicatorrelationships!(ri, debate["panel"]["adjudicators"])
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
    addteam!(ri, id, name, institution, institution.region, gender, language, points)
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
    # ranking = interpretranking(d["strength"])
    other_institutions = [getobjectwithid(ri.institutions, id) for id in d["societies"]]
    regions = unique([inst.region for inst in [institution; other_institutions]])
    gender = interpretpersongender(d["gender"])
    language = interpretlanguage(d["language_status"])
    adj = addadjudicator!(id, name, institution, ranking, regions, gender, language)

    # Also add team conflicts for every society
    conflictteams = filter(x -> x.institution ∈ other_institutions, ri.teams)
    for conflictteam in conflictteams
        addteamadjconflict!(ri, conflictteam, adj)
    end
end

function addadjudicatorrelationships!(ri::RoundInfo, d::JsonDict)
    id = d["id"]
    adj = getobjectwithid(ri.adjudicators, id)
    for conflictadjidstr in d["strikedAdjudicators"]
        conflictadjid = parse(Int, conflictadjidstr)
        conflictadj = getobjectwithid(ri.adjudicators, conflictadjid)
        addadjadjconflict!(ri, adj, conflictadj)
    end
    for conflictteamidstr in d["strikedTeams"]
        conflictteamid = parse(Int, conflictadjidstr)
        conflictteam = getobjectwithid(ri.teams, conflictteamid)
        addteamadjconflict!(ri, conflictteam, adj)
    end
    for seenadjiddict in d["pastAdjudicatorIDs"]
        round = parse(Int, seenadjiddict["rno"])
        seenadjid = parse(Int, seenadjiddict["bid"])
        seenadj = getobjectwithid(ri.adjudicators, seenadjid)
        addadjadjhistory!(ri, adj, seenadj, round)
    end
    for seenteamiddict in d["pastTeamIDs"]
        round = parse(Int, seenteamiddict["rno"])
        for pos in ["og", "oo", "cg", "co"]
            seenteamidkey = pos * "_team_id"
            seenteamid = parse(Int, seenteamiddict[seenteamidkey])
            seenteam = getobjectwithid(ri.teams, seenteamid)
            addteamadjhistory!(ri, seenteam, adj, round)
        end
    end
end
