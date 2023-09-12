"""
Frequencies
BEASTObject that performs calculations based on the State.
Represents character frequencies typically used as distribution of the root of the tree. Calculates empirical frequencies of characters in sequence data, or simply assumes a uniform distribution if the estimate flag is set to false

"""
@with_kw mutable struct Frequencies <: CalculationNode
    name::NString=nothing
    id::NString=nothing
    data::Union{Nothing, Alignment}=nothing    # Sequence data for which frequencies are calculated
    estimate::Union{Nothing, Bool}=nothing        # Whether to estimate the frequencies from data (true=default) or assume a uniform distribution over characters (false)
    frequencies::Union{Nothing, RealParameter}=nothing    # A set of frequencies specified as space separated values summing to 1
end


"""
HKY
HKY85 (Hasegawa, Kishino & Yano, 1985) substitution model of nucleotide evolution.

Reference:
Hasegawa M, Kishino H, Yano T (1985) Dating the human-ape splitting by a molecular clock of mitochondrial DNA. Journal of Molecular Evolution 22:160-174.

doi:10.1007/BF02101694
"""
@with_kw mutable struct HKY <: SubstitutionModel
    name::NString=nothing
    id::NString="hky"
    kappa::Union{Nothing, String, Float64}=nothing              # kappa parameter in HKY model
    frequencies::Vector{Frequencies}=nothing    # substitution model equilibrium state frequencies
end


"""
JukesCantor

Jukes Cantor substitution model: all rates equal and uniformly distributed frequencies
"""
@with_kw mutable struct JukesCantor <: SubstitutionModel
    name::NString=nothing
    id::NString="JC69"
    frequencies::Union{Nothing, Vector{Frequencies}}=nothing   # substitution model equilibrium state frequencies
end


