# Functions to export to JSON for the Node.js part to work with.
# This file is part of the Adjumo module.

using JsonAPI

# export exportjsonapi, jsonapi
# export exportjsoninstitutions, exportjsonteams, exportjsonadjudicators, exportjsondebates,
#     jsoninstitutions, jsonteams, jsonadjudicators, jsondebates
# export exportjsonadjadjhistory, exportjsonteamadjhistory, exportjsongroupedadjs
export exportroundinfo, exportallocations

exportjsonapi(io::IO, ri::RoundInfo, field::Symbol) = printjsonapi(io, getfield(ri, field))
jsonapi(ri::RoundInfo, field::Symbol) = jsonapi(getfield(ri, field))

exportjsoninstitutions(io::IO, ri::RoundInfo) = printjsonapi(io, ri.institutions)
exportjsonteams(io::IO, ri::RoundInfo) = printjsonapi(io, ri.teams)
exportjsonadjudicators(io::IO, ri::RoundInfo) = printjsonapi(io, ri.adjudicators)
exportjsondebates(io::IO, ri::RoundInfo) = printjsonapi(io, ri.debates)
jsoninstitutions(ri::RoundInfo) = jsonapi(ri.institutions)
jsonteams(ri::RoundInfo) = jsonapi(ri.teams)
jsonadjudicators(ri::RoundInfo) = jsonapi(ri.adjudicators)
jsondebates(ri::RoundInfo) = jsonapi(ri.debates)

immutable AdjAdjHistory
    adj1::Adjudicator
    adj2::Adjudicator
    rounds::Vector{Int}
end

immutable TeamAdjHistory
    team::Team
    adjudicator::Adjudicator
    rounds::Vector{Int}
end

immutable GroupedAdjudicators
    adjudicators::Vector{Adjudicator}
end

function exportjsonadjadjhistory(io::IO, ri::RoundInfo)
    histories = [AdjAdjHistory(adjs.adj1, adjs.adj2, rounds) for (adjs, rounds) in ri.adjadjhistory]
    printjsonapi(io, histories)
end

function exportjsonteamadjhistory(io::IO, ri::RoundInfo)
    histories = [TeamAdjHistory(ta.team, ta.adjudicator, rounds) for (ta, rounds) in ri.teamadjhistory]
    printjsonapi(io, histories)
end

function exportjsongroupedadjs(io::IO, ri::RoundInfo)
    groups = [GroupedAdjudicators(adjs) for adjs in ri.groupedadjs]
    printjsonapi(io, groups)
end

function exportroundinfo(ri::RoundInfo, directory::AbstractString)
    mkpath(directory)
    fields = [
        :adjudicators,
        :teams,
        :institutions,
        :debates,
        :adjadjconflicts,
        :teamadjconflicts,
        :lockedadjs,
        :blockedadjs,
        :componentweights,
    ]

    for field in fields
        filename = joinpath(directory, string(field)*".json")
        println("Writing $filename")
        f = open(filename, "w")
        exportjsonapi(f, ri, field)
        close(f)
    end

    special_fields = [
        "adjadjhistory",
        "teamadjhistory",
        "groupedadjs"
    ]

    for field in special_fields
        filename = joinpath(directory, field*".json")
        println("Writing $filename")
        f = open(filename, "w")
        func = eval(symbol("exportjson"*field))
        func(f, ri)
        close(f)
    end
end

function exportallocations(allocations::Vector{PanelAllocation}, directory::AbstractString)
    mkpath(directory)
    filename = joinpath(directory, "panelallocations.json")
    println("Writing $filename")
    f = open(filename, "w")
    printjsonapi(f, allocations)
    close(f)
end