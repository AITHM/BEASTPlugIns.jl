"""
Beta

BEASTObject that performs calculations based on the State.
A class that describes a parametric distribution, that is, a distribution that takes some parameters/valuables as inputs and can produce (cumulative) densities and inverse cumulative densities.
Beta distribution, used as prior. p(x;alpha,beta) = \\frac{x^{alpha-1}(1-x)^{beta-1}} {B(alpha,beta)} where B() is the beta function. If the input x is a multidimensional parameter, each of the dimensions is considered as a separate independent component.
"""
@with_kw mutable struct Beta <: Distribution
    name::NString=nothing
    id::NString=nothing
    alpha::Union{Nothing, Vector{RealParameter}}=nothing
    beta::Union{Nothing, Vector{RealParameter}}=nothing
    offset::NFloat64=0.0       # offset of origin (defaults to 0)
end


"""
Exponential

BEASTObject that performs calculations based on the State.
A class that describes a parametric distribution, that is, a distribution that takes some parameters/valuables as inputs and can produce (cumulative) densities and inverse cumulative densities.
Exponential distribution. f(x;lambda) = 1/lambda e^{-x/lambda}, if x >= 0 If the input x is a multidimensional parameter, each of the dimensions is considered as a separate independent component.
"""
@with_kw mutable struct Exponential <: Distribution
    name::NString=nothing
    id::NString=nothing
    mean::Union{Nothing, Vector{RealParameter}}=nothing
    offset::NFloat64=nothing       # offset of origin (defaults to 0)
end


"""
Gamma

BEASTObject that performs calculations based on the State.
A class that describes a parametric distribution, that is, a distribution that takes some parameters/valuables as inputs and can produce (cumulative) densities and inverse cumulative densities.
Gamma distribution. for x>0 g(x;alpha,beta) = 1/Gamma(alpha) beta^alpha} x^{alpha - 1} e^{-frac{x}{beta}}If the input x is a multidimensional parameter, each of the dimensions is considered as a separate independent component.
"""
@with_kw mutable struct Gamma <: Distribution
    name::NString=nothing
    id::NString=nothing
    alpha::Union{Nothing, Vector{RealParameter}}=nothing
    beta::Union{Nothing, Vector{RealParameter}}=nothing
    mode::NString="ShapeScale"
    offset::NFloat64=nothing       # offset of origin (defaults to 0)
end


"""
LogNormalDistributionModel

BEASTObject that performs calculations based on the State.
A class that describes a parametric distribution, that is, a distribution that takes some parameters/valuables as inputs and can produce (cumulative) densities and inverse cumulative densities.
A log-normal distribution with mean and variance parameters.
"""
@with_kw mutable struct LogNormalDistributionModel <: Distribution
    name::NString=nothing
    id::NString=nothing
    M::Union{Nothing, Vector{RealParameter}}=nothing
    S::Union{Nothing, Vector{RealParameter}}=nothing
    meanInRealSpace::NBool=false    # Whether the M parameter is in real space, or in log-transformed space. Default false = log-transformed.
    offset::NFloat64=nothing       # offset of origin (defaults to 0)
end


"""
Normal

BEASTObject that performs calculations based on the State.
A class that describes a parametric distribution, that is, a distribution that takes some parameters/valuables as inputs and can produce (cumulative) densities and inverse cumulative densities.
Normal distribution. f(x) = frac{1}{sqrt{2 pi sigma^2}} e^{ -frac{(x-mu)^2}{2sigma^2} } If the input x is a multidimensional parameter, each of the dimensions is considered as a separate independent component.
"""
@with_kw mutable struct Normal <: Distribution
    name::NString=nothing
    id::NString=nothing
    mean::Union{Nothing, Vector{RealParameter}}=nothing
    sigma::Union{Nothing, Vector{RealParameter}}=nothing
    tau::Union{Nothing, Vector{RealParameter}}=nothing
    offset::NFloat64=nothing       # offset of origin (defaults to 0)
end


"""
Prior

BEASTObject that performs calculations based on the State.
Probabilistic representation that can produce a log probability for instance for running an MCMC chain.
Produces prior (log) probability of value x.If x is multidimensional, the components of x are assumed to be independent, so the sum of log probabilities of all elements of x is returned as the prior.

Logable: yes, this can be used in a log.
"""
@with_kw mutable struct Prior <: Distribution
    name::NString=nothing
    id::NString=nothing
    x::Union{Nothing, String}=nothing    # point at which the density is calculated
    distr::Union{Nothing, Vector{<:Distribution}}=nothing                         # distribution used to calculate prior, e.g. normal, beta, gamma.
end


"""
Uniform

BEASTObject that performs calculations based on the State.
A class that describes a parametric distribution, that is, a distribution that takes some parameters/valuables as inputs and can produce (cumulative) densities and inverse cumulative densities.
Uniform distribution over a given interval (including lower and upper values)
"""
@with_kw mutable struct UniformDistribution <: Distribution
    name::NString=nothing
    id::NString=nothing
    lower::Union{Nothing, Vector{RealParameter}}=nothing
    upper::Union{Nothing, Vector{RealParameter}}=nothing
    offset::NFloat64=nothing
end


"""
CompoundDistribution

BEASTObject that performs calculations based on the State.
Probabilistic representation that can produce a log probability for instance for running an MCMC chain.
Takes a collection of distributions, typically a number of likelihoods and priors and combines them into the compound of these distributions typically interpreted as the posterior.

Logable: yes, this can be used in a log.
"""
@with_kw mutable struct CompoundDistribution <: Distribution
    name::NString=nothing
    id::NString=nothing
    distribution::Union{Vector{<:Distribution}, Nothing}=nothing    # individual probability distributions, e.g. the likelihood and prior making up a posterior
    prior::Union{Nothing, Vector{<:Distribution}}=nothing
    useThreads::NBool=nothing                                                     # calculated the distributions in parallel using threads (default false)
    threads::NInt64=nothing                                                          # maximum number of threads to use, if less than 1 the number of threads in BeastMCMC is used (default -1)
    ignore::NBool=nothing                                                        # ignore all distributions and return 1 as distribution (default false)
end


function Distribution(d::Distributions.Distribution)
    if isa(d, Distributions.Exponential)
        return Exponential(mean = d.θ)
    elseif isa(d, Distributions.Normal)
        return Normal(mean = d.μ, sigma = d.σ)
    elseif isa(d, Distributions.Gamma)
        return Gamma(alpha=d.α, beta=d.θ)
    elseif isa(d, Distributions.LogNormal)
        return LogNormalDistributionModel(M = d.μ, S = d.σ)
    elseif isa(d, Distributions.Uniform)
        return UniformDistribution(lower=d.a, upper=d.b)
    elseif isa(d, Distributions.Beta)
        return Beta(alpha=d.α, beta=d.β)
    end
    return
end