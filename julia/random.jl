include("testdata.jl")

function addrandomregions!(adj::Adjudicator)
    # TODO replace these with more realistic distributions
    while rand() < 0.05
        push!(adj.regions, rand([instances(Region)[2:end]...]))
    end
end

function randomgender!(team::Team)
    # TODO replace these with more realistic distributions
    team.gender = rand([instances(TeamGender)[2:end]...])
end

function randomgender!(adj::Adjudicator)
    # TODO replace these with more realistic distributions
    adj.gender = rand([instances(PersonGender)[2:end]...])
end

function randomlanguage!(item)
    # TODO replace these with more realistic distributions
    item.language = rand([instances(LanguageStatus)[2:end]...])
end

function randomranking!(adj::Adjudicator)
    # TODO replace these with more realistic distributions
    adj.ranking = rand([instances(Wudc2015AdjudicatorRank)[2:end]...])
end

function randomroundinfo(ndebates::Int, currentround::Int)
    nadjs = 3ndebates
    nteams = 4ndebates
    ninstitutions = 2ndebates

    roundinfo = RoundInfo(currentround)

    institutions = roundinfo.institutions
    teams = roundinfo.teams
    adjudicators = roundinfo.adjudicators

    for args in rand(INSTITUTIONS, ninstitutions)
        addinstitution!(roundinfo, args...)
    end

    for i in 1:nteams
        inst = rand(institutions)
        existing = numteamsfrominstitution(roundinfo, inst)
        addteam!(roundinfo, "$(inst.code) $(existing+1)", inst)
    end

    adjnames = rand(PERSON_NAMES, nadjs)
    for (name, gender) in adjnames
        addadjudicator!(roundinfo, name, rand(institutions), gender)
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

    sort!(adjudicators, by=adj->adj.ranking, rev=true)
    teams_shuffled = reshape(shuffle(teams), (4, ndebates))
    debates = [teams_shuffled[:,i] for i in 1:ndebates]
    debateweights = rand(length(debates)) * 10

    setdebates!(roundinfo, debates)
    setdebateweights!(roundinfo, debateweights)

    println("There are $(numdebates(roundinfo)) debates and $(numadjs(roundinfo)) adjudicators.")

    for i in 1:nadjs÷3
        addadjadjconflict!(roundinfo, rand(adjudicators, 2)...)
        addteamadjconflict!(roundinfo, rand(teams), rand(adjudicators))
    end

    for r in 1:currentround-1
        teams_shuffled = reshape(shuffle(teams), (4, ndebates))
        debates = [teams_shuffled[:,i] for i in 1:ndebates]
        adjs_shuffled = reshape(shuffle(adjudicators), (3, ndebates))
        panels = [adjs_shuffled[:,i] for i in 1:ndebates]
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
        addlockedadj!(roundinfo, rand(adjudicators), rand(1:ndebates))
        addblockedadj!(roundinfo, rand(adjudicators), rand(1:ndebates))
    end
    addgroupedadjs!(roundinfo, rand(adjudicators, 2))

    return roundinfo
end

