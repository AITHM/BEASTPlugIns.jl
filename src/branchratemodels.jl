"""
StrictClockModel

Defines a mean rate for each branch in the beast.tree
    
"""
@with_kw mutable struct StrictClockModel <: BranchRateModel
    id::NString="StrictClock"
    clockRate::Union{Nothing, String, RealParameter, Vector{RealParameter}}=nothing
end


# @with_kw UCRelaxedClockModel <: BranchRateModel
#     distr::Distribution=LogNormal(1.)
#     rateCategories::NInt64=nothing
#     numberOfDiscreteRates::Int64=-1
#     rateQuantiles::NVector{Float6464}=nothing
#     rates::NVector{Float6464}::=nothing
#     tree::BeastTree
#     normalize::Bool=false
#     clockRate::Float6464=1.0
# end