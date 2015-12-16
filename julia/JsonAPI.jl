# Partial JSON API implementation. Will eventually be spun out to its own
# package, once it's stable.

module JsonAPI

using JSON

export jsonapidict, printjsonapi, jsonapi

typealias JsonDict Dict{AbstractString,Any}

makename(s::Symbol) = lowercase(string(s))

makevalue(x::Integer) = x
makevalue(x::AbstractFloat) = x
makevalue(x::AbstractString) = x
makevalue(x::Void) = x
makevalue(x::Enum) = Integer(x)

addfield!(res::JsonDict, k::Symbol, v) = addfield!(res, makename(k), v)

addfield!(res::JsonDict, k::AbstractString, v::Integer) = addattribute!(res, k, v)
addfield!(res::JsonDict, k::AbstractString, v::AbstractFloat) = addattribute!(res, k, v)
addfield!(res::JsonDict, k::AbstractString, v::AbstractString) = addattribute!(res, k, v)
addfield!(res::JsonDict, k::AbstractString, v::Void) = addattribute!(res, k, v)
addfield!(res::JsonDict, k::AbstractString, v::Enum) = addattribute!(res, k, v)

addfield!{T<:Integer}(res::JsonDict, k::AbstractString, v::Array{T}) = addattributearray!(res, k, v)
addfield!{T<:AbstractFloat}(res::JsonDict, k::AbstractString, v::Array{T}) = addattributearray!(res, k, v)
addfield!{T<:AbstractString}(res::JsonDict, k::AbstractString, v::Array{T}) = addattributearray!(res, k, v)
addfield!{T<:Void}(res::JsonDict, k::AbstractString, v::Array{T}) = addattributearray!(res, k, v)
addfield!{T<:Enum}(res::JsonDict, k::AbstractString, v::Array{T}) = addattributearray!(res, k, v)

function addfield!(res::JsonDict, k::AbstractString, v)
    if :id ∉ fieldnames(v)
        error("Not sure what to do with field $k, type $(typeof(v)) has no field id")
    end
    addrelationship!(res, k, v)
end

function addfield!(res::JsonDict, k::AbstractString, v::Array)
    if :id ∉ fieldnames(eltype(v))
        error("Not sure what to do with field $k, type $(eltype(v)) has no field id")
    end
    addrelationshiparray!(res, k, v)
end

function addattribute!(res::JsonDict, k::AbstractString, v)
    attributes = get!(JsonDict, res, "attributes")
    attributes[k] = makevalue(v)
end

function addattributearray!(res::JsonDict, k::AbstractString, v::Array)
    attributes = get!(JsonDict, res, "attributes")
    attributes[k] = map(makevalue, v)
end

function addrelationship!(res::JsonDict, k::AbstractString, v)
    relationships = get!(JsonDict, res, "relationships")
    resource = resourceid(v)
    linkage = JsonDict("data"=>resource)
    relationships[k] = linkage
end

function addrelationshiparray!(res::JsonDict, k::AbstractString, v)
    relationships = get!(JsonDict, res, "relationships")
    resources = map(resourceid, v)
    linkage = JsonDict("data"=>resources)
    relationships[k] = linkage
end

function resourceid{T}(obj::T)
    res = JsonDict()
    res["type"] = makename(T.name.name)
    res["id"] = obj.id
    return res
end

function resource{T}(obj::T, id::Int)
    res = resource(obj)
    if !haskey(res, "id")
        res["id"] = id
    end
    return res
end

function resource{T}(obj::T)
    res = JsonDict()
    res["type"] = makename(T.name.name)
    if :id ∈ fieldnames(T)
        res["id"] = obj.id
    end
    for field in fieldnames(T)
        if field == :id
            continue
        end
        fvalue = getfield(obj, field)
        addfield!(res, field, fvalue)
    end
    return res
end

function primarydata(a::Array)
    primarydata = Array{JsonDict}(length(a))
    for (i, item) in enumerate(a)
        primarydata[i] = resource(item, i)
    end
    return primarydata
end

function primarydata(obj)
    resource(obj, 1)
end

function jsonapidict(a)
    d = JsonDict()
    d["data"] = primarydata(a)
    return d
end

function printjsonapi(io::IO, obj)
    d = jsonapidict(obj)
    JSON.print(io, d)
end

function jsonapi(obj)
    d = jsonapidict(obj)
    JSON.json(d)
end

end # module