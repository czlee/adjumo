push!(LOAD_PATH, joinpath(Base.source_dir(), ".."))
using Adjumo
using Iterators

ranks = [instances(Wudc2015AdjudicatorRank)...]
names = Dict(zip(ranks, ("T-", "T0", "T+", "P-", "P0", "P+", "C-", "C0", "C+")))
reverse!(ranks)

for panel in product(ranks, ranks, ranks)
    panel = reverse([panel...])
    if panel[1] < panel[2] || panel[2] < panel[3]
        continue
    end
    panelname = string([names[r] for r in panel]...)
    q = panelquality([panel...])
    println("$panelname,$q")
end