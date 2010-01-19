class SparqlFactory
  @prefix="PREFIX rdfs:<http://www.w3.org/2000/01/rdf-schema#>
  PREFIX owl2xml:<http://www.w3.org/2006/12/owl2-xml#>
  PREFIX xsd:<http://www.w3.org/2001/XMLSchema#>
  PREFIX www:<http://www.mobileContext.de/>
  PREFIX owl:<http://www.w3.org/2002/07/owl#>
  PREFIX context:<http://www.mobileContext.de/context#>
  PREFIX rdf:<http://www.w3.org/1999/02/22-rdf-syntax-ns#>"
  
  def self.getContext(user,contextTyp,attributes)
    predicateQuery = getPredicates(user,contextTyp,attributes.keys)
    result = SesameAdapter.query("#{@prefix} #{predicateQuery}")
    result = Parser::Base.predicates(result)
    return [] if result.length==0 
    contextQuery = createContextQuery(user,contextTyp,result,attributes)
    result = SesameAdapter.query("#{@prefix} #{contextQuery}")
    result = Parser::Base.contextName(result)
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
  
  def self.createContextQueryAlt(user,contextTyp,predicates,attributes)
    #TODO: Make Predicates Optional
    where="?context rdf:type context:#{contextTyp}. ?context rdfs:label ?contextName. ?context context:belongsToUser context:#{user}."
    filter="FILTER ("
    predicates.each do |predicate|
      var =  attributes[predicate["variable"]]
      typeString = Helper::Base.getTypeString(predicate["type"])
      where += "?context <#{predicate['predicate']}> ?#{predicate['sparql']}. "
      filter += "?#{predicate['sparql']} #{predicate['operator']} '#{var}'#{typeString} && "
    end
    
    filter = filter[0..(filter.length-4)]
    result = "Select ?contextName where {#{where} #{filter})}"
  end
  
  def self.createContextQuery(user,contextTyp,predicates,attributes)
    #TODO: Make Predicates Optional
    where="?context rdf:type context:#{contextTyp}. ?context rdfs:label ?contextName. ?context context:belongsToUser context:#{user}."
    filter="FILTER ("
    vars=" "
    predicates.each do |predicate|
      var =  attributes[predicate["variable"]]
      typeString = Helper::Base.getTypeString(predicate["type"])
      where += " OPTIONAL {?context <#{predicate['predicate']}> ?#{predicate['sparql']}. FILTER (?#{predicate['sparql']} #{predicate['operator']} '#{var}'#{typeString})} "
      vars += "?#{predicate['sparql']} "
    end
    result = "Select ?contextName #{vars} where {#{where}}"
  end
end