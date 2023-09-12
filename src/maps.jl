@with_kw mutable struct UniformMap <: Map
    name::String="UniformDistribution"
    value::String="beast.base.inference.distribution.Uniform"
end

@with_kw mutable struct ExponentialMap <: Map
    name::String="Exponential"
    value::String="beast.base.inference.distribution.Exponential"
end

@with_kw mutable struct LogNormalMap <: Map
    name::String="LogNormal"
    value::String="beast.base.inference.distribution.LogNormalDistributionModel"
end


@with_kw mutable struct NormalMap <: Map
    name::String="Normal"
    value::String="beast.base.inference.distribution.Normal"
end


@with_kw mutable struct BetaMap <: Map
    name::String="Beta"
    value::String="beast.base.inference.distribution.Beta"
end


@with_kw mutable struct GammaMap <: Map
    name::String="Gamma"
    value::String="beast.base.inference.distribution.Gamma"
end


@with_kw mutable struct LaplaceDistributionMap <: Map
    name::String="LaplaceDistribution"
    value::String="beast.base.inference.distribution.LaplaceDistribution"
end


@with_kw mutable struct PriorMap <: Map
    name::String="prior"
    value::String="beast.base.inference.distribution.Prior"
end


@with_kw mutable struct InverseGammaMap <: Map
    name::String="InverseGamma"
    value::String="beast.base.inference.distribution.InverseGamma"
end


@with_kw mutable struct OneOnXMap <: Map
    name::String="OneOnX"
    value::String="beast.base.inference.distribution.OneOnX"
end