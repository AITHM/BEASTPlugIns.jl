"""
TreeLikelihood

implemented by the following
beast.evolution.likelihood.BeagleTreeLikelihood
BEASTObject that performs calculations based on the State.
Probabilistic representation that can produce a log probability for instance for running an MCMC chain.
Generic tree likelihood for an alignment given a generic SiteModel, a beast tree and a branch rate model
Calculates the probability of sequence data on a beast.tree given a site and substitution model using a variant of the 'peeling algorithm'. For details, seeFelsenstein, Joseph (1981). Evolutionary trees from DNA sequences: a maximum likelihood approach. J Mol Evol 17 (6): 368-376.

Logable: yes, this can be used in a log.
"""
@with_kw mutable struct TreeLikelihood <: Distribution
    id::NString=nothing
    useAmbiguities::NBool=nothing     # flag to indicate that sites containing ambiguous states should be handled instead of ignored (the default)
    useTipLikelihoods::NBool=nothing  # flag to indicate that partial likelihoods are provided at the tips
    implementation::NString=nothing   # name of class that implements this treelikelihood potentially more efficiently. This class will be tried first, with the TreeLikelihood as fallback implementation. When multi-threading, multiple objects can be created.
    # scaling::beast.evolution.likelihood.TreeLikelihood$Scaling
    rootFrequencies::Union{Nothing, Vector{Frequencies}}=nothing   # prior state frequencies at root, optional
    data::Union{Nothing, String, Alignment}=nothing                         # sequence data for the beast.tree
    tree::Union{Nothing, String, Tree}=nothing                         # phylogenetic beast.tree with sequence data in the leafs
    siteModel::Union{Nothing, Vector{<:SiteModel}}=nothing           # site model for leafs in the beast.tree
    branchRateModel::Union{Nothing, Vector{<:BranchRateModel}}=nothing   # A model describing the rates on the branches of the beast.tree
end


