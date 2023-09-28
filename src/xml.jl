function Base.join(x::VFloat64, delim="")
    return join([isinf(i) ? "Infinity" : string(i) for i in x], delim)
end


function LightXML.new_element(tag::String, attributes)
    element = new_element(tag)
    set_attributes(element, attributes)
    return element
end


function LightXML.add_child(parent::XMLElement, child_tag::String, attributes::Dict)
    child = new_element(child_tag)
    set_attributes(child, attributes)
    add_child(parent, child)
    return parent
end


function LightXML.create_root(xml::XMLDocument, tag::String, attributes)
    rt = create_root(xml, tag)
    set_attributes(rt, attributes)
    return rt
end


function LightXML.new_element(obj::BEASTObject, name=nothing)
    T = typeof(obj)
    attribs = [field for field in fieldnames(T) if !isnothing(getfield(obj, field)) && !isa(getfield(obj, field), Vector{<:BEASTObject})]
    attrib_dct = Dict(attribs .=> [isa(x, Vector) ? join(x, " ") : string(x) for x in getfield.(Ref(obj), attribs)])
    if !haskey(attrib_dct, :name)
        attrib_dct[:name] = isnothing(name) ? split(string(T), ".")[end] : name
        # println(attrib_dct[:name])
        # println(typeof(attrib_dct[:name]))
    end
    attrib_dct[:spec] = split(string(T), ".")[end]
    element = new_element(attrib_dct[:name], attrib_dct)
    children = [field for field in fieldnames(T) if isa(getfield(obj, field), Vector{<:BEASTObject})]
    for child in children
        for val in getfield(obj, child)
            add_child(element, new_element(val, string(child)))
        end
    end
    return element
end


function LightXML.new_element(obj::Loggable, name=nothing)
    T = typeof(obj)
    attribs = [field for field in fieldnames(T) if !isnothing(getfield(obj, field))]
    attrib_dct = Dict(attribs .=> getfield.(Ref(obj), attribs))
    return new_element("log", attrib_dct)
    # return new_element("log", Dict("idref"=>obj.idref))
end



function LightXML.XMLDocument(obj::BEASTObject)
    xml = XMLDocument()
    rt = create_root(xml, "beast", Dict("namespace"=>"beastfx.app.seqgen:beast.base.evolution.alignment:beast.base.evolution.tree:beast.base.evolution.sitemodel:substmodels.nucleotide:beast.base.evolution.substitutionmodel:beast.base.evolution.branchratemodel:beast.base.inference.parameter",
                                        "version"=>"2.7")
    )
    for field in fieldnames(typeof(obj))
        val = getfield(obj, field)
        if !isnothing(val)
            for idx in eachindex(val)
                add_child(rt, new_element(val[idx], string(field)))
            end
        end
    end
    return xml
end


function LightXML.XMLDocument(scr::BEASTScript, anom::Dict=Dict("clockRate"=>"clock.rate"))
    xml = XMLDocument()
    set_root(xml, new_element(scr))
    fix_anomalies!(root(xml), anom)
    return xml
end


function make(dct::Dict)
    return eval(dct[:spec])(dct)
end


function beast_xml(nwk::Node,
                   sequencelength::Int64,
                   clockRate::AbstractFloat,
                   outputFileName::String;
                   clockModel::Symbol=:StrictClockModel,
                   substModel::Symbol=:JukesCantor,
                   mutationRate::AbstractFloat=1.,
                   gammaCategoryCount::Integer=4,
                   shape::Union{Nothing, AbstractFloat}=nothing,
                   proportionInvariant::AbstractFloat=0.,
                   alignment_id::String="alignment",
                   tree_id::String="Tree",
                   merge=nothing,
                   iterations=nothing,
                   namespace="beastfx.app.seqgen:beast.base.evolution.alignment:beast.base.evolution.tree:beast.base.evolution.sitemodel:substmodels.nucleotide:beast.base.evolution.substitutionmodel:beast.base.evolution.branchratemodel:beast.base.inference.parameter",
                   version="2.7")

    alignment = Alignment(nwk, alignment_id)
    tree = TreeParser(nwk, tree_id)

    branchRateModel= Dict(:spec => clockModel, :clockRate => Dict(:spec => RealParameter, :name=>"clock.rate", :value=>clockRate))
    substModel = Dict(:spec => substModel)

    siteModel = SiteModel(id="siteModel",
                          mutationRate=mutationRate,
                          gammaCategoryCount=gammaCategoryCount,
                          shape=shape,
                          proportionInvariant=proportionInvariant,
                          substModel=make(substModel))

    seqgen = SequenceSimulator(id="seqgen",
                               data="@"*alignment_id,
                               tree="@"*tree_id,
                               siteModel=siteModel,
                               branchRateModel = make(branchRateModel),
                               sequencelength=sequencelength,
                               outputFileName=outputFileName,
                               merge=merge,
                               iterations=iterations)

    beast_script = BEASTScript(name="beast",
                               version=version,
                               namespace=namespace,
                               data=alignment,
                               tree=tree,
                               run=seqgen)

    return  XMLDocument(beast_script)
end


function beast_xml(alignmentFile::NString,
                   nwk::Node,
                   logFileName::String;
                   treePrior::DataType=BirthDeathSkylineModel,
                   initTree::Union{Nothing, Node}=nothing,
                   originInit::Union{Nothing, AbstractFloat}=nothing,
                   originPrior::Union{Nothing, Distributions.Distribution}=nothing,
                   reproductiveNumberInit::Union{Nothing, AbstractFloat}=nothing,
                   reproductiveNumberPrior::Union{Nothing, Distributions.Distribution}=nothing,
                   becomeUninfectiousRateInit::Union{Nothing, AbstractFloat, Vector{<:AbstractFloat}}=nothing,
                   becomeUninfectiousRatePrior::Union{Nothing, Distributions.Distribution, Vector{<:Distributions.Distribution}}=nothing,
                   samplingProportionInit::Union{Nothing, AbstractFloat, Vector{<:AbstractFloat}}=nothing,
                   samplingProportionPrior::Union{Nothing, Distributions.Distribution, Vector{<:Distributions.Distribution}}=nothing,
                   R0Init::Union{Nothing, Float64, Vector{<:AbstractFloat}}=nothing,
                   R0Prior::Union{Nothing, Distributions.Distribution, Vector{<:Distributions.Distribution}}=nothing,
                   R0AmongDemesInit::Union{Nothing, Float64, Vector{<:AbstractFloat}}=nothing,
                   R0AmongDemesPrior::Union{Nothing, Distributions.Distribution, Vector{<:Distributions.Distribution}}=nothing,
                   migrationMatrixInit::Union{Nothing, Float64, Vector{<:AbstractFloat}}=nothing,
                   migrationMatrixPrior::Union{Nothing, Distributions.Distribution, Vector{<:Distributions.Distribution}}=nothing,
                   frequenciesInit::Union{Nothing, Float64, Vector{<:AbstractFloat}}=nothing,
                   frequenciesPrior::Union{Nothing, Distributions.Distribution, Vector{<:Distributions.Distribution}}=nothing,
                   rhoInit::Union{Nothing, Float64, Vector{<:AbstractFloat}}=nothing,
                   rhoPrior::Union{Nothing, Distributions.Distribution, Vector{<:Distributions.Distribution}}=nothing,
                   stateNumber::Union{Nothing, Integer}=nothing,
                   gammaShapeInit::Union{Nothing, AbstractFloat}=nothing,
                   gammaShapePrior::Union{Nothing, Distributions.Distribution}=nothing,
                   clockRateInit::Union{Nothing, AbstractFloat}=nothing,
                   clockRatePrior::Union{Nothing, Distributions.Distribution}=nothing,
                   operator_weights::Dict{String, Float64}=Dict("reproductiveNumber"=>3., "becomeUninfectiousRate"=>3., "samplingProportion"=>3., "origin"=>3., "clockRate"=>3., "gammaShape"=>6.),
                   clockModel::Symbol=:StrictClockModel,
                   substitutionModel::Symbol=:JukesCantor,
                   mutationRate::AbstractFloat=1.,
                   gammaCategoryCount::Integer=4,
                   proportionInvariant::AbstractFloat=0.,
                   alignmentId::String="alignment",
                   treeId::String="Tree",
                   chainLength::Integer=10_000_000,
                   logEvery::Integer=5_000,
                   namespace="bdmm.evolution.speciation:beast.base.inference:beast.base.evolution.operator:beast.base.evolution.branchratemodel:beast.base.evolution.substitutionmodel:beast.base.evolution.sitemodel:beast.base.evolution.likelihood:beast.base.inference.distribution:bdsky.evolution.speciation:beast.base.evolution.tree:beast.base.inference.parameter:beast.base.evolution.alignment:beast.base.inference:beast.base.evolution.tree.coalescent",
                   version="2.7")

    alignment = Alignment(root(parse_file(alignmentFile)))
    alignment.id = alignmentId

    tipTimes = get_tip_dates(nwk, joinall=true)
    tipTypes = get_tip_types(nwk, joinall=true)
 
    tree = isnothing(initTree) ? RandomTree(id=treeId,
                          taxa="@"*alignmentId,
                          populationModel = ConstantPopulation(id="ConstantPopulation", 
                                                               popSize=[1.0]),
                          trait = [TraitSet(id="dateTrait", 
                                            value=tipTimes, 
                                            traitname="date", 
                                            taxa=[TaxonSet(id="taxonSet", 
                                                           alignment="@"*alignmentId
                                                           )]
                                            )]
                          ) : TreeParser(tree, id=treeId)    
    
    siteParameters = ["gammaShape", "clockRate"]
    siteInitial = [gammaShapeInit, clockRateInit]
    sitePriors = [gammaShapePrior, clockRatePrior]

    if treePrior == BirthDeathSkylineModel

        treeParameters = ["origin", "reproductiveNumber", "becomeUninfectiousRate", "samplingProportion"]
        modelId = "bdsky"

        initialConditions = [originInit, reproductiveNumberInit, becomeUninfectiousRateInit, samplingProportionInit]
        parameterPriors = [originPrior, reproductiveNumberPrior, becomeUninfectiousRatePrior, samplingProportionPrior]

    elseif treePrior == BirthDeathMigrationModelUncoloured

        treeParameters = ["origin", "R0", "R0AmongDemes", "becomeUninfectiousRate", "migrationMatrix", "samplingProportion", "frequencies"]
        modelId = "bdsky"

        initialConditions = [originInit, R0Init, R0AmongDemesInit, becomeUninfectiousRateInit, migrationMatrixInit, samplingProportionInit, frequenciesInit]
        parameterPriors = [originPrior, R0Prior, R0AmongDemesPrior, becomeUninfectiousRatePrior, migrationMatrixPrior, samplingProportionPrior, frequenciesPrior]

    end

    parameters = vcat(treeParameters, siteParameters)
    append!(initialConditions, siteInitial)
    append!(parameterPriors, sitePriors)

    # initial = [eval(Symbol(par * "Init")) for par in parameters]
    # priors = [eval(Symbol(par * "Prior")) for par in parameters]
    isnothing(initialConditions) && throw(MissingException(string(treePrior) * " expects initial values and priors for: " * join(parameters, ", ")))
    state = State(id="state",
                  stateNode = vcat(tree, [RealParameter(id=par, value=val) for (par, val) in zip(parameters, initialConditions)]))
    treeModel = treePrior(Dict(Symbol.(treeParameters) .=> "@".*treeParameters))
    treeModel.id = modelId
    treeModel.tree = "@"*treeId
    if treePrior == BirthDeathMigrationModelUncoloured
        treeModel.stateNumber = stateNumber
        treeModel.tiptypes = [TraitSet(id="type", traitname="type", taxa="@taxonSet", value=tipTypes)]
    end

    parameterPriors = [Prior(name="distribution", 
                             id=par*"Prior", 
                             x = "@"*par, 
                             distr = Distribution(prior)) 
                        for (par, prior) in zip(parameters, parameterPriors)]

    prior = CompoundDistribution(id="prior",
                                 distribution=vcat(treeModel, parameterPriors))


    branchRateModel= Dict(:spec => clockModel, :clockRate => "@clockRate")
    substModel = Dict(:spec => substitutionModel)

    siteModel = SiteModel(id="siteModel",
                          mutationRate=[mutationRate],
                          gammaCategoryCount=gammaCategoryCount,
                          shape="@gammaShape",
                          proportionInvariant=[proportionInvariant],
                          substModel=make(substModel))

    likelihood = CompoundDistribution(id="likelihood",
                                      distribution=[TreeLikelihood(id="treeLikelihood",
                                                                   data="@"*alignmentId,
                                                                   tree="@"*treeId,
                                                                   siteModel=[siteModel],
                                                                   branchRateModel=make(branchRateModel))])

    posterior = CompoundDistribution(id="posterior",
                                     distribution=[prior, likelihood])

    treeOperators = [eval(:($T(tree="@"*$treeId))) for T in subtypes(TreeOperator)]
    parameterOperators = [ScaleOperator(parameter = "@"*par, id=par*"Scaler", weight=operator_weights[par]) for par in parameters]

    operators = vcat(treeOperators, parameterOperators)

    traceLogger = Logger(sanitiseHeaders="true", 
                         logEvery=logEvery, 
                         model="@posterior", 
                         sort="smart", 
                         fileName=logFileName*".log",
                         log=[Loggable(idref=par) for par in vcat("posterior", "likelihood", "prior", "treeLikelihood", parameters)])

    screenLogger = Logger(logEvery=1_000,
                          id="screenlog",
                          log=[Loggable(idref=par) for par in ["posterior", "likelihood", "prior"]])

    treeLogger = Logger(logEvery=logEvery,
                        mode="tree",
                        id="treelog",
                        fileName=logFileName*".trees",
                        log=[Loggable(idref=treeId)])

    mcmc = MCMC(id="mcmc",
                chainLength=chainLength,
                state=state,
                distribution=posterior,
                operator=operators,
                logger=[traceLogger, screenLogger, treeLogger])

    beast_script = BEASTScript(name="beast",
                               version=version,
                               namespace=namespace,
                               data=alignment,
                            #    tree=tree,
                               run=mcmc)

    return  XMLDocument(beast_script)
end


# function beast_xml_from_template(alignment_file::String, nwk::Node, template::String)

#     xml = parse_file(template)
#     alignment = root(parse_file(alignment_file))
#     tipTimes = get_tip_dates(nwk, joinall=true)

#     trait_element = new_element("trait", Dict("value"=>tipTimes, "id"=>"dateTrait", "spec"=>"beast.base.evolution.tree.TraitSet", "traitname"=>"date"))
#     add_child(trait_element, "taxa", Dict("id"=>"taxonSet", "spec"=>"TaxonSet", "name"=>"taxa", "alignment"=>"@SequenceSimulator"))

#     tipTypes = get_tip_types(nwk, joinall=true)
#     add_child(root(xml)["run"][1]["distribution"][1]["distribution"][1]["distribution"][1], "tiptypes", Dict("id"=>"typeTraitSet", "spec"=>"beast.base.evolution.tree.TraitSet", "taxa"=>"@taxonSet", "traitname"=>"type", "value"=>tipTypes))

#     add_child(root(xml), alignment)
#     add_child(root(xml)["run"][1]["state"][1]["stateNode"][1], trait_element)

#     return xml
# end


function beast_xml_from_template(alignment_file::String, tip_times::String, tip_types::String, template::String)

    xml = parse_file(template)
    alignment = root(parse_file(alignment_file))

    trait_element = new_element("trait", Dict("value"=>tip_times, "id"=>"dateTrait", "spec"=>"beast.base.evolution.tree.TraitSet", "traitname"=>"date"))
    add_child(trait_element, "taxa", Dict("id"=>"taxonSet", "spec"=>"TaxonSet", "name"=>"taxa", "alignment"=>"@SequenceSimulator"))

    add_child(root(xml)["run"][1]["distribution"][1]["distribution"][1]["distribution"][1], "tiptypes", Dict("id"=>"typeTraitSet", "spec"=>"beast.base.evolution.tree.TraitSet", "taxa"=>"@taxonSet", "traitname"=>"type", "value"=>tip_types))

    add_child(root(xml), alignment)
    add_child(root(xml)["run"][1]["state"][1]["stateNode"][1], trait_element)

    return xml
end


function beast_xml_from_template(alignment_file::String, tip_times::String, template::String)

    xml = parse_file(template)
    alignment = root(parse_file(alignment_file))

    trait_element = new_element("trait", Dict("value"=>tip_times, "id"=>"dateTrait", "spec"=>"beast.base.evolution.tree.TraitSet", "traitname"=>"date"))
    add_child(trait_element, "taxa", Dict("id"=>"taxonSet", "spec"=>"TaxonSet", "name"=>"taxa", "alignment"=>"@SequenceSimulator"))

    add_child(root(xml), alignment)
    add_child(root(xml)["run"][1]["state"][1]["stateNode"][1], trait_element)

    return xml
end


macro varname(arg)
    string(arg)
end