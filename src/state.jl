"""
State

The state represents the current point in the state space, and maintains values of a set of StateNodes, such as parameters and trees. Furthermore, the state manages which parts of the model need to be stored/restored and notified that recalculation is appropriate.
"""
@with_kw mutable struct State <: BEASTObject
    name::NString=nothing
    id::NString=nothing
    stateNode::Union{Vector{<:StateNode}, Nothing}=nothing  # anything that is part of the state
    parameter::Union{Nothing, Vector{<:BEASTParameter}}=nothing
    storeEvery::NInt64=-1                                   # store the state to disk every X number of samples so that we can resume computation later on if the process failed half-way.
end
