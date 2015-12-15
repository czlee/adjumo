# This file is part of the Adjumo module.

export showconstraints, showdebatedetail

"Prints information about the given debate."
function showdebatedetail(roundinfo::RoundInfo, debateindex::Int, panel::AdjudicatorPanel)
    debate = roundinfo.debates[debateindex]
    println("== Debate $debateindex ==")

    println("Teams:")
    for team in debate.teams
        printfmtln("   {:<22}     {:<20}  {:1} {:<3} {:<5}",
                team.name, team.institution.code, abbr(team.gender), abbr(team.language), abbr(team.region))
    end
    drc, teamregionsordered = debateregionclass(debate)
    printfmtln("   {}: {}", drc, join([abbr(r) for r in teamregionsordered], ", "))

    println("Adjudicators:")
    for (role, adj) in rolelist(panel)
        adjname = adj.name * role
        printfmtln("   {:<22}  {:<2} {:<20}  {:1} {:<3} {}",
                adjname, abbr(adj.ranking), adj.institution.code, abbr(adj.gender), abbr(adj.language), join([abbr(r) for r in adj.regions], ","))
    end

    println("Conflicts:")
    for team in debate.teams, adj in adjlist(panel)
        if conflicted(roundinfo, team, adj)
            printfmtln("   {} conflicts with {}", adj.name, team.name)
        end
    end
    for (adj1, adj2) in combinations(adjlist(panel), 2)
        if conflicted(roundinfo, adj1, adj2)
            printfmtln("   {} conflicts with {}", adj1.name, adj2.name)
        end
    end

    println("History:")
    for team in debate.teams, adj in adjlist(panel)
        history = roundsseen(roundinfo, team, adj)
        if length(history) > 0
            printfmtln("   {} saw {} in round{} {}", adj.name, team.name,
                    (length(history) > 1) ? "s" : "", join([string(r) for r in history], ", "))
        end
    end
    for (adj1, adj2) in combinations(adjlist(panel), 2)
        history = roundsseen(roundinfo, adj1, adj2)
        if length(history) > 0
            printfmtln("   {} was with {} in round{} {}", adj1.name, adj2.name,
                    (length(history) > 1) ? "s" : "", join([string(r) for r in history], ", "))
        end
    end

    println("Constraints:")
    for adj in lockedadjs(roundinfo, debate)
        println("   $(adj.name) is locked to this debate")
    end
    for adj in blockedadjs(roundinfo, debate)
        printfmtln("   $(adj.name) is blocked from this debate")
    end
    for adjs in groupedadjs(roundinfo, adjlist(panel))
        printfmtln("   {} are grouped together", join([adj.name for adj in adjs], ", "))
    end

    println("Scores:                          raw      weighted")
    components = [
        ("Panel size", :panelsize, panelsizescore(panel)),
        ("Panel quality", :quality, panelquality(panel)),
        ("Regional representation", :regional, panelregionalrepresentationscore(debate, panel)),
        ("Language representation", :language, panellanguagerepresentationscore(debate, panel)),
        ("Gender representation", :gender, panelgenderrepresentationscore(debate, panel)),
        ("Team-adj history", :teamhistory, teamadjhistoryscore(roundinfo, debate, panel)),
        ("Adj-adj history", :adjhistory, adjadjhistoryscore(roundinfo, panel)),
        ("Team-adj conflicts", :teamconflict, teamadjconflictsscore(roundinfo, debate, panel)),
        ("Adj-adj conflicts", :adjconflict, adjadjconflictsscore(roundinfo, panel)),
    ]
    for component in components
        name, weightfield, score = component
        weight = getfield(roundinfo.componentweights, weightfield)
        printfmtln("{:>25}: {:>9.3f}  {:>12.3f}", name, score, score * weight)
    end
    debatescore = score(roundinfo, debate, panel)
    printfmtln("{:>25}:            {:>12.3f}  ({:>6.3f})  {:>12.3f}", "Overall", debatescore, debate.weight, debatescore * debate.weight)
    println()
end

"Prints all adjudicator constraints for the given RoundInfo."
function showconstraints(roundinfo::RoundInfo)
    println("Adjudicator constraints:")
    for (adj1, adj2) in roundinfo.adjadjconflicts
        printfmtln("   {} and {} conflict with each other", adj1.name, adj2.name)
    end
    for (team, adj) in roundinfo.teamadjconflicts
        debateindex = findfirst(debate -> team ∈ debate.teams, roundinfo.debates)
        debatestr = join([team.name for team in roundinfo.debates[debateindex].teams], ", ")
        printfmtln("   {} conflicts with {}, so blocked from [{}]", adj.name, team.name, debatestr)
    end
    for (adj, debate) in roundinfo.lockedadjs
        debatestr = join([team.name for team in debate.teams], ", ")
        printfmtln("   {} is locked to debate [{}]", adj.name, debatestr)
    end
    for (adj, debate) in roundinfo.blockedadjs
        debatestr = join([team.name for team in debate.teams], ", ")
        printfmtln("   {} is blocked from debate [{}]", adj.name, debatestr)
    end
    for adjs in roundinfo.groupedadjs
        printfmtln("   {} are grouped together", join([adj.name for adj in adjs], ", "))
    end
    println()
end