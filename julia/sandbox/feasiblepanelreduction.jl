push!(LOAD_PATH, joinpath(Base.source_dir(), ".."))
using Adjumo
using Iterators
using Formatting

const ADJUDICATOR_RANK_ABBRS = ["T-", "T0", "T+", "P-", "P0", "P+", "C-", "C0", "C+"]
abbr(r::Wudc2015AdjudicatorRank) = ADJUDICATOR_RANK_ABBRS[Integer(r)+1]

ranks = [instances(Wudc2015AdjudicatorRank)...]
for panelsize in [2,3,4]
    for panel in product([ranks for i in 1:panelsize]...)
        score = panelquality([panel...])
        if score < -20
            printfmtln("{} {}", join(map(abbr, panel),""), score)
        end
    end
end