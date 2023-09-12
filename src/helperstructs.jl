
NInt64 = Union{Int64, Nothing}
NFloat64 = Union{Float64, Nothing}
NBool = Union{Bool, Nothing}
NString = Union{String, Nothing}
VInt64 = Union{Int64, Vector{Int64}}
VFloat64 = Union{Float64, Vector{Float64}}
VBool = Union{Bool, Vector{Bool}}
VString = Union{String, Vector{String}}

NVInt64 = Union{Int64, Vector{Int64}, Nothing}
NVFloat64 = Union{Float64, Vector{Float64}, Nothing}
NVBool = Union{Bool, Vector{Bool}, Nothing}
NVString = Union{String, Vector{String}, Nothing}


# function N(T::DataType)
#     return Union{Nothing, T}
# end

# function NV(T::DataType)
#     return Union{Nothing, T, Vector{<:T}}
# end