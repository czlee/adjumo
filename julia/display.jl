# This file is part of the AdjumoDataTools module, or you can include("display.jl")
# it if you prefer.

using Formatting
import Adjumo: debateregionclass, namewithrolelist

# These functions are not efficiently written, and not performance-critical.
abbr(g::TeamGender) = ["-", "M", "F", "X"][Integer(g)+1]
abbr(g::PersonGender) = ["-", "m", "f", "o"][Integer(g)+1]
abbr(r::Region) = ["-", "NAsia", "SEAsi", "MEast", "SAsia", "Afric", "Ocean", "NAmer", "LAmer", "Europ", "IONA"][Integer(r)+1]
abbr(l::LanguageStatus) = ["-", "EPL", "ESL", "EFL"][Integer(l)+1]
abbr(r::Wudc2015AdjudicatorRank) = ["T-", "T", "T+", "P-", "P", "P+", "C-", "C", "C+"][Integer(r)+1]

function showteams(rinfo::RoundInfo)
    for team in sort(rinfo.teams, by=t->t.points, rev=true)
        printfmtln("{:<25} {:>2} {:1} {:<3} {:<5}",
            team.name, team.points, abbr(team.gender), abbr(team.language), abbr(team.region))
    end
end

function showadjudicators(rinfo::RoundInfo)
    for adj in sort(rinfo.adjudicators, by=t->t.ranking, rev=true)
        printfmtln("{:<25} {:<2} {:1} {:<3} {}",
            adj.name, abbr(adj.ranking), abbr(adj.gender), abbr(adj.language), join([abbr(r) for r in adj.regions], ","))
    end
end

"Prints information about the given debate."
function showdebatedetail(roundinfo::RoundInfo, allocation::PanelAllocation)
    debate = allocation.debate
    println("== Debate with id $(debate.id) ==")

    println("Teams:")
    for team in debate.teams
        printfmtln("   {:<22}     {:<20}  {:1} {:<3} {:<5}",
                team.name, team.institution.code, abbr(team.gender), abbr(team.language), abbr(team.region))
    end
    drc, teamregionsordered = debateregionclass(debate)
    printfmtln("   {}: {}", drc, join([abbr(r) for r in teamregionsordered], ", "))

    println("Adjudicators:")
    for (adjname, adj) in zip(namewithrolelist(allocation), adjlist(allocation))
        printfmtln("   {:<22}  {:<2} {:<20}  {:1} {:<3} {}",
                adjname, abbr(adj.ranking), adj.institution.code, abbr(adj.gender), abbr(adj.language), join([abbr(r) for r in adj.regions], ","))
    end

    println("Conflicts:")
    for team in debate.teams, adj in adjlist(allocation)
        if conflicted(roundinfo, team, adj)
            printfmtln("   {} conflicts with {}", adj.name, team.name)
        end
    end
    for (adj1, adj2) in combinations(adjlist(allocation), 2)
        if conflicted(roundinfo, adj1, adj2)
            printfmtln("   {} conflicts with {}", adj1.name, adj2.name)
        end
    end

    println("History:")
    for team in debate.teams, adj in adjlist(allocation)
        history = roundsseen(roundinfo, team, adj)
        if length(history) > 0
            printfmtln("   {} saw {} in round{} {}", adj.name, team.name,
                    (length(history) > 1) ? "s" : "", join([string(r) for r in history], ", "))
        end
    end
    for (adj1, adj2) in combinations(adjlist(allocation), 2)
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
    for adjs in groupedadjs(roundinfo, adjlist(allocation))
        printfmtln("   {} are grouped together", join([adj.name for adj in adjs], ", "))
    end

    panel = AdjudicatorPanel(allocation)
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
    @assert debatescore == allocation.score
    printfmtln("{:>25}:            {:>12.3f}  ({:>6.3f})  {:>12.3f}", "Overall", allocation.score, debate.weight, allocation.score * debate.weight)
    println()
end

"Prints all adjudicator constraints for the given RoundInfo."
function showconstraints(roundinfo::RoundInfo)
    println("Adjudicator constraints:")
    for adjpair in roundinfo.adjadjconflicts
        printfmtln("   {} and {} conflict with each other", adjpair.adj1.name, adjpair.adj2.name)
    end
    for ta in roundinfo.teamadjconflicts
        debateindex = findfirst(debate -> ta.team ∈ debate.teams, roundinfo.debates)
        debatestr = join([t.name for t in roundinfo.debates[debateindex].teams], ", ")
        printfmtln("   {} conflicts with {}, so blocked from [{}]", ta.adjudicator.name, ta.team.name, debatestr)
    end
    for ad in roundinfo.lockedadjs
        debatestr = join([team.name for team in ad.debate.teams], ", ")
        printfmtln("   {} is locked to debate [{}]", ad.adjudicator.name, debatestr)
    end
    for ad in roundinfo.blockedadjs
        debatestr = join([team.name for team in ad.debate.teams], ", ")
        printfmtln("   {} is blocked from debate [{}]", ad.adjudicator.name, debatestr)
    end
    for adjs in roundinfo.groupedadjs
        printfmtln("   {} are grouped together", join([adj.name for adj in adjs], ", "))
    end
    println()
end