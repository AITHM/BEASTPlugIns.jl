"""
TreeIntervals

BEASTObject that performs calculations based on the State.
Extracts the intervals from a tree. Points in the intervals are defined by the heights of nodes in the tree.
"""
@with_kw mutable struct TreeIntervals <: PopulationModel
    id::NString=nothing
    tree::Union{Nothing, Tree}  # tree for which to calculate the intervals
end


"""
BayesianSkyline

BEASTObject that performs calculations based on the State.
Probabilistic representation that can produce a log probability for instance for running an MCMC chain.
Distribution on a tree, typically a prior such as Coalescent or Yule
Bayesian skyline: A likelihood function for the generalized skyline plot coalescent.
"""
@with_kw mutable struct BayesianSkyline <: PopulationModel
    id::NString=nothing
    popSizes::Float64           # present-day population size. If time units are set to Units.EXPECTED_SUBSTITUTIONS thenthe N0 parameter will be interpreted as N0 * mu. Also note that if you are dealing with a diploid population N0 will be out by a factor of 2.
    groupSizes::IntegerParameter  # the group sizes parameter
    tree::Union{Nothing, Tree}                  # tree over which to calculate a prior or likelihood
    treeIntervals::Union{Nothing, TreeIntervals}    # Intervals for a phylogenetic beast tree
end


"""
Coalescent

BEASTObject that performs calculations based on the State.
Probabilistic representation that can produce a log probability for instance for running an MCMC chain.
Distribution on a tree, typically a prior such as Coalescent or Yule
Calculates the probability of a beast.tree conditional on a population size function. Note that this does not take the number of possible tree interval/tree topology combinations in account, in other words, the constant required for making this a proper distribution that integrates to unity is not calculated (partly, because we don't know how for sequentially sampled data).

Logable: yes, this can be used in a log.
"""
@with_kw mutable struct Coalescent{T<:PopulationFunction} <: TreeDistribution
    id::NString=nothing
    populationModel::Union{Nothing, T}              # A population size model
    tree::Union{Nothing, Tree}                      # tree over which to calculate a prior or likelihood
    treeIntervals::Union{Nothing, TreeIntervals}    # Intervals for a phylogenetic beast tree
end


"""
ConstantPopulation

BEASTObject that performs calculations based on the State.
An implementation of a population size function beastObject.Also note that if you are dealing with a diploid population N0 will be the number of alleles, not the number of individuals.
coalescent intervals for a constant population
"""
@with_kw mutable struct ConstantPopulation <: PopulationFunction
    id::NString=nothing
    popSize::Union{Nothing, Vector{RealParameter}}=nothing     # constant (effective) population size value.
end


"""
CompoundPopulationFunction

BEASTObject that performs calculations based on the State.
An implementation of a population size function beastObject.Also note that if you are dealing with a diploid population N0 will be the number of alleles, not the number of individuals.
An effective population size function based on coalecent times from a set of trees.

Logable: yes, this can be used in a log.
"""
@with_kw mutable struct CompoundPopulationFunction <: PopulationFunction
    id::NString=nothing
    populationSizes::Union{Nothing, Vector{RealParameter}}          # population value at each point.
    populationIndicators::Union{Nothing, Vector{BooleanParameter}}  # Include/exclude population value from the population function.
    itree::Union{Nothing, Vector{TreeIntervals}}            # Coalecent intervals of this tree are used in the compound population function.
    type::NString="linear"                  # Flavour of demographic: either linear or stepwise for piecewise-linear or piecewise-constant.
    useIntervalsMiddle::NBool=false         # When true, the demographic X axis points are in the middle of the coalescent intervals. By default they are at the beginning.
end


"""
ExponentialGrowth

BEASTObject that performs calculations based on the State.
An implementation of a population size function beastObject.Also note that if you are dealing with a diploid population N0 will be the number of alleles, not the number of individuals.
Coalescent intervals for a exponentially growing population.
"""
@with_kw mutable struct ExponentialGrowth <: PopulationFunction
    id::NString=nothing
    popSize::Union{Nothing, Vector{RealParameter}}=1.0        # present-day population size (defaults to 1.0)
    growthRate::Union{Nothing, Vector{RealParameter}}=nothing # Growth rate is the exponent of the exponential growth. A value of zero represents a constant population size, negative values represent decline towards the present, positive numbers represents exponential growth towards the present.
end