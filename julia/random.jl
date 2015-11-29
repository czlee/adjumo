function randomregion!(item)
    # TODO replace these with more realistic distributions
    item.region = rand([instances(Region)[2:end]...])
end

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


    institutions = [Institution("Institution $(i)", "Inst$(i)") for i = 1:ninstitutions]
    for inst in institutions
        randomregion!(inst)
    end
    teams = [Team("Team $(i)", rand(institutions)) for i = 1:nteams]
    adjudicators = [Adjudicator("Adjudicator $(i)", rand(institutions)) for i = 1:nadjs]

    for team in teams
        randomgender!(team)
        randomlanguage!(team)
    end
    for adj in adjudicators
        randomranking!(adj)
        randomgender!(adj)
        randomlanguage!(adj)
        addrandomregions!(adj)
    end

    sort!(adjudicators, by=adj->adj.ranking, rev=true)
    teams_shuffled = reshape(shuffle(teams), (4, ndebates))
    debates = [teams_shuffled[:,i] for i in 1:ndebates]
    roundinfo = RoundInfo(institutions, teams, adjudicators, debates, currentround)

    for i in 1:nadjs
        addadjadjconflict!(roundinfo, rand(adjudicators), rand(adjudicators))
        addteamadjconflict!(roundinfo, rand(teams), rand(adjudicators))
        addteamadjconflict!(roundinfo, rand(teams), rand(adjudicators))
    end

    for r in 1:currentround-1
        teams_shuffled = reshape(shuffle(teams), (4, ndebates))
        debates = [teams_shuffled[:,i] for i in 1:ndebates]
        adjs_shuffled = reshape(shuffle(adjudicators), (3, ndebates))
        panels = [adjs_shuffled[:,i] for i in 1:ndebates]
        for panel in panels
            for (adj1, adj2) in subsets(panel, 2)
                addadjadjhistory!(roundinfo, adj1, adj2, r)
            end
        end
        for (debate, panel) in zip(debates, panels)
            for (team, adj) in product(debate, panel)
                addteamadjhistory!(roundinfo, team, adj, r)
            end
        end
    end

    return roundinfo
end
