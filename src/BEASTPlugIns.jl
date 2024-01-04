module BEASTPlugIns


using Distributions
using LightXML
using NewickTree
using Parameters
using InteractiveUtils
using XML2_jll: libxml2


abstract type BEASTObject end
abstract type Runnable <: BEASTObject end
abstract type CalculationNode <: BEASTObject end
abstract type StateNode <: CalculationNode end
abstract type BEASTParameter <: StateNode end
abstract type Distribution <: CalculationNode end
abstract type PopulationFunction <: BEASTObject end
abstract type TreeDistribution <: Distribution end
abstract type SpeciesTreeDistribution <: TreeDistribution end
abstract type Operator <: BEASTObject end
abstract type TreeOperator <: Operator end
abstract type SubstitutionModel <: BEASTObject end
abstract type BranchRateModel <: BEASTObject end
abstract type Map <: BEASTObject end


Base.convert(::Type{Vector{<:T}}, x::T) where T <: BEASTObject = [x]
Base.convert(::Type{Vector{<:T}}, x::Nothing) where T <: Map = [eval(:($map())) for map in subtypes(Map)]
Base.convert(::Type{Bool}, x::String) = x in ["true", "yes", "1"] ? true : false
Base.convert(::Type{Union{Nothing, Bool}}, x::T) where T <: AbstractString = x in ["true", "yes", "1"] ? true : false
Base.convert(::Type{Union{Nothing, Float64}}, x::T) where T <: AbstractString = parse(Float64, x)
Base.convert(::Type{Union{Nothing, Int64}}, x::T) where T <: AbstractString = parse(Int64, x)

function Base.convert(::Type{Union{Nothing, Float64, Vector{Float64}}}, x::T) where T <: AbstractString
    vals = split(x, " ")
    length(vals) == 1 && return convert(Union{Nothing, Float64}, vals[1])
    return [convert(Union{Nothing, Float64}, val) for val in vals]
end


function Base.convert(::Type{Union{Nothing, Int64, Vector{Int64}}}, x::T) where T <: AbstractString
    vals = split(x, " ")
    length(vals) == 1 && return convert(Union{Nothing, Int64}, vals[1])
    return [convert(Union{Nothing, Int64}, val) for val in vals]
end


Base.isnothing(x::Vector{T}) where T <: Any = any(isnothing.(x))


include("..\\src\\utils.jl")
include("..\\src\\helperstructs.jl")
include("..\\src\\state.jl")
include("..\\src\\parameters.jl")
include("..\\src\\distributions.jl")
include("..\\src\\alignment.jl")



@with_kw mutable struct BEASTScript <: BEASTObject
    name::NString="beast"
    namespace::NString=nothing
    beautitemplate::NString=nothing
    beautistatus::NString=nothing
    version::NString=nothing
    required::NString=nothing
    data::Union{Nothing, Vector{<:CalculationNode}}=nothing
    tree::Union{Nothing, Vector{<:StateNode}}=nothing
    maps::Union{Nothing, Vector{<:Map}}=nothing
    run::Union{Nothing, Vector{<:BEASTObject}}=nothing
end


function parse_beast_file(file::AbstractString)
    xml = parse_file(file)
    root_node = root(xml)
    fix_anomalies!(root_node)
    map_dct = get_maps(root_node)
    overwrite_maps!(root_node, map_dct)
    return BEASTScript(root_node)
end


function (::Type{T})(x::AbstractXMLNode) where {T<:BEASTObject}
    attrib_dct = attributes_dict(x)
    if !haskey(attrib_dct, "name")
        attrib_dct["name"] = LightXML.name(x)
    end
    if !haskey(attrib_dct, "value") && !isnothing(content(x))
        attrib_dct["value"] = content(x)
    end
    inst = T()
    complete!(inst, attrib_dct)
    for c in child_elements(x)
        tag = Symbol(LightXML.name(c))
        c_name = Symbol(attribute(c, "name"))
        if hasfield(T, tag)
            setbeastfield!(inst, c, tag)
        elseif  hasfield(T, c_name)
            setbeastfield!(inst, c, c_name)
        end
    end
    return inst
end


function setbeastfield!(x, el::AbstractXMLNode, field::Symbol)
    spec = get_spec_type(el)
    S = !isnothing(spec) ? spec : field
    if S == :prior
        S = Prior
    end
    cur_val = getfield(x, field)
    new_val = isnothing(cur_val) ? [S(el)] : vcat(cur_val, S(el))
    setfield!(x, field, new_val)
    return
end


include("..\\src\\tree.jl")
include("..\\src\\populationmodels.jl")
include("..\\src\\operators.jl")
include("..\\src\\substitutionmodels.jl")
include("..\\src\\sitemodel.jl")
include("..\\src\\branchratemodels.jl")
include("..\\src\\seqgen.jl")
include("..\\src\\core.jl")


@with_kw mutable struct Loggable <: BEASTObject
    name::NString=nothing
    id::NString=nothing
    spec::NString=nothing
    idref::NString=nothing
    arg::NString=nothing
end

function Logger(x::AbstractXMLNode)
    logger = Logger()
    complete!(logger, attributes_dict(x))
    loggables = Vector{Loggable}()
    for c in child_elements(x)
        lg = Loggable()
        complete!(lg, attributes_dict(c))
        push!(loggables, lg)
    end
    logger.log = loggables
    return logger
end



include("..\\src\\xml.jl")
include("..\\src\\speciation.jl")
# include("..\\src\\utils.jl")
include("..\\src\\maps.jl")
# include("..\\src\\sitemodel.jl")
include("..\\src\\likelihood.jl")


function (::Type{T})(x::Dict) where {T<:BEASTObject}
    t = T()
    for (key, val) in x
        if hasfield(T, key) 
            if isa(val, Dict)
                setfield!(t, key, [eval(val[:spec])(val)])
            else
                cval = convert(fieldtype(T, key), val)
                setfield!(t, key, cval)
            end
        end
    end
    return t
end



export beast_xml, beast_xml_from_template, get_tip_dates, get_tip_types, BirthDeathMigrationModelUncoloured, BirthDeathSkylineModel, BEASTScript

# RealParameter, BEASTObject, Distribution, BEASTParameter, XML, Beta, Prior, BirthDeathSkylineModel, BooleanParameter, Sequence, Alignment,
# Operator, TreeOperator, ScaleOperator, TreeParser, JukesCantor, SiteModel, StrictClockModel, BranchRateModel, SequenceSimulator, SequenceSimulatorXML, BEASTXML, Map,
# State, make, TreeLikelihood, CompoundDistribution, ConstantPopulation, TaxonSet, TraitSet, RandomTree, Loggable, Logger, MCMC, BEASTScript, BirthDeathMigrationModelUncoloured



end # module BEASTPlugIns
