# This file is part of the AdjumoDataTools module.

using Formatting
import Adjumo: debateregionclass, namewithrolelist

export showteams, showadjudicators, showconstraints, showdebatedetail

const TEAM_GENDER_ABBRS = ["-", "M", "F", "X"]
const PERSON_GENDER_ABBRS = ["-", "m", "f", "o"]
const REGION_ABBRS = ["-", "NAsia", "SEAsi", "MEast", "SAsia", "Afric", "Ocean", "NAmer", "LAmer", "Europ", "IONA"]
const LANGUAGE_ABBRS = ["-", "EPL", "ESL", "EFL"]
const ADJUDICATOR_RANK_ABBRS = ["T-", "T", "T+", "P-", "P", "P+", "C-", "C", "C+"]
abbr(g::TeamGender) = TEAM_GENDER_ABBRS[Integer(g)+1]
abbr(g::PersonGender) = PERSON_GENDER_ABBRS[Integer(g)+1]
abbr(r::Region) = REGION_ABBRS[Integer(r)+1]
abbr(l::LanguageStatus) = LANGUAGE_ABBRS[Integer(l)+1]
abbr(r::Wudc2015AdjudicatorRank) = ADJUDICATOR_RANK_ABBRS[Integer(r)+1]

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

showdebatedetail(roundinfo::RoundInfo, allocation::PanelAllocation; α::Float64=1.0) =
        showdebatedetail(STDOUT, roundinfo, allocation; α=1.0)

"Prints information about the given debate."
function showdebatedetail(io::IO, roundinfo::RoundInfo, allocation::PanelAllocation; α::Float64=1.0)
    debate = allocation.debate
    println(io, "== Debate with id $(debate.id) ==")

    println(io, "Teams:")
    for team in debate.teams
        printfmtln(io, "   {:<22}     {:<20}  {:1} {:<3} {:<5}",
                team.name, team.institution.code, abbr(team.gender), abbr(team.language), abbr(team.region))
    end
    drc, teamregionsordered = debateregionclass(debate)
    printfmtln(io, "   {}: {}", drc, join([abbr(r) for r in teamregionsordered], ", "))

    println(io, "Adjudicators:")
    for (adjname, adj) in zip(namewithrolelist(allocation), adjlist(allocation))
        printfmtln(io, "   {:<22}  {:<2} {:<20}  {:1} {:<3} {}",
                adjname, abbr(adj.ranking), adj.institution.code, abbr(adj.gender), abbr(adj.language), join([abbr(r) for r in adj.regions], ","))
    end

    println(io, "Conflicts:")
    for team in debate.teams, adj in adjlist(allocation)
        if conflicted(roundinfo, team, adj)
            printfmtln(io, "   {} conflicts with {}", adj.name, team.name)
        end
    end
    for (adj1, adj2) in combinations(adjlist(allocation), 2)
        if conflicted(roundinfo, adj1, adj2)
            printfmtln(io, "   {} conflicts with {}", adj1.name, adj2.name)
        end
    end

    println(io, "History:")
    for team in debate.teams, adj in adjlist(allocation)
        history = roundsseen(roundinfo, team, adj)
        if length(history) > 0
            printfmtln(io, "   {} saw {} in round{} {}", adj.name, team.name,
                    (length(history) > 1) ? "s" : "", join([string(r) for r in history], ", "))
        end
    end
    for (adj1, adj2) in combinations(adjlist(allocation), 2)
        history = roundsseen(roundinfo, adj1, adj2)
        if length(history) > 0
            printfmtln(io, "   {} was with {} in round{} {}", adj1.name, adj2.name,
                    (length(history) > 1) ? "s" : "", join([string(r) for r in history], ", "))
        end
    end

    println(io, "Constraints:")
    for adj in lockedadjs(roundinfo, debate)
        println(io, "   $(adj.name) is locked to this debate")
    end
    for adj in blockedadjs(roundinfo, debate)
        printfmtln(io, "   $(adj.name) is blocked from this debate")
    end
    for adjs in groupedadjs(roundinfo, adjlist(allocation))
        printfmtln(io, "   {} are grouped together", join([adj.name for adj in adjs], ", "))
    end

    panel = AdjudicatorPanel(allocation)
    println(io, "Scores:                          raw      weighted")
    components = [
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
        printfmtln(io, "{:>25}: {:>9.3f}  {:>12.3f}", name, score, score * weight)
    end
    debatescore = score(roundinfo, debate, panel)
    weightedscore = weightedαfairness(debate.weight, debatescore, α)
    if weightedscore != allocation.score
        warn(io, "Score mismatch: $weightedscore != $(allocation.score)")
    end
    printfmtln(io, "{:>25}:            {:>12.3f}  ({:>6.3f})  {:>12.3f}", "Overall", debatescore, debate.weight, weightedscore)
    println(io)
end

showconstraints(roundinfo::RoundInfo) = showconstraints(STDOUT, roundinfo)

"Prints all adjudicator constraints for the given RoundInfo."
function showconstraints(io::IO, roundinfo::RoundInfo)
    println(io, "Adjudicator constraints:")
    for adjpair in roundinfo.adjadjconflicts
        printfmtln(io, "   {} and {} conflict with each other", adjpair.adj1.name, adjpair.adj2.name)
    end
    for ta in roundinfo.teamadjconflicts
        debateindex = findfirst(debate -> ta.team ∈ debate.teams, roundinfo.debates)
        debatestr = join([t.name for t in roundinfo.debates[debateindex].teams], ", ")
        printfmtln(io, "   {} conflicts with {}, so blocked from [{}]", ta.adjudicator.name, ta.team.name, debatestr)
    end
    for ad in roundinfo.lockedadjs
        debatestr = join([team.name for team in ad.debate.teams], ", ")
        printfmtln(io, "   {} is locked to debate [{}]", ad.adjudicator.name, debatestr)
    end
    for ad in roundinfo.blockedadjs
        debatestr = join([team.name for team in ad.debate.teams], ", ")
        printfmtln(io, "   {} is blocked from debate [{}]", ad.adjudicator.name, debatestr)
    end
    for adjs in roundinfo.groupedadjs
        printfmtln(io, "   {} are grouped together", join([adj.name for adj in adjs], ", "))
    end
    println(io)
end