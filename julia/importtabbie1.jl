# Import Tabbie1 data from an SQL database into a RoundInfo.
#
# This is intended only for the use of historical datasets. For Thessaloniki
# WUDC 2016, we used this to try out the dataset from Malaysia WUDC 2015. (For
# obvious reasons, this dataset is not in this repository.)
#
# Requirements:
#   Pkg.clone("https://github.com/JuliaDB/DBI.jl.git")
# (This is an unregistered package at time of writing.)
#
# Usage:
#   using AdjumoDataTools
#   using DBI
#   using PostgreSQL
#   dbconnection = connect(Postgres, host, username, password, dbname, port)
#   currentround = 5
#   ri = gettabbie1roundinfo(dbconnection, currentround)
#
# You can also include("importtabbie1.jl") this file rather than use the
# AdjumoDataTools module, if you prefer.
#
# Because Tabbie1 doesn't have all of the information Adjumo requires, we
# require "augmentation files" to provide the missing data. You need to generate
# these yourself, probably manually. To do so, run this script:
#       cd ../misc
#       psql -d mydb -f generatecsv.sql
# and the files "adjudicators.csv", "teams.csv" and "institutions.csv" will show
# up in that folder. Then add appropriate columns for the missing fields, and
# save as "adjudicators-augmented.csv", "teams-augmented.csv" and "institutions-
# augmented.csv".
#
# Notes:
#  - Regions are hardcoded to match those used at Malaysia WUDC 2015. You'll
#    need to change interpretregion() if yours are different.
#  - For adjudicators, regions are taken from the database. For teams, regions
#    are inferred from the institutions, as indicated in the augmented
#    institutions CSV file.

using DBI

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

function gettabbie1roundinfo(dbconnection, currentround)
    rinfo = RoundInfo(currentround)

    # Institutions
    println("gettabbie1roundinfo: Importing institutions...")
    stmt = prepare(dbconnection, "SELECT univ_id, univ_name, univ_code FROM university;")
    result = execute(stmt)
    f = open("../misc/institutions-augmented.csv")
    (csvdata, header) = readdlm(f, ','; header=true)
    csv_ids = csvdata[:,findfirst(header,"univ_id")]
    csv_regions = csvdata[:,findfirst(header,"Region")]

    for (id32, name, code) in result
        id = Int(id32)

        csvrows = find(x -> x == id, csv_ids)
        if length(csvrows) != 1
            warn("Institution $code (id $id) occurred $(length(csvrows)) times in institutions-augmented.csv")
            region = NoRegion
        else
            region = interpretregion(csv_regions[csvrows[1]])
        end

        addinstitution!(rinfo, id, name, code, region)
    end

    # Teams
    println("gettabbie1roundinfo: Importing teams...")
    stmt = prepare(dbconnection, "SELECT team_id, univ_id, team_code, esl FROM team;")
    result = execute(stmt)
    f = open("../misc/speakers-augmented.csv")
    (csvdata, header) = readdlm(f, ','; header=true)
    csv_ids = csvdata[:,findfirst(header,"team_id")]
    csv_genders = csvdata[:,findfirst(header,"Gender")]
    for (id32, univ_id32, code, esl) in result
        id = Int(id32)
        univ_id = Int(univ_id32)
        institution = getobjectwithid(rinfo.institutions, univ_id)
        name = institution.code * " " * code
        region = institution.region
        language = interpretlanguage(esl)

        csvrows = find(x -> x == id, csv_ids)
        if length(csvrows) != 2
            warn("Team $name (id $id) had $(length(csvrows)) speakers in speakers-augmented.csv")
            gender = TeamNoGender
        else
            genders = map(interpretpersongender, csv_genders[csvrows])
            gender = aggregategender(genders...)
        end

        addteam!(rinfo, id, name, institution, region, gender, language, 0)
    end

    # Adjudicators
    println("gettabbie1roundinfo: Importing adjudicators...")
    stmt = prepare(dbconnection, "SELECT adjud_id, univ_id, adjud_name, region_id FROM adjudicator;")
    result = execute(stmt)
    f = open("../misc/adjudicators-augmented.csv")
    (csvdata, header) = readdlm(f, ','; header=true)
    csv_ids = csvdata[:,findfirst(header,"adjud_id")]
    csv_rankings = csvdata[:,findfirst(header,"ranking")]
    csv_genders = csvdata[:,findfirst(header,"Gender")]
    csv_languages = csvdata[:,findfirst(header,"Language")]
    for (id32, univ_id32, name, region_id) in result
        id = Int(id32)
        univ_id = Int(univ_id32)
        institution = getobjectwithid(rinfo.institutions, univ_id)
        regions = [interpretregion(region_id)]

        csvrows = find(x -> x == id, csv_ids)
        if length(csvrows) != 1
            warn("Adjudicator $name (id $id) occurred $(length(csvrows)) times in adjudicators-augmented.csv")
            ranking = TraineeMinus
            gender = PersonNoGender
            language = NoLanguage
        else
            csvrow = csvrows[1]
            ranking = interpretranking(csv_rankings[csvrow])
            gender = interpretpersongender(csv_genders[csvrow])
            language = interpretlanguage(csv_languages[csvrow])
        end
        addadjudicator!(rinfo, id, name, institution, ranking, regions, gender, language)
    end

    # Previous rounds
    for round in 1:currentround-1
        println("gettabbie1roundinfo: Importing history from round $round...")
        stmt = prepare(dbconnection, "SELECT adjud_round_$round.debate_id, adjud_id, first, second, third, fourth FROM adjud_round_$round LEFT JOIN result_round_$round ON result_round_$round.debate_id = adjud_round_$round.debate_id ORDER BY adjud_round_$round.debate_id")
        result = execute(stmt)
        iterstate = start(result)
        if !done(result, iterstate)
            (row, iterstate) = next(result, iterstate)
            last_debate = false
            while !last_debate
                debate_id = Int(row[1])
                adjud_ids = []
                team_ids = map(Int, row[3:6])
                teams = [getobjectwithid(rinfo.teams, id) for id in team_ids]
                # pull all rows for this debate, in order to get all adjudicators
                while debate_id == row[1]
                    push!(adjud_ids, Int(row[2]))
                    if done(result, iterstate)
                        last_debate = true
                        break
                    end
                    (row, iterstate) = next(result, iterstate)
                end
                adjs = [getobjectwithid(rinfo.adjudicators, id) for id in adjud_ids]

                for (team, points) in zip(teams, 3:-1:0)
                    team.points += points
                end

                for adj in adjs, team in teams
                    addteamadjhistory!(rinfo, team, adj, round)
                end
                for (adj1, adj2) in combinations(adjs, 2)
                    addadjadjhistory!(rinfo, adj1, adj2, round)
                end
            end
        end
    end

    # Current round
    println("gettabbie1roundinfo: Importing draw from round $currentround...")
    stmt = prepare(dbconnection, "SELECT debate_id, og, oo, cg, co FROM draw_round_$currentround")
    result = execute(stmt)
    for row in result
        id = Int(row[1])
        teamids = map(Int, row[2:5])
        teams = [getobjectwithid(rinfo.teams, tid) for tid in teamids]
        # stopgap: weight by number of points
        weight = maximum([team.points for team in teams])
        adddebate!(rinfo, id, weight, teams)
    end

    println("gettabbie1roundinfo: There are $(numdebates(rinfo)) debates and $(numadjs(rinfo)) adjudicators.")

    disconnect(dbconnection)
    return rinfo
end

REGIONS_BY_NAME = Dict("North East Asia" => NorthAsia,
    "South East Asia" => SouthEastAsia,
    "Middle East" => MiddleEast,
    "South Asia" => SouthAsia,
    "Africa" => Africa,
    "Oceania" => Oceania,
    "North America" => NorthAmerica,
    "Latin America and the Caribbean" => LatinAmerica,
    "Europe" => Europe,
    "IONA" => IONA,
)
function interpretregion(val::AbstractString)
    return REGIONS_BY_NAME[val]
end

REGIONS_BY_ID = [Oceania, IONA, NorthAmerica, LatinAmerica, Europe, Africa, MiddleEast, NorthAsia, SouthEastAsia, SouthAsia]
function interpretregion(val::Integer)
    return REGIONS_BY_ID[val]
end

function interpretlanguage(val::AbstractString)
    val = uppercase(val)
    if val == "N" || val == "EPL"
        return EnglishPrimary
    elseif val == "ESL"
        return EnglishSecond
    elseif val == "EFL"
        return EnglishForeign
    else
        error("Unknown language value: $val")
    end
end

function interpretpersongender(val::AbstractString)
    val = lowercase(val)
    if val == "male"
        return PersonMale
    elseif val == "female"
        return PersonFemale
    end
end

RANKINGS = Dict("C+" => ChairPlus, "C0" => Chair, "C-" => ChairMinus,
    "P+" => PanellistPlus, "P0" => Panellist, "P-" => PanellistMinus,
    "T+" => TraineePlus, "T0" => Trainee, "T-" => TraineeMinus
)
function interpretranking(val::AbstractString)
    return RANKINGS[val]
end
