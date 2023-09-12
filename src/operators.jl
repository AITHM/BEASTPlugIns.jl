

"""
DeltaExchangeOperator

Proposes a move in state space.
A generic operator for use with a sum-constrained (possibly weighted) vector parameter.

"""
@with_kw mutable struct DeltaExchangeOperator <: Operator
    id::NString=nothing
    parameter::Union{Nothing, String, Vector{<:BEASTParameter}}=nothing     # if specified, this parameter is operated on
    intparameter::Union{Nothing, String, Vector{<:BEASTParameter}}=nothing  # if specified, this parameter is operated on
    delta::NFloat64=0.1                                                     # Magnitude of change for two randomly picked values
    autoOptimize::NBool=nothing                                             # if true, window size will be adjusted during the MCMC run to improve mixing. Default=true
    integer::NBool=nothing                                                  # if true, changes are all integers. Default=false
    weightVector::Union{Nothing, Vector{<:BEASTParameter}}=nothing          # weights on a vector parameter
    weight::NFloat64=0.1                                                     # weight with which this operator is selected
end


"""
Exchange

Proposes a move in state space.
This operator changes a beast.tree.
Implements branch exchange operations. There is a NARROW and WIDE variety. The narrow exchange is very similar to a rooted-beast.tree nearest-neighbour interchange but with the restriction that node height must remain consistent.


"""
@with_kw mutable struct Exchange <: TreeOperator
    isNarrow::NBool=true        # if true (default) a narrow exchange is performed, otherwise a wide exchange. Default=true
    id::NString=isNarrow ? "Narrow" : "Wide"
    tree::Union{Nothing, String, Tree}=nothing   # BeastTree on which operation is performed
    markclades::NBool=nothing   # mark all ancestors of nodes changed by the operator as changed, up to the MRCA of all nodes changed by the operator. Default=false
    weight::NFloat64=1.0         # weight with which this operator is selected
end



"""
ScaleOperator

Proposes a move in state space.
Scales a parameter or a complete beast.tree (depending on which of the two is specified.
"""
@with_kw mutable struct ScaleOperator <: Operator
    id::NString=nothing
    tree::Union{Nothing, String, Tree}=nothing                  # BeastTree on which operation is performed
    parameter::Union{Nothing, String, Vector{<:BEASTParameter}}=nothing  # if specified, this parameter is scaled
    scaleFactor::NFloat64=0.75              # scaling factor: range from 0 to 1. Close to zero is very large jumps, close to 1.0 is very small jumps
    scaleAll::NBool=nothing                 # if true, all elements of a parameter (not beast.tree) are scaled, otherwise one is randomly selected. Default=false
    scaleAllIndependently::NBool=nothing    # if true, all elements of a parameter (not beast.tree) are scaled with a different factor, otherwise a single factor is used. Default=false
    degreesOfFreedom::NInt64=nothing        # degrees of freedom used when scaleAllIndependently=false and scaleAll=true to override default in calculation of Hasting ratio. Ignored when less than 1, default 0
    indicator::Union{Nothing, Vector{<:BEASTParameter}}=nothing           # indicates which dimension of the parameters can be scaled. Only used when scaleAllIndependently=false and scaleAll=false. If not specified it is assumed all dimensions are allowed to be scaled
    rootOnly::NBool=nothing                # scale root of a tree only, ignored if tree is not specified (default false)
    optimise::NBool=nothing                # flag to indicate that the scale factor is automatically changed in order to achieve a good acceptance rate (default true)
    upper::NFloat64=nothing                # Upper Limit of scale factor. Default=0.99999999
    lower::NFloat64=nothing                # Lower limit of scale factor. Default=1e-8
    weight::NFloat64=3.0                    # weight with which this operator is selected
end


"""
SubtreeSlide

Proposes a move in state space.
This operator changes a beast.tree.
Moves the height of an internal node along the branch. If it moves up, it can exceed the root and become a new root. If it moves down, it may need to make a choice which branch to slide down into.

"""
@with_kw mutable struct SubtreeSlide <: TreeOperator
    id::NString="SubtreeSlide"
    size::NFloat64=nothing  # size of the slide, default 1.0
    gaussian::NBool=nothing # Gaussian (=true=default) or uniform delta
    optimise::NBool=nothing # flag to indicate that the scale factor is automatically changed in order to achieve a good acceptance rate (default true)
    limit::NFloat64=nothing # limit on step size, default disable, i.e. -1. (when positive, gets multiplied by tree-height/log2(n-taxa)
    tree::Union{Nothing, String, Tree}=nothing   # BeastTree on which operation is performed
    markclades::NBool=nothing # mark all ancestors of nodes changed by the operator as changed, up to the MRCA of all nodes changed by the operator. Default=false
    weight::NFloat64=15.0      # weight with which this operator is selected
end


"""
Uniform <: Operator

Proposes a move in state space.
This operator changes a beast.tree.
Randomly selects true internal tree node (i.e. not the root) and move node height uniformly in interval restricted by the nodes parent and children.

Fields:
    tree::BeastTree=nothing - BeastTree on which operation is performed
    markclades::Bool=false  - mark all ancestors of nodes changed by the operator as changed, up to the MRCA of all nodes changed by the operator
    weight::Float64           - weight with which this operator is selected

"""
@with_kw mutable struct Uniform <: TreeOperator
    id::NString="Uniform"
    tree::Union{Nothing, String, Tree}=nothing   # BeastTree on which operation is performed
    markclades::NBool=nothing   # mark all ancestors of nodes changed by the operator as changed, up to the MRCA of all nodes changed by the operator. Default=false
    weight::NFloat64=30.0        # weight with which this operator is selected
end


"""
UpDownOperator

Proposes a move in state space.
This element represents an operator that scales two parameters in different directions. Each operation involves selecting a scale uniformly at random between scaleFactor and 1/scaleFactor. The up parameter is multiplied by this scale and the down parameter is divided by this scale.

"""
@with_kw mutable struct UpDownOperator <: Operator
    id::NString=nothing
    scaleFactor::NFloat64=0.9              # magnitude factor used for scaling
    up::Union{Nothing, Vector{<:StateNode}}=nothing                # zero or more items to scale upwards
    down::Union{Nothing, Vector{<:StateNode}}=nothing              # zero or more items to scale upwards
    optimise::NBool=nothing               # flag to indicate that the scale factor is automatically changed in order to achieve a good acceptance rate (default true)
    elementWise::NBool=nothing            # flag to indicate that the scaling is applied to a random index in multivariate parameters (default false)
    differentRandomIndex::NBool=nothing   # flag to indicate if a different random index should be chosen for each parameter (default false); only applicable if elementWise is set to true
    upper::NFloat64=nothing               # Upper Limit of scale factor. Default=0.99999999
    lower::NFloat64=nothing               # Lower limit of scale factor. Default=1e-8
    weight::NFloat64=3.0                   # weight with which this operator is selected
end


"""
WilsonBalding


Proposes a move in state space.
This operator changes a beast.tree.
Implements the unweighted Wilson-Balding branch swapping move. This move is similar to one proposed by WILSON and BALDING 1998 and involves removing a subtree and re-attaching it on a new parent branch


"""
@with_kw mutable struct WilsonBalding <: TreeOperator
    id::NString="WilsonBalding"
    tree::Union{Nothing, String, Tree}=nothing   # BeastTree on which operation is performed
    markclades::NBool=nothing   # mark all ancestors of nodes changed by the operator as changed, up to the MRCA of all nodes changed by the operator. Default=false
    weight::NFloat64=3.0         # weight with which this operator is selected
end


function tree_operators(tree_id)
    return [eval(:($T(tree="@"*$tree_id))) for T in subtypes(TreeOperator)]
end 


