"""
BooleanParameter

BEASTObject that performs calculations based on the State.
A node that can be part of the state.
A parameter represents a value in the state space that can be changed by operators.
A Boolean-valued parameter represents a value (or array of values if the dimension is larger than one) in the state space that can be changed by operators.

Logable: yes, this can be used in a log.
"""
@with_kw mutable struct BooleanParameter <: BEASTParameter
    name::NString=nothing
    id::NString=nothing                  # Parameter id
    value::Union{Nothing, Bool, Vector{Bool}}=nothing            # start value(s) for this parameter. If multiple values are specified, they should be separated by whitespace
    dimension::NInt64=1       # dimension of the parameter (default 1, i.e scalar)
    minordimension::NInt64=1  # minor-dimension when the parameter is interpreted as a matrix (default 1)
    keys::NString=nothing   # the keys (unique dimension names) for the dimensions of this parameter
    estimate::NBool=true    # whether to estimate this item or keep constant to its initial value
end


"""
IntegerParameter

BEASTObject that performs calculations based on the State.
A node that can be part of the state.
A parameter represents a value in the state space that can be changed by operators.
An Int64eger-valued parameter represents a value (or array of values if the dimension is larger than one) in the state space that can be changed by operators.

Logable: yes, this can be used in a log.
"""
@with_kw mutable struct IntegerParameter <: BEASTParameter
    name::NString=nothing
    id::NString=nothing                  # Parameter id   
    lower::NFloat64=nothing      # lower value for this parameter (default -infinity)
    upper::NFloat64=nothing       # upper value for this parameter (default +infinity)
    value::Union{Nothing, Int64, Vector{Int64}}=nothing            # start value(s) for this parameter. If multiple values are specified, they should be separated by whitespace
    dimension::NInt64=1       # dimension of the parameter (default 1, i.e scalar)
    minordimension::NInt64=1  # minor-dimension when the parameter is interpreted as a matrix (default 1)
    keys::NString=nothing   # the keys (unique dimension names) for the dimensions of this parameter
    estimate::NBool=true    # whether to estimate this item or keep constant to its initial value
end


"""
RealParameter

BEASTObject that performs calculations based on the State.
A node that can be part of the state.
A parameter represents a value in the state space that can be changed by operators.
A real-valued parameter represents a value (or array of values if the dimension is larger than one) in the state space that can be changed by operators.

Logable: yes, this can be used in a log.
"""
@with_kw mutable struct RealParameter <: BEASTParameter
    name::NString=nothing
    id::NString=nothing                  # Parameter id
    lower::Union{Nothing, String, Float64}=nothing        # lower value for this parameter (default -infinity)
    upper::Union{Nothing, String, Float64}=nothing         # upper value for this parameter (default +infinity)
    value::Union{Nothing, Float64, Vector{Float64}}=nothing             # start value(s) for this parameter. If mutiple values are specified, they should be separated by whitespace
    dimension::NInt64=nothing         # dimension of the parameter (default 1, i.e scalar)
    minordimension::NInt64=nothing    # minor-dimension when the parameter is interpreted as a matrix (default 1)
    keys::NString=nothing       # the keys (unique dimension names) for the dimensions of this parameter
    estimate::NBool=nothing        # whether to estimate this item or keep constant to its initial value. Default=true
end


function (::Type{T})(x::Number) where {T<:BEASTParameter}
    return T(value=x)
end


function (::Type{T})(x::Vector{<:Number}) where {T<:BEASTParameter}
    println("here")
    return [T.(value=x)]
end


Base.convert(::Type{Vector{RealParameter}}, x::AbstractFloat) = [RealParameter(x)]
Base.convert(::Type{Union{Nothing, Vector{RealParameter}}}, x::AbstractFloat) = [RealParameter(x)]
Base.convert(::Type{Union{Nothing, RealParameter, String, Vector{RealParameter}}}, x::AbstractFloat) = RealParameter(x)
Base.convert(::Type{Union{Nothing, String, RealParameter}}, x::AbstractFloat) = RealParameter(x)
Base.convert(::Type{Union{RealParameter, String, Vector{RealParameter}}}, x::Vector{<:Number}) = RealParameter(x)

Base.convert(::Type{T}, x::Number) where T <: BEASTParameter = T(x)
