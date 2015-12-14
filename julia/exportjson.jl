using JsonAPI

export exportjsoninstitutions, exportjsonteams, exportjsonadjudicators, exportjsondebates,
    jsoninstitutions, jsonteams, jsonadjudicators, jsondebates

function exportjsoninstitutions(ri::RoundInfo, io::IO)
    d = jsonapidict(ri.institutions)
    JSON.print(io, d)
end

function exportjsonteams(ri::RoundInfo, io::IO)
    d = jsonapidict(ri.teams)
    JSON.print(io, d)
end

function exportjsonadjudicators(ri::RoundInfo, io::IO)
    d = jsonapidict(ri.adjudicators)
    JSON.print(io, d)
end

function exportjsondebates(ri::RoundInfo, io::IO)
    d = jsonapidict(ri.debates)
    JSON.print(io, d)
end

function jsoninstitutions(ri::RoundInfo)
    d = jsonapidict(ri.institutions)
    JSON.json(d)
end

function jsonteams(ri::RoundInfo)
    d = jsonapidict(ri.teams)
    JSON.json(d)
end

function jsonadjudicators(ri::RoundInfo)
    d = jsonapidict(ri.adjudicators)
    JSON.json(d)
end

function jsondebates(ri::RoundInfo)
    d = jsonapidict(ri.debates)
    JSON.json(d)
end

function exportall(ri::RoundInfo)
    for field in fieldnames(ri)
        d = jsonapidict(getfield(ri, field))
        f = open(string(field)*".json", "w")
        JSON.print(f, d)
        close(f)
    end
end