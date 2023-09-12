"""
SiteModel

Defines mutation rate and gamma distributed rates across sites (optional) and proportion of the sites invariant (also optional).
"""
@with_kw mutable struct SiteModel <: BEASTObject
    id::NString="SiteModel"
    mutationRate::Union{Nothing, Vector{RealParameter}}=nothing           # mutation rate (defaults to 1.0)
    gammaCategoryCount::NInt64=nothing              # gamma category count (default=zero for no gamma)
    shape::Union{Nothing, String, RealParameter}=nothing                  # shape parameter of gamma distribution. Ignored if gammaCategoryCount 1 or less
    proportionInvariant::Union{Nothing, Vector{RealParameter}}=nothing
    # parameter::Union{Nothing, Vector{<:BEASTParameter}}=nothing
    substModel::Union{Nothing, Vector{<:SubstitutionModel}}=nothing           # substitution model along branches in the beast.tree
end