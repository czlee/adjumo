# Generate random datasets for use with Adjumo.
#
# Usage:
#   using Adjumo
#   using AdjumoDataTools
#   ndebates = 50
#   currentround = 5
#   ri = randomroundinfo(ndebates, currentround)
#
# You can also include("random.jl") this file rather than use the
# AdjumoDataTools module, if you prefer.

using Iterators
include("randomdata.jl")

export randomgender!, randomlanguage!, randomranking!, randomregion!, randomregions!

function randdiscrete(valuesandprobs)
    r = rand()
    s = 0.0
    for (v, p) in valuesandprobs
        s += p
        if r < s
            return v
        end
    end
end

function randomregion()
    randdiscrete([
        (NorthAsia, 0.1),
        (SouthEastAsia, 0.13),
        (MiddleEast, 0.05),
        (SouthAsia, 0.04),
        (Africa, 0.05),
        (Oceania, 0.08),
        (NorthAmerica, 0.19),
        (LatinAmerica, 0.04),
        (Europe, 0.14),
        (IONA, 0.18),
    ])
end

function randomregion!(team::Team)
    team.region = randomregion()
end

function randomregions!(adj::Adjudicator)
    adj.regions = Region[randomregion()]
    addrandomregions!(adj)
end

function addrandomregions!(adj::Adjudicator)
    # TODO replace these with more realistic distributions
    while rand() < 0.05
        push!(adj.regions, randomregion())
    end
end

function randomgender!(team::Team)
    team.gender = randdiscrete([
        (TeamMale, 0.4),
        (TeamFemale, 0.4),
        (TeamMixed, 0.2)
    ])
end

function randomgender!(adj::Adjudicator)
    team.gender = randdiscrete([
        (PersonMale, 0.65),
        (PersonFemale, 0.35),
    ])
end

function randomlanguage!(item)
    item.language = randdiscrete([
        (EnglishPrimary, 0.66)
        (EnglishSecond, 0.24)
        (EnglishForeign, 0.1)
    ])
end

function randomranking!(adj::Adjudicator)
    adj.ranking = randdiscrete([
        (TraineeMinus, 0.04),
        (Trainee, 0.06),
        (TraineePlus, 0.1),
        (PanellistMinus, 0.15),
        (Panellist, 0.25),
        (PanellistPlus, 0.15),
        (ChairMinus, 0.08),
        (Chair, 0.12),
        (ChairPlus, .05),
    ])
end

function randpair(v::Vector)
    for i = 1:100
        p = rand(v, 2)
        if p[1] != p[2]
            return p
        end
    end
    warn("Could not draw pair of two distinct items after 100 attempts")
    return p
end

function randomroundinfo(ndebates::Int, currentround::Int)
    nadjs = Integer(7ndebates÷2)
    nteams = 4ndebates
    ninstitutions = 2ndebates

    roundinfo = RoundInfo(currentround)

    institutions = roundinfo.institutions
    teams = roundinfo.teams
    adjudicators = roundinfo.adjudicators

    for args in rand(INSTITUTIONS, ninstitutions)
        addinstitution!(roundinfo, rand(1:10000), args...)
    end

    for i in 1:nteams
        inst = rand(institutions)
        existing = numteamsfrominstitution(roundinfo, inst)
        addteam!(roundinfo, rand(1:100000), "$(inst.code) $(existing+1)", inst)
    end

    adjnames = rand(PERSON_NAMES, nadjs)
    for (name, gender) in adjnames
        addadjudicator!(roundinfo, rand(1:100000), name, rand(institutions), gender)
    end

    for team in teams
        randomgender!(team)
        randomlanguage!(team)
    end
    for adj in adjudicators
        randomranking!(adj)
        randomlanguage!(adj)
        addrandomregions!(adj)
    end

    teams_shuffled = reshape(shuffle(teams), (4, ndebates))
    for i in 1:ndebates
        adddebate!(roundinfo, rand(1:100000), 10rand(), teams_shuffled[:,i])
    end

    for i in 1:nadjs÷4
        addadjadjconflict!(roundinfo, randpair(adjudicators)...)
        addteamadjconflict!(roundinfo, rand(teams), rand(adjudicators))
        addinstadjconflict!(roundinfo, rand(institutions), rand(adjudicators))
    end

    for r in 1:currentround-1
        debates = partition(shuffle(teams), 4)
        panels = map(collect, collect(partition(shuffle(adjudicators[1:3ndebates]), 3)))
        for (panel, leftoveradj) in zip(panels, adjudicators[3ndebates+1:end])
            push!(panel, leftoveradj)
        end
        for panel in panels
            for (adj1, adj2) in combinations(panel, 2)
                addadjadjhistory!(roundinfo, adj1, adj2, r)
            end
        end
        for (debate, panel) in zip(debates, panels)
            for team in debate, adj in panel
                addteamadjhistory!(roundinfo, team, adj, r)
            end
        end
    end

    for i in 1:2
        addlockedadj!(roundinfo, rand(adjudicators), rand(roundinfo.debates))
        addblockedadj!(roundinfo, rand(adjudicators), rand(roundinfo.debates))
    end
    for i = 1:100
        groupedadjs = randpair(adjudicators)
        if !conflicted(roundinfo, groupedadjs...)
            addgroupedadjs!(roundinfo, groupedadjs)
            break
        end
    end

    return roundinfo
end

