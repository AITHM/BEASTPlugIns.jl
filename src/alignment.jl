"""
Sequence

Single sequence in an alignment.
"""
@with_kw mutable struct Sequence <: BEASTObject
    name::NString=nothing
    id::NString=nothing
    totalcount::NInt64=nothing    # number of states or the number of lineages for this species in SNAPP analysis. Default=4
    taxon::NString=nothing               # name of this species
    value::NString=nothing               # sequence data, either encoded as a string or as comma separated list of integers, or comma separated likelihoods/probabilities for each site if uncertain=true.In either case, whitespace is ignored.
    uncertain::NInt64=nothing     # if true, sequence is provided as comma separated probabilities for each character, with sites separated by a semi-colons. In this formulation, gaps are coded as 1/K,...,1/K, where K is the number of states in the model.
end


# function Sequence(seq::AbstractXMLNode, id::Union{Nothing, String}=nothing)
#     LightXML.name(seq) != "sequence" && return nothing
#     attrib_dct = attributes_dict(seq)
#     out = Sequence(id = isnothing(id) ? attrib_dct["taxon"] : id,
#                    taxon = attrib_dct["taxon"],
#                    value = attrib_dct["value"])
#     delete!(attrib_dct, "id")
#     complete!(out, attrib_dct)
#     return out
# end


"""
Taxon

implemented by the following
beast.evolution.alignment.TaxonSet
For identifying a single taxon
"""
mutable struct Taxon <: BEASTObject
    # id::NString=nothing
end


"""
Alignment

implemented by the following
beast.app.seqgen.SimulatedAlignment
beast.evolution.alignment.AscertainedAlignment
beast.evolution.alignment.FilteredAlignment
BEASTObject that performs calculations based on the State.
Unordered set mapping keys to values
Class representing alignment data
"""
@with_kw mutable struct Alignment <: CalculationNode
    name::NString=nothing
    id::NString=nothing
    sequence::Union{Vector{Sequence}, Nothing}=nothing                 # sequence and meta data for particular taxon
    # taxa::NTaxonSet=nothing         # An optional taxon-set used only to sort the sequences into the same order as they appear in the taxon-set
    statecount::NInt64=nothing      # maximum number of states in all sequences
    dataType::NString="nucleotide"  # data type, one of {aminoacid=aminoacid, binary=binary, integer=integer, nucleotide=nucleotide, standard=standard, twoStateCovarion=twoStateCovarion, user defined=user defined}
    # userDataType::NString=nothing # non-standard, user specified data type, if specified 'dataType' is ignored
    strip::NBool=nothing              # sets weight to zero for sites that are invariant (e.g. all 1, all A or all unkown)
    weights::NVString=nothing       # comma separated list of weights, one for each site in the sequences. If not specified, each site has weight 1
    ascertained::NBool=nothing        # is true if the alignment allows ascertainment correction, i.e., conditioning the Felsenstein likelihood on excluding constant sites from the alignment
    excludefrom::NInt64=nothing             # first site to condition on, default 0
    excludeto::NInt64=nothing               # last site to condition on (but excluding this site), default 0
    excludeevery::NInt64=nothing            # interval between sites to condition on (default 1)
    includefrom::NInt64=nothing              # first site to condition on, default 0
    includeto::NInt64=nothing               # last site to condition on (but excluding this site), default 0
    includeevery::NInt64=nothing            # interval between sites to condition on (default 1)
end


# function Alignment(alignment::AbstractXMLNode, id::Union{Nothing, String}=nothing)
#     LightXML.name(alignment) in ["data", "alignment"] || return nothing
#     attrib_dct = attributes_dict(alignment)
#     seqs = alignment["sequence"]
#     out = Alignment(id = isnothing(id) ? "alignment" : id,
#                     sequence = Sequence.(seqs, nothing))
#     complete!(out, attrib_dct)
#     return out
# end


# function Alignment(alignment::XMLDocument, id::Union{Nothing, String}=nothing)
#     return Alignment(root(alignment), id)
# end


function Alignment(nwk::Node, id::String="alignment")
    return Alignment(id=id,
                     sequence=[Sequence(id=label, taxon=label, value="?", totalcount=4) for label in get_tip_labels(nwk)],
    )
end


"""
TaxonSet

For identifying a single taxon
A TaxonSet is an ordered set of taxa. The order on the taxa is provided at the time of construction either from a list of taxon objects or an alignment.
"""
@with_kw mutable struct TaxonSet <: BEASTObject
    name::NString=nothing
    id::NString=nothing
    taxon::Union{Nothing, Vector{Taxon}}=nothing   # list of taxa making up the set
    alignment::Union{Nothing, String, Alignment}=nothing   # alignment where each sequence represents a taxon
end


# """
# SimulatedAlignment

# BEASTObject that performs calculations based on the State.
# Unordered set mapping keys to values
# Class representing alignment data
# An alignment containing sequences randomly generated using agiven site model down a given tree.
# """
# @with_kw struct SimulatedAlignment
#     data::Alignment         # alignment data which specifies datatype and taxa of the beast.tree
#     tree::Tree              # phylogenetic beast.tree with sequence data in the leafs
#     siteModel::SiteModel    # site model for leafs in the beast.tree
#     branchRateModel::NBranchRateModel=nothing   # A model describing the rates on the branches of the beast.tree.
#     sequencelength::NINt64=1_000                # nr of samples to generate (default 1000).
#     outputFileName::NString=nothing             # If provided, simulated alignment is additionally written to this file.
#     sequence::Union{Sequence, Vector{Sequence}, Nothing}=nothing                 # sequence and meta data for particular taxon
#     # taxa::NTaxonSet=nothing         # An optional taxon-set used only to sort the sequences into the same order as they appear in the taxon-set
#     statecount::NInt64=nothing      # maximum number of states in all sequences
#     dataType::NString="nucleotide"  # data type, one of {aminoacid=aminoacid, binary=binary, integer=integer, nucleotide=nucleotide, standard=standard, twoStateCovarion=twoStateCovarion, user defined=user defined}
#     # userDataType::
#     strip::NBool=false              # sets weight to zero for sites that are invariant (e.g. all 1, all A or all unkown)
#     weights::NVString=nothing       # comma separated list of weights, one for each site in the sequences. If not specified, each site has weight 1
#     ascertained::NBool=false        # is true if the alignment allows ascertainment correction, i.e., conditioning the Felsenstein likelihood on excluding constant sites from the alignment
#     excludefrom::NInt64=0             # first site to condition on, default 0
#     excludeto::NInt64=0               # last site to condition on (but excluding this site), default 0
#     excludeevery::NInt64=1            # interval between sites to condition on (default 1)
#     inludefrom::NInt64=0              # first site to condition on, default 0
#     includeto::NInt64=0               # last site to condition on (but excluding this site), default 0
#     includeevery::NInt64=1            # interval between sites to condition on (default 1)
# end