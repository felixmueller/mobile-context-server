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
  # Returns:
  #   All matching contexts for a given user and a given type
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
  
  #
  # This method delivers all contexts for a given user and a given type
  # matching the given attributes.
  #
  # Parameters:
  #   user: The name of the user the contexts belong to
  #   type: The type of the contexts
  #   attributes: The attributes with its values gathered from the client
  #
  # Returns:
  #   All matching contexts for a given user, a given type and the given attributes
  #
  def self.getContext(user, type, attributes)
    
    # Prepare the query that requests all predicates that belong to the given user and the given type
    predicateQuery = getPredicateQuery(user, type, attributes.keys)
    
    # Execute the query that requests all predicates that belong to the given user and the given type
    predicates = SesameAdapter.query("#{@prefix} #{predicateQuery}")
    
    # Parse the JSON result to ruby
    predicates = Parser::Base.predicates(predicates)
    
    # Prepare the query that requests all contexts that match the given user and the given type
    contextQuery = createContextQuery(user, type, predicates, attributes)

    # Execute the query that requests all contexts that match the given user and the given type
    result = SesameAdapter.query("#{@prefix} #{contextQuery}")

    # Parse the JSON result to ruby
    result = Parser::Base.contextName(result)
    
    # Filter the results to match the given rules
    result = Helper::Base.filterResults(result, attributes, predicates)
  
  end
  
  #
  # This method delivers the query to get all predicates for a given user and a given type
  # matching the given attributes.
  #
  # Parameters:
  #   user: The name of the user the contexts belong to
  #   type: The type of the contexts
  #   keys: The attributes with its values gathered from the client
  #
  # Returns:
  #   The query to get all matching predicates for a given user, a given type and the given attributes
  #
  def self.getPredicateQuery(user, type, keys)
    
    # Combine all attribute keys with a SPARQL UNION clause
    union = predicateUnion(keys)
    
    # Return the SPARQL query 
    result = "  SELECT DISTINCT ?predicate ?operator ?variable ?sparql ?type
                WHERE {
                  #{union}.
                  ?context    ?predicate            ?o.
                  ?context    context:belongsToUser context:#{user}.
                  ?predicate  context:hasOperator   ?operator.
                  ?predicate  context:hasVariable   ?variable.
                  ?predicate  context:hasSparql     ?sparql.
                  ?predicate  rdfs:range            ?type.
                }"
  end
  
  #
  # This method delivers the union clauses for all variables in the given attributes array.
  #
  # Parameters:
  #   array: The array with the attributes
  #
  # Returns:
  #   The union clauses for all variables in the given attributes array
  #
  def self.predicateUnion(array)
    
    # Prepare the result
    result=" "
    
    # Iterate all variables in the attributes array
    array.each do |variable|
      
      # Add a SPARQL UNION clause for every variable
      result += " {?predicate context:hasVariable '#{variable}'} UNION"

    end
    
    # Remove the last " UNION"
    result = result[0..result.length-6]
    
    # Return the result
    result
    
  end
  
  #
  # This method delivers the final query to get all predicates for a given user
  # and a given type matching the rules defined by the context model.
  #
  # Parameters:
  #   user: The name of the user the contexts belong to
  #   type: The type of the contexts
  #   predicated: All predicates for the rules defined by the context model
  #   attributes: The attributes with its values gathered from the client
  #
  # Returns:
  #   The final query to get all predicates for a given user
  #   and a given type matching the rules defined by the context model
  #  
  def self.createContextQuery(user, type, predicates, attributes)
    
    # Create the WHERE clause for the SPARQL query
    where = " ?context    rdf:type              context:#{type}.
              ?context    rdf:type              ?contextTyp.
              ?contextTyp rdfs:label            ?contextType.
              ?context    rdfs:label            ?contextName.
              ?context    context:belongsToUser context:#{user}."
    
    vars = " "
    @pres = predicates
    @attrs = attributes
    
    # Iterate all predicates
    predicates.each do |predicate|
    
      #var = attributes[predicate["variable"]]
    
      # Add clauses for every predicate
      where += " OPTIONAL {?context <#{predicate['predicate']}> ?#{predicate['sparql']}}. "
      vars += "?#{predicate['sparql']} "
    
    end
    
    # Create the final SPARQL query and return it
    result = "  SELECT ?contextName ?contextType ?context #{vars}
                WHERE {
                  #{where}
                }"
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
  
  #  def self.getAllPredicates
  #    result = SesameAdapter.query("#{@prefix} Select distinct ?predicate ?operator ?variable ?sparql ?type where {?s ?predicate ?o. ?predicate rdfs:domain context:Context. ?predicate context:hasOperator ?operator. ?predicate context:hasVariable ?variable. ?predicate context:hasSparql ?sparql. ?predicate rdfs:range ?type.}")
  #    result = Parser::Base.parseAllPredicates(result)
  #  end
  
end