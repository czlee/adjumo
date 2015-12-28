# Deficit points.
# This file is part of the Adjumo module.

export DeficitPointEntry

type DeficitPointEntry
    team::Team
    round::Int
    quality::Float64
    region::Float64
    gender::Float64
    language::Float64
end

"""
Calculates the deficit point entries for the next round, based on the allocation
of the previous round. Does not take into account the results of the previous
round. Returns a list of DeficitPointEntry objects.
"""
function computedeficitpointentries(rinfo::RoundInfo, allocations::Vector{PanelAllocation})


    for alloc in allocations

    end

end