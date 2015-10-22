"Container type for all information about a round."
type RoundInfo
    ndebates::Int           # number of debates
    nadjs::Int              # number of adjudicators
    adjrankings::Vector     # adjudicator rankings, must have nadjs
end

@enum Gender GenderMale GenderFemale GenderOther
@enum Region Oceania NorthAmerica SouthAmerica IONA Europe Africa SouthEastAsia EastAsia SouthAsia

type Team
    gender::Gender
    region::Region
end

"A list of \"feasible panels\" is a list of lists of integers. Each (inner) list
contains the indices of adjudicators on a feasible panel."
typealias FeasiblePanelsList{T<:Integer} Vector{Vector{Int64}}

@enum Wudc2015AdjudicatorRank TraineeMinus Trainee TraineePlus PanellistMinus Panellist PanellistPlus ChairMinus Chair ChairPlus

