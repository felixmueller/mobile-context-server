#
#  sparqlFactory.rb
#  ContextServer
#  This class handles all SPARQL queries
#
#  Created by Felix on 19.01.10.
#  Copyright 2009 Felix Mueller (felixmueller@mac.com). All rights reserved.
#
#  Special thanks to Stephan Pavlovic for his hints & support!
#

class SparqlFactory

  # Define the default namespace for every SPARQL query
  @prefix = "PREFIX rdfs:<http://www.w3.org/2000/01/rdf-schema#>
  PREFIX owl2xml:<http://www.w3.org/2006/12/owl2-xml#>
  PREFIX xsd:<http://www.w3.org/2001/XMLSchema#>
  PREFIX www:<http://contextserver.felixmueller.name/>
  PREFIX owl:<http://www.w3.org/2002/07/owl#>
  PREFIX context:<http://contextserver.felixmueller.name/context#>
  PREFIX rdf:<http://www.w3.org/1999/02/22-rdf-syntax-ns#>"
  
#  @predis = []
#  @attrs = {}
  
  #
  # This method delivers all matching contexts for a given user and a given type.
  #
  # Parameters:
  #   user: The name of the user the contexts belong to
  #   type: The type of the contexts
  #
  def self.getAllContexts(user, type)
    
    # Define the user query string if user was specified
    userTriple = "?context context:belongsToUser context:#{user}." unless user.nil?
    
    # Prepare the SPARQL query
    sparqlQuery = " SELECT ?contextName ?contextType
                    WHERE {
                      #{userTriple}
                      ?context      rdf:type      context:#{type}.
                      ?context      rdfs:label    ?contextName.
                      ?context      rdf:type      ?contextTyp.
                      ?contextTyp   rdfs:label    ?contextType.
                    }"
    
    # Query the triple store with the sesame adapter module
    result = SesameAdapter.query("#{@prefix} #{sparqlQuery}")
    
    # Parse the result with the parser module
    result = Parser::Base.parseAllContexts(result)
    
  end
  
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
  

  
  
  def self.getAllPredicates
    result = SesameAdapter.query("#{@prefix} Select distinct ?predicate ?operator ?variable ?sparql ?type where {?s ?predicate ?o. ?predicate rdfs:domain context:Context. ?predicate context:hasOperator ?operator. ?predicate context:hasVariable ?variable. ?predicate context:hasSparql ?sparql. ?predicate rdfs:range ?type.}")
    result = Parser::Base.parseAllPredicates(result)
  end
  
  def self.getPredicates(user,contextTyp,keys)
    union = predicateUnion(keys)
    result = "Select distinct ?predicate ?operator ?variable ?sparql ?type where { #{union}. ?context ?predicate ?o. ?context context:belongsToUser context:#{user}.  ?predicate context:hasOperator ?operator. ?predicate context:hasVariable ?variable. ?predicate context:hasSparql ?sparql. ?predicate rdfs:range ?type.}"
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
    @pres = predicates
    @attrs = attributes
    predicates.each do |predicate|
      var =  attributes[predicate["variable"]]
      where += " OPTIONAL {?context <#{predicate['predicate']}> ?#{predicate['sparql']}}. "
      vars += "?#{predicate['sparql']} "
    end
    result = "Select ?contextName ?contextType ?context #{vars} where {#{where}}"
  end
  
  def self.getDerivedContexts(hits)
    where = "?context rdfs:label ?contextName. "
    hits.each do |hit|
      where += "{?context context:hasSubContext <#{hit['context']}>} UNION "
    end
    where=where[0..where.length-7]
    query = "Select distinct ?contextName ?context  where { #{where}}"
    result = SesameAdapter.query("#{@prefix} #{query}")
    result = Parser::Base.parseDerived(result)
    result = checkForDerived(result,hits)
  end
  
  def self.checkForDerived(derived,check)
    returner=[]
    derived.each do |deriv|
      query = "Select ?context where {<#{derived}> context:hasSubContext ?context}"
      result = SesameAdapter.query("#{@prefix} #{query}")
      result = Parser::Base.parseDerived(result)
      bla = checkHits(result,check)
      if bla==true
        returner.push deriv.split("#")[1]
      end
    end
    returner
  end  
  
  def self.checkHits(one,two)
    hits=[]
    one.each do |on|
      hit=false
      two.each do |to|
        if(on==to["context"])==true
          hit=true
        end
      end
      hits.push on if hit==true
    end
    hits==one ? true : false
  end
  
  
end