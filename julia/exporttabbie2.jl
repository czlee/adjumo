# Function that exports a file to be used by the Tabbie2 system.

using JSON

function exporttabbiejson(io::IO, rinfo::RoundInfo)
    d = convertroundinfototabbie2(rinfo)
    JSON.print(io, d)
end

function convertroundinfototabbiedict(rinfo::RoundInfo)

end