function get_tip_labels(nwk::Node)
    return NewickTree.name.(getleaves(nwk))
end


function get_tip_dates(nwk::Node; joinall::Bool=false)
    tip_labels = get_tip_labels(nwk)
    tip_dates = Dict(tip_labels .=> [split(label, "_")[2] for label in tip_labels])
    joinall || return tip_dates
    return join([key*"="*val for (key, val) in tip_dates], ",")
end


function get_tip_types(nwk::Node; type::String="NOT_SET", joinall::Bool=false)
    tip_labels = get_tip_labels(nwk)
    tip_types = Dict(tip_labels .=> type)
    joinall || return tip_types
    return join([key*"="*val for (key, val) in tip_types], ",")
end


function complete!(x, dct)
    T = typeof(x)
    for (key, val) in dct
        if hasfield(T, Symbol(key))
            cval = convert(fieldtype(T, Symbol(key)), val)
            setfield!(x, Symbol(key), cval)
        end
    end
end


function get_spec(el::AbstractXMLNode)
    !has_attribute(el, "spec") && return
    spec = attribute(el, "spec")
    return split(spec, ".")[end]
end


function get_spec_type(el::AbstractXMLNode)
    return eval(Symbol(get_spec(el)))
end


function get_maps(el::AbstractXMLNode, map_dct::Dict{String, String}=Dict{String,String}())
    map_dct = Dict{String, String}()
    for c in child_elements(el)
        if LightXML.name(c) == "map"
            map_dct[attribute(c, "name")] = content(c)
        end
    end
    return map_dct
end


function overwrite_maps!(x::AbstractXMLNode, map_dict::Dict{String, String})
    haskey(map_dict, LightXML.name(x)) && set_attribute(x, "spec", map_dict[LightXML.name(x)])
    for c in child_elements(x)
        if LightXML.name(c) == "map"
            unlink(c)
        else
            overwrite_maps!(c, map_dict)
        end
    end
end


function LightXML.has_attribute(x::AbstractXMLNode, names::Vector{<:AbstractString})
    return any([has_attribute(x, n) for n in names])
end


function Base.delete!(node::AbstractXMLNode, attr::AbstractString)
    ccall(
                (:xmlUnsetProp, libxml2),
                Cint,
                (Ptr{Cvoid}, Cstring),
                node.ptr, attr)ccall(
                            (:xmlUnsetProp, libxml2),
                Cint,
                (Ptr{Cvoid}, Cstring),
                node.ptr, attr)
    return node
end


function fix_anomalies!(x::AbstractXMLNode, dict::Dict=Dict("clock.rate"=>"clockRate"))
    for (key, val) in dict
        if  has_attribute(x, key)
            set_attribute(x, val, attribute(x, key))
            delete!(x.node, key)
        elseif attribute(x, "spec") == "UniformDistribution"
            set_attribute(x, "spec", "Uniform")
        end
    end
    for c in child_elements(x)
        fix_anomalies!(c, dict)
    end
end
