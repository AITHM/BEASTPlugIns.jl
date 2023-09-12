"""
BirthDeathMigrationModelUncoloured

This model implements a multi-deme version of the BirthDeathSkylineModel with discrete locations and migration events among demes.
This should be used when the migration process along the phylogeny is irrelevant. Otherwise the BirthDeathMigrationModel can be employed.
This implementation also works with sampled ancestor trees.
"""
@with_kw mutable struct BirthDeathMigrationModelUncoloured <: SpeciesTreeDistribution
    name::NString=nothing
    id::NString=nothing
    tree::Union{Nothing, String}=nothing
    tiptypes::Union{Nothing, Vector{TraitSet}}=nothing                                          # trait information for initializing traits (like node types/locations) in the tree
    frequencies::Union{Nothing, String, RealParameter}=nothing                                  # The frequencies for each type
	origin::Union{Nothing, String, RealParameter}=nothing                                       # The origin of infection x1
	originIsRootEdge::Union{Nothing, String, Bool}=nothing                                      # The origin is only the length of the root edge, false
    maxEvaluations::Union{Nothing, Int64}=nothing                                               # The maximum number of evaluations for ODE solver, 1000000
	conditionOnSurvival::Union{Nothing, Bool}=nothing                                           # condition on at least one survival? Default true
	relativeTolerance::NFloat64=nothing                                                         # relative tolerance for numerical integration, 1e-7
	absoluteTolerance::NFloat64=nothing                                                         # absolute tolerance for numerical integration, 1e-100
	migChangeTimesInput::Union{Nothing, String, Vector{RealParameter}}=nothing                  # The times t_i specifying when migration rate changes occur, null
	birthRateChangeTimesInput::Union{Nothing, String, Vector{RealParameter}}=nothing            # The times t_i specifying when birth/R rate changes occur, null
	b_ijChangeTimesInput::Union{Nothing, String, Vector{RealParameter}}=nothing                 # The times t_i specifying when birth/R among demes changes occur, null
	deathRateChangeTimesInput::Union{Nothing, String, Vector{RealParameter}}=nothing            # The times t_i specifying when death/becomeUninfectious rate changes occur, null
	samplingRateChangeTimesInput::Union{Nothing, String, Vector{RealParameter}}=nothing         # The times t_i specifying when sampling rate or sampling proportion changes occur, null
	removalProbabilityChangeTimesInput::Union{Nothing, String, Vector{RealParameter}}=nothing   # The times t_i specifying when removal probability changes occur, null
	intervalTimes::Union{Nothing, String, Vector{RealParameter}}=nothing                        # The time t_i for all parameters if they are the same", null
	migTimesRelativeInput::NBool=nothing                                                        # True if migration rate change times specified relative to tree height? Default false
	b_ijChangeTimesRelativeInput::NBool=nothing                                                 # True if birth rate change times specified relative to tree height? Default false
	birthRateChangeTimesRelativeInput::NBool=nothing                                            # True if birth rate change times specified relative to tree height? Default false
	deathRateChangeTimesRelativeInput::NBool=nothing                                            # True if death rate change times specified relative to tree height? Default false
	samplingRateChangeTimesRelativeInput::NBool=nothing                                         # True if sampling rate times specified relative to tree height? Default false
	removalProbabilityChangeTimesRelativeInput::NBool=nothing                                   # True if removal probability change times specified relative to tree height? Default false
	reverseTimeArraysInput::NBool=nothing                                                       # True if the time arrays are given in backwards time (from the present back to root). Order: 1) birth 2) death 3) sampling 4) rho 5) r 6) migration. Default false Careful, rate array must still be given in FORWARD time (root to tips)
	rhoSamplingTimes::Union{Nothing, String, Vector{RealParameter}}=nothing                     # The times t_i specifying when rho-sampling occurs, null
    contemp::NBool=nothing                                                                      # Only contemporaneous sampling (i.e. all tips are from same sampling time, default false)
	birthRate::Union{Nothing, String, RealParameter, PopulationFunction}=nothing                # BirthRate = BirthRateVector * birthRateScalar, birthrate can change over time
    deathRate::Union{Nothing, String, RealParameter, PopulationFunction}=nothing                # The deathRate vector with birthRates between times
	samplingRate::Union{Nothing, String, RealParameter, PopulationFunction}=nothing             # The sampling rate per individual
	m_rho::Union{Nothing, String, RealParameter}=nothing                                        # The proportion of lineages sampled at rho-sampling times (default 0.)
	R0::Union{Nothing, String, RealParameter}=nothing                                           # The basic reproduction number
	becomeUninfectiousRate::Union{Nothing, String, RealParameter}=nothing                       # Rate at which individuals become uninfectious (through recovery or sampling)
	samplingProportion::Union{Nothing, String, RealParameter}=nothing                           # The samplingProportion = samplingRate / becomeUninfectiousRate
	identicalRatesForAllTypesInput::Union{Nothing, String, BooleanParameter}=nothing            # True if all types should have the same 1) birth 2) death 3) sampling 4) rho 5) r 6) migration rate. Default false
	R0_base::Union{Nothing, String, RealParameter}=nothing                                      # The basic reproduction number for the base pathogen class, should have the same dimension as the number of time intervals
	lambda_ratio::Union{Nothing, String, RealParameter}=nothing                                 # The ratio of basic infection rates of all other classes when compared to the base lambda, should have the dimension of the number of pathogens - 1, as it is kept constant over intervals.
	migrationMatrix::Union{Nothing, String, RealParameter}=nothing                              # Flattened migration matrix, can be asymmetric, diagonal entries omitted
	migrationMatrixScaleFactor::Union{Nothing, String, RealParameter}=nothing                   # A real number with which each migration rate entry is scaled
	rateMatrixFlagsInput::Union{Nothing, String, BooleanParameter}=nothing                      # Optional boolean parameter specifying which rates to use. (Default is to use all rates.)
	birthRateAmongDemes::Union{Nothing, String, RealParameter}=nothing                          # birth rate vector with rate at which transmissions occur among locations
	R0AmongDemes::Union{Nothing, String, RealParameter}=nothing                                 # The basic reproduction number determining transmissions occur among locations
	removalProbability::Union{Nothing, String, RealParameter}=nothing                           # The probability of an individual to become noninfectious immediately after the sampling
	stateNumber::NInt64=nothing                                                                 # The number of states or locations
	adjustTimesInput::Union{Nothing, String, RealParameter}=nothing                             # Origin of MASTER sims which has to be deducted from the change time arrays
	useRKInput::NBool=nothing                                                                   # Use fixed step size Runge-Kutta integrator with 1000 steps. Default false
	checkRho::NBool=nothing                                                                     # check if rho is set if multiple tips are given at present (default true)
	isParallelizedCalculationInput::NBool=nothing                                               # is the calculation parallelized on sibling subtrees or not (default true)
	minimalProportionForParallelizationInput::NFloat64=nothing                                  # the minimal relative size the two children subtrees of a node must have to start parallel calculations on the children. (default: 1/10)
end


"""
BirthDeathSkylineModel

Adaptation of Tanja Stadler's BirthDeathSamplingModel
to allow for birth and death rates to change at times t_i
"""
@with_kw mutable struct BirthDeathSkylineModel <: SpeciesTreeDistribution
    name::NString=nothing
    id::NString=nothing
    tree::Union{Nothing, String}=nothing
    origin::Union{Nothing, String, RealParameter}=nothing                   # The time from origin to last sample (must be larger than tree height) (RealParameter) null
    reproductiveNumber::Union{Nothing, String, RealParameter}=nothing       # The basic / effective reproduction number
    becomeUninfectiousRate::Union{Nothing, String, RealParameter}=nothing   # Rate at which individuals become uninfectious (through recovery or sampling)
    samplingProportion::Union{Nothing, String, RealParameter}=nothing       # The samplingProportion = samplingRate / becomeUninfectiousRate
    birthRateChangeTimes::Union{Nothing, Vector{RealParameter}}=nothing     # The times t_i specifying when birth/R rate changes occur
    deathRateChangeTimes::Union{Nothing, Vector{RealParameter}}=nothing     # The times t_i specifying when death/becomeUninfectious rate changes occur
    samplingRateChangeTimes::Union{Nothing, Vector{RealParameter}}=nothing  # The times t_i specifying when sampling rate or sampling proportion changes occur
    removalProbabilityChangeTimes::Union{Nothing, Vector{RealParameter}}=nothing    # The times t_i specifying when removal probability changes occur
    intervalTimes::Union{Nothing, Vector{RealParameter}}=nothing            # The time t_i for all parameters if they are the same
    birthRateChangeTimesRelative::NBool=nothing                             # True if birth rate change times specified relative to tree height? Default false
    deathRateChangeTimesRelative::NBool=nothing                             # True if death rate change times specified relative to tree height? Default false
    samplingRateChangeTimesRelative::NBool=nothing                          # True if sampling rate times specified relative to tree height? Default false
    removalProbabilityChangeTimesRelative::NBool=nothing                    # True if removal probability change times specified relative to tree height? Default false
    reverseTimeArrays::Union{Nothing, Vector{BooleanParameter}}=nothing     # True if the time arrays are given in backwards time (from the present back to root). Order: 1) birth 2) death 3) sampling 4) rho 5) r. Default false. Careful, rate array must still be given in FORWARD time (root to tips). If rhosamplingTimes given, they should be backwards and this should be true.");
    rhoSamplingTimes::Union{Nothing, Vector{RealParameter}}=nothing         # The times t_i specifying when rho-sampling occurs (RealParameter) null
    # origin::Union{Nothing, RealParameter}=nothing                         # The time from origin to last sample (must be larger than tree height) (RealParameter) null
    originIsRootEdge::NBool=nothing                                         # The origin is only the length of the root edge, false
    conditionOnRoot::NBool=nothing                                          # The tree likelihood is conditioned on the root height otherwise on the time of origin, false
    birthRate::Union{Nothing, RealParameter}=nothing                        # BirthRate = BirthRateVector * birthRateScalar, birthrate can change over time
    deathRate::Union{Nothing, RealParameter}=nothing                        # The deathRate vector with birthRates between times
    samplingRate::Union{Nothing, RealParameter}=nothing                     # The sampling rate per individual
    removalProbability::Union{Nothing, RealParameter}=nothing               # The probability of an individual to become noninfectious immediately after the sampling
    m_rho::Union{Nothing, RealParameter}=nothing                            # The proportion of lineages sampled at rho-sampling times (default 0.)
    contemp::NBool=nothing                                                  # Only contemporaneous sampling (i.e. all tips are from same sampling time, default false, false
    # baseReproductiveNumber::Union{Nothing, Function}=nothing              # The basic / effective reproduction number for the base cluster / pathogen class"
    # lambda_ratio::Union{Nothing, Function}=nothing                        # The factor with which to scale the transmission rate.
    netDiversification::Union{Nothing, RealParameter}=nothing               # The net diversification rate
    turnOver::Union{Nothing, RealParameter}=nothing                         # The turn over rate
    forceRateChange::NBool=nothing                                          # If there is more than one interval and we estimate the time of rate change, do we enforce it to be within the tree interval? Default true, true
    conditionOnSurvival::NBool=nothing                                      # if is true then condition on sampling at least one individual (psi-sampling) true
    conditionOnRhoSampling::NBool=nothing                                   # if is true then condition on sampling at least one individual at present. false
    taxon::Union{Nothing, Taxon}=nothing                                    # a name of the taxon for which to calculate the prior probability of being sampled ancestor under the model, (Taxon) null
    SATaxonInput::Union{Nothing, IntegerParameter}=nothing                  # A binary parameter which is equal to zero if the taxon is not a sampled ancestor (that is, it does not have sampled descendants) and to one if it is a sampled ancestor (that is, it has sampled descendants), (IntegerParameter) null
end