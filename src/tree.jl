abstract type PopulationModel end

"""
TraitSet

A trait set represent a collection of properties of taxons, for the use of initializing a tree. The traits are represented as text content in taxon=value form, for example, for a date trait, wecould have a content of chimp=1950,human=1991,neander=-10000. All white space is ignored, so they canbe put on multiple tabbed lines in the XML. The type of node in the tree determines what happes with this information. The default Node only recognizes 'date', 'date-forward' and 'date-backward' as a trait, but by creating custom Node classes other traits can be supported as well.
"""
@with_kw mutable struct TraitSet <: BEASTObject
    name::NString=nothing
    id::NString=nothing              # Traitset id
    traitname::NString=nothing       # name of the trait, used as meta data name for the tree. Special traitnames that are recognized are 'age','date','date-forward' and 'date-backward'.
    units::NString=nothing   # name of the units in which values are posed, used for conversion to a real value. This can be [year, month, day] (default 'year')
    value::NString=nothing           # traits encoded as taxon=value pairs separated by commas
    taxa::Union{Nothing, String, Vector{TaxonSet}}=nothing  # contains list of taxa to map traits to
    dateFormat::NString=nothing     # the date/time format to be parsed, (e.g., 'dd/M/yyyy')
end


"""
Tree

implemented by the following
beast.evolution.speciation.CalibratedYuleInitialTree
beast.evolution.speciation.RandomGeneTree
beast.evolution.speciation.StarBeastStartState
beast.evolution.tree.RandomTree
beast.util.ClusterTree
beast.util.TreeParser
BEASTObject that performs calculations based on the State.
A node that can be part of the state.
Tree (the T in BEAST) representing gene beast.tree, species beast.tree, language history, or other time-beast.tree relationships among sequence data.

Logable: yes, this can be used in a log.
"""
@with_kw mutable struct Tree <: StateNode
    name::NString=nothing
    id::NString=nothing                  # Tree id
    # initial::NTree=nothing    # tree to start with
    trait::Union{Nothing, Vector{TraitSet}}=nothing    # trait information for initializing traits (like node dates) in the tree
    taxonset::Union{Nothing, Vector{TaxonSet}}=nothing # set of taxa that correspond to the leafs in the tree
    nodetype::NString="beast.evolution.tree.Node"    # type of the nodes in the beast.tree
    adjustTreeNodeHeights::NBool=true               # if true (default), then tree node heights are adjusted to avoid non-positive branch lengths. If you want to maintain zero branch lengths then you must set this to false.
    estimate::NBool=true                            # whether to estimate this item or keep constant to its initial value
end


"""
RandomTree

implemented by the following
beast.evolution.speciation.RandomGeneTree
BEASTObject that performs calculations based on the State.
A node that can be part of the state.
Tree (the T in BEAST) representing gene beast.tree, species beast.tree, language history, or other time-beast.tree relationships among sequence data.
This class provides the basic engine for coalescent simulation of a given demographic model over a given time period.

Logable: yes, this can be used in a log.
"""
@with_kw mutable struct RandomTree <: StateNode
    name::NString=nothing
    id::NString=nothing                                          # Tree id
    taxa::Union{Nothing, String, Vector{Alignment}}=nothing     # set of taxa to initialise tree specified by alignment
    populationModel::Union{Nothing, Vector{<:PopulationFunction}}=nothing         # population function for generating coalescent???
    # constraint::
    rootHeight::NFloat64=nothing        # If specified the tree will be scaled to match the root height, if constraints allow this
    initial::Union{Nothing, Vector{Tree}}=nothing      # tree to start with
    trait::Union{Nothing, Vector{TraitSet}}=nothing    # trait information for initializing traits (like node dates) in the tree
    taxonset::Union{Nothing, TaxonSet}=nothing # set of taxa that correspond to the leafs in the tree
    nodetype::NString=nothing   # type of the nodes in the beast.tree. Default="beast.evolution.tree.Node"
    adjustTreeNodeHeights::NBool=nothing   # if true (default), then tree node heights are adjusted to avoid non-positive branch lengths. If you want to maintain zero branch lengths then you must set this to false.
    estimate::NBool=nothing                # whether to estimate this item or keep constant to its initial value
end


"""
TreeParser

BEASTObject that performs calculations based on the State.
A node that can be part of the state.
Tree (the T in BEAST) representing gene beast.tree, species beast.tree, language history, or other time-beast.tree relationships among sequence data.
Create beast.tree by parsing from a specification of a beast.tree in Newick format (includes parsing of any meta data in the Newick string).

Logable: yes, this can be used in a log.
"""
@with_kw mutable struct TreeParser <: StateNode
    name::NString=nothing
    id::NString=nothing                                 # Tree id
    IsLabelledNewick::NBool=false                       # Is the newick tree labelled (alternatively contains node numbers)? Default=false.
    taxa::Union{Nothing, String, Alignment}=nothing     # Specifies the list of taxa represented by leaves in the beast.tree
    newick::NString=nothing                             # initial beast.tree represented in newick format
    offset::NInt64=nothing                              # offset if numbers are used for taxa (offset=the lowest taxa number) default=1
    threshold::NFloat64=nothing                         # threshold under which node heights (derived from lengths) are set to zero. Default=0.
    singlechild::NBool=nothing                          # flag to indicate that single child nodes are allowed. Default=true.
    adjustTipHeights::NBool=nothing                     # flag to indicate if tipHeights shall be adjusted when date traits missing. Default=true.
    scale::NFloat64=nothing                             # scale used to multiply internal node heights during parsing. Useful for importing starting from external programs, for instance, RaxML tree rooted using Path-o-gen. Default=1.0
    binarizeMultifurcations::NBool=nothing              # Whether or not to turn multifurcations into sequences of bifurcations. (Default true.)
    initial::Union{Nothing, Tree}=nothing               # tree to start with
    trait::Union{Nothing, Vector{TraitSet}}=nothing     # trait information for initializing traits (like node dates) in the tree
    taxonset::Union{Nothing, TaxonSet}=nothing          # set of taxa that correspond to the leaves in the tree
    nodetype::NString=nothing                           # type of the nodes in the beast.tree. Default="beast.evolution.tree.Node"
    adjustTreeNodeHeights::NBool=nothing                # if true (default), then tree node heights are adjusted to avoid non-positive branch lengths. If you want to maintain zero branch lengths then you must set this to false.
    estimate::NBool=nothing                             # whether to estimate this item or keep constant to its initial value. Default=true
end


function TreeParser(nwk::Node, id::String="Tree")
    return TreeParser(id=id,
                      newick=string(nwk),
                      IsLabelledNewick=true,
                      adjustTipHeights=false)
end