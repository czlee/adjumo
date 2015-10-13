"Container type for all information about a round."
type RoundInfo
    ndebates::Int64         # number of debates
    nadjs::Int64            # number of adjudicators
    adjrankings::Vector     # adjudicator rankings, must have nadjs elements
end

"A list of \"feasible panels\" is a list of lists of integers. Each (inner) list
contains the indices of adjudicators on a feasible panel."
typealias FeasiblePanelsList{T<:Integer} Vector{Vector{Int64}}

@enum Wudc2015AdjudicatorRank TraineeMinus Trainee TraineePlus PanellistMinus Panellist PanellistPlus ChairMinus Chair ChairPlus

