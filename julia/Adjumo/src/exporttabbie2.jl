# Function that exports a file to be used by the Tabbie2 system.
# This file is part of the Adjumo module.

using JSON

export exporttabbiejson

function exporttabbiejson(allocations::Vector{PanelAllocation}, directory::AbstractString)
    filename = joinpath(directory, "allocationsfortabbie2.json")
    println("Writing $filename")
    f = open(filename, "w")
    printtabbiejson(f, allocations)
    close(f)
end

function printtabbiejson(io::IO, allocations::Vector{PanelAllocation})
    d = convertallocationstotabbiedict(allocations)
    JSON.print(io, d)
end

function convertallocationstotabbiedict(allocations::Vector{PanelAllocation})
    v = Array{Dict{AbstractString,Any}}(length(allocations))
    for (i, alloc) in enumerate(allocations)
        panel = Dict{AbstractString,Any}(
            "chair" => alloc.chair.id,
            "panellists" => [p.id for p in alloc.panellists],
            "trainees" => [t.id for t in alloc.trainees],
        )
        d = Dict{AbstractString,Any}(
            "id" => alloc.debate.id,
            "strength" => alloc.score,
            "panel" => panel,
            "messages" => [],
        )
        v[i] = d
    end
    return v
end