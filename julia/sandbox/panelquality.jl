push!(LOAD_PATH, joinpath(Base.source_dir(), ".."))
using Adjumo

const JUDGE_SCORES = Float64[
#  T-    T0    T+    P-    P0   P+  C-  C0  C+
  -50   -50   -20     5    10   30  20  40  50
  -50   -50   -20     5    10   30  20  40  50
 -200  -200  -200  -100  -100   20  10  30  40
 -200  -200  -200  -200  -200   15   5  25  35
]
const CHAIR_SCORES = Float64[
 -200  -200  -200  -200  -100  -20  10  15  20
]
const NUM_RANKS = length(instances(Wudc2015AdjudicatorRank))

function panelquality1(rankings::Vector{Wudc2015AdjudicatorRank})
    sort!(rankings, rev=true)
    score = 0
    counts = zeros(Int, NUM_RANKS)

    # General value of judges
    for rank in rankings
        rankindex = Integer(rank)+1
        count = counts[rankindex] += 1
        if count > 4
            count = 4
        end
        score += JUDGE_SCORES[count, rankindex]
    end

    # Bonus for chair
    score += CHAIR_SCORES[Integer(rankings[1])+1]

    return score
end

function panelquality2(rankings::Vector{Wudc2015AdjudicatorRank})
    sort!(rankings, rev=true)
    score = 0
    counts = zeros(Int, NUM_RANKS)

    # General value of judges
    for rank in rankings
        rankindex = Integer(rank)+1
        count = counts[rankindex] += 1
        if count > 4
            count = 4
        end
        score += JUDGE_SCORES[count, rankindex]
    end

    # Bonus for chair
    chairrankindex = findlast(x -> x > 0, counts)
    score += CHAIR_SCORES[chairrankindex]
    return score
end

function panelquality3(rankings::Vector{Wudc2015AdjudicatorRank})
    score = 0
    counts = zeros(Int, NUM_RANKS)

    # General value of judges
    for rank in rankings
        rankindex = Integer(rank)+1
        count = counts[rankindex] += 1
        if count > 4
            count = 4
        end
        score += JUDGE_SCORES[count, rankindex]
    end

    # Bonus for chair
    chairrankindex = findlast(x -> x > 0, counts)
    score += CHAIR_SCORES[chairrankindex]
    return score
end

function panelquality4(rankings::Vector{Wudc2015AdjudicatorRank})
    score = 0
    counts = zeros(Int, NUM_RANKS)

    # General value of judges
    for rank in rankings
        rankindex = Integer(rank)+1
        count = counts[rankindex] += 1
        if count > 4
            count = 4
        end
    end
    for rank in reverse(instances(Wudc2015AdjudicatorRank))

    end

    # Bonus for chair
    chairrankindex = findlast(x -> x > 0, counts)
    score += CHAIR_SCORES[chairrankindex]
    return score
end

testdata = [rand([instances(Wudc2015AdjudicatorRank)...], rand(2:5)) for i in 1:100000]

funcs = [
    panelquality1,
    panelquality2,
    panelquality3,
]

for i = 1:5
    for f in shuffle(funcs)
        println(f)
        @time [f(regions) for regions in testdata]
    end
end

A = [[f(regions) for regions in testdata] for f in funcs]
for (i, j) in combinations(1:length(funcs), 2)
    @show (i, j) all((a,b) -> a == b, zip(A[i], A[j]))
end