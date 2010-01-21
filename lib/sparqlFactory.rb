class SparqlFactory

  #namespaces für sparql abfragen
  @prefix="PREFIX rdfs:<http://www.w3.org/2000/01/rdf-schema#>
  PREFIX owl2xml:<http://www.w3.org/2006/12/owl2-xml#>
  PREFIX xsd:<http://www.w3.org/2001/XMLSchema#>
  PREFIX www:<http://www.mobileContext.de/>
  PREFIX owl:<http://www.w3.org/2002/07/owl#>
  PREFIX context:<http://www.mobileContext.de/context#>
  PREFIX rdf:<http://www.w3.org/1999/02/22-rdf-syntax-ns#>"
  
  # hauptmethode
  def self.getContext(user,contextTyp,attributes)
    # 1) prädikate ermitteln (alle, die zu user und dem typ gehören!)
    predicateQuery = getPredicates(user,contextTyp,attributes.keys)
    # predicates: json-hash:
    predicates = SesameAdapter.query("#{@prefix} #{predicateQuery}")
    # parsen nach ruby hash:
    predicates = Parser::Base.predicates(predicates)
    
    # 2) kontext ermitteln (alle zu user und typ) 
    contextQuery = createContextQuery(user,contextTyp,predicates,attributes) 
    result = SesameAdapter.query("#{@prefix} #{contextQuery}")
    result = Parser::Base.contextName(result)
    # 3) filtern nach bedingungen (regeln)
    result = Helper::Base.filterResults(result,attributes,predicates)
  end
  
  def self.getAllContexts(user,typ)
    use = "?context context:belongsToUser context:#{user}." unless user.nil?
    query="Select ?contextName ?contextType where {#{use} ?context rdf:type context:#{typ}. ?context rdfs:label ?contextName. ?context rdf:type ?contextTyp. ?contextTyp rdfs:label ?contextType}"
    result = SesameAdapter.query("#{@prefix} #{query}")
    result = Parser::Base.parseAllContexts(result)
  end
  
  
  def self.getAllPredicates
    result = SesameAdapter.query("#{@prefix} Select distinct ?predicate ?operator ?variable ?sparql ?type where {?s ?predicate ?o. ?predicate rdfs:domain context:Context. ?predicate context:hasOperator ?operator. ?predicate context:hasVariable ?variable. ?predicate context:hasSparql ?sparql. ?predicate rdfs:range ?type.}")
    result = Parser::Base.parseAllPredicates(result)
  end
  
  def self.getPredicates(user,contextTyp,keys)
    union = predicateUnion(keys)
    result = "Select ?predicate ?operator ?variable ?sparql ?type where { #{union}. ?context ?predicate ?o. ?context context:belongsToUser context:#{user}. ?context rdf:type context:#{contextTyp}. ?predicate context:hasOperator ?operator. ?predicate context:hasVariable ?variable. ?predicate context:hasSparql ?sparql. ?predicate rdfs:range ?type.}"
  end
  
  def self.predicateUnion(array)
    result=" "
    array.each do |a|
      result += " {?predicate context:hasVariable '#{a}'} UNION"
    end
    result=result[0..result.length-6]
    result
  end
  
  def self.createContextQuery(user,contextTyp,predicates,attributes)
    where="?context rdf:type context:#{contextTyp}. ?context rdf:type ?contextTyp. ?contextTyp rdfs:label ?contextType. ?context rdfs:label ?contextName. ?context context:belongsToUser context:#{user}."
    vars=" "
    predicates.each do |predicate|
      var =  attributes[predicate["variable"]]
      where += " OPTIONAL {?context <#{predicate['predicate']}> ?#{predicate['sparql']}}. "
      vars += "?#{predicate['sparql']} "
    end
    result = "Select ?contextName ?contextType #{vars} where {#{where}}"
  end
end