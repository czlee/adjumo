# Functions to import from the Node.js part.
# This file is part of the Adjumo module.

export importcomponentweightsjsonintoroundinfo!, importcomponentweightsjson

function importcomponentweightsjsonintoroundinfo!(rinfo::RoundInfo, io::IO)
    weights = importcomponentweightsjson(io)
    rinfo.componentweights = weights
end

function importcomponentweightsjson(io::IO)
    d = JSON.parse(io)
    return convertcomponentweightsdict(d)
end

function convertcomponentweightsdict(dict::JsonDict)
    weights = AdjumoComponentWeights()
    for (key, value) in dict
        sym = symbol(key)
        valuefloat = parse(Float64, value)
        setfield!(weights, sym, valuefloat)
    end
    return weights
end
