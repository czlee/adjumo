using JsonAPI

export exportjsoninstitutions, exportjsonteams, exportjsonadjudicators, exportjsondebates,
    jsoninstitutions, jsonteams, jsonadjudicators, jsondebates

exportjsoninstitutions(io::IO, ri::RoundInfo) = printjsonapi(io, ri.institutions)
exportjsonteams(io::IO, ri::RoundInfo) = printjsonapi(io, ri.teams)
exportjsonadjudicators(io::IO, ri::RoundInfo) = printjsonapi(io, ri.adjudicators)
exportjsondebates(io::IO, ri::RoundInfo) = printjsonapi(io, ri.debates)
jsoninstitutions(ri::RoundInfo) = jsonapi(ri.institutions)
jsonteams(ri::RoundInfo) = jsonapi(ri.teams)
jsonadjudicators(ri::RoundInfo) = jsonapi(ri.adjudicators)
jsondebates(ri::RoundInfo) = jsonapi(ri.debates)

function exportall(ri::RoundInfo)
    for field in fieldnames(ri)
        d = jsonapidict(getfield(ri, field))
        f = open(string(field)*".json", "w")
        JSON.print(f, d)
        close(f)
    end
end