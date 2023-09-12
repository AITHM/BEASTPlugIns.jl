"""
ConstantFunction

Function that does not change over time
"""
@with_kw mutable struct ConstantFunction
    name::NString=nothing
    id::NString=nothing
    value::Union{Nothing, String, Vector{String}}=nothing      # Space delimited string of double values
end


"""
Logger

Logs results of a calculation processes on regular intervals.
"""
@with_kw mutable struct Logger <: BEASTObject
    name::NString=nothing
    id::NString=nothing
    fileName::NString=nothing       # Name of the file, or stdout if left blank
    logEvery::NInt64=nothing              # Number of sampled logged
    model::Union{Nothing, String}=nothing     # Model to log at the top of the log. If specified, XML will be produced for the model, commented out by # at the start of a line. Alignments are suppressed. This way, the log file documents itself.
    mode::NString=nothing           # logging mode, one of [autodetect, compound, tree]
    sort::NString=nothing           # sort items to be logged, one of [none, alphabetic, smart]
    sanitiseHeaders::NBool=false    # whether to remove any clutter introduced by Beauti
    ascii::NBool=true               # whether to convert the log output to ASCII
    log::Union{Nothing, Vector{<:BEASTObject}}=nothing                 # Element in a log. This can be any plug in that is Loggable.
end


"""
OperatorSchedule

Specify operator selection and optimisation schedule
"""
@with_kw mutable struct OperatorSchedule <: BEASTObject
    name::NString=nothing
    id::NString=nothing
    transform::NString=nothing       # transform optimisation schedule (default none) This can be [none, log, sqrt] (default 'none')
    autoOptimize::NBool=true        # whether to automatically optimise operator settings
    detailedRejection::NBool=false  # true if detailed rejection statistics should be included. (default=false)
    autoOptimizeDelay::NInt64=10_000    # number of samples to skip before auto optimisation kicks in (default=10000)
    operator::Union{Nothing, Vector{<:Operator}}=nothing        # operator that the schedule can choose from. Any operators added by other classes (e.g. MCMC) will be added if there are no duplicates.
    # subschedule::OperatorSchedule=nothing   # operator schedule representing a subset ofthe weight of the operators it contains.
    weight::NFloat64=100.               # weight with which this operator schedule is selected. Only used when this operator schedule is nested inside other schedules. This weight is relative to other operators and operator schedules of the parent schedule.
    weightIsPercentage::NBool=false     # indicates weight is a percentage of total weight instead of a relative weight
    operatorPattern::NString=nothing    # Regular expression matching operator IDs of operators of parent schedule
end


"""
MCMC

Entry point for running a Beast task, for instance an MCMC or other probabilistic analysis, a simulation, etc.
MCMC chain. This is the main element that controls which posterior to calculate, how long to run the chain and all other properties, which operators to apply on the state space and where to log results.
"""
@with_kw mutable struct MCMC <: BEASTObject
    name::NString=nothing
    id::NString=nothing
    chainLength::NInt64=nothing                              # Length of the MCMC chain i.e. number of samples taken in main loop
    state::Union{Nothing, Vector{<:State}}=nothing                          # elements of the state space
    init::Union{Nothing, Vector{<:StateNode}}=nothing       # one or more state node initializers used for determining the start state of the chain
    storeEvery::NInt64=-1                           # store the state to disk every X number of samples so that we can resume computation later on if the process failed half-way.
    preBurnin::NInt64=0                             # Number of burn in samples taken before entering the main loop
    numInitializationAttempts::NInt64=10            # Number of initialization attempts before failing (default=10)
    distribution::Union{Nothing, Vector{<:Distribution}}=nothing            # probability distribution to sample over (e.g. a posterior)
    operator::Union{Nothing, Vector{<:Operator}}=nothing                    # operator for generating proposals in MCMC state space
    logger::Union{Nothing, Vector{<:BEASTObject}}=nothing                   # loggers for reporting progress of MCMC chain
    sampleFromPrior::NBool=false                    # whether to ignore the likelihood when sampling (default false). The distribution with id 'likelihood' in the posterior input will be ignored when this flag is set.
    operatorschedule::Union{Nothing, Vector{<:BEASTObject}}=nothing         # specify operator selection and optimisation schedule
end