#
#  sparqlFactory.rb
#  ContextServer
#  This class handles all SPARQL queries
#
#  Created by Felix on 19.01.10.
#  Copyright 2010 Felix Mueller (felixmueller@mac.com). All rights reserved.
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
    
    # Prepare variables
    vars = " "
    
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
  
  #
  # This method requests derived contexts based on the given hits.
  #
  # Parameters:
  #   hits: An array if all hits
  #
  # Returns:
  #   The derived contexts based on the given hits
  #
  def self.getDerivedContexts(hits)
    
    # Prepare the WHERE clause
    where = "?context rdfs:label ?contextName. "

    # Iterate all hits
    hits.each do |hit|
      
      # Add a clause for every hit
      where += "{?context context:hasSubContext <#{hit['context']}>} UNION "
      
    end

    # Remove the last "UNION"
    where = where[0..where.length-7]
    
    # Prepare the SPARQL query
    query = " SELECT DISTINCT ?contextName ?context
              WHERE {
                #{where}
              }"
              
    # Execute the SPARQL query
    result = SesameAdapter.query("#{@prefix} #{query}")

    # Parse the results to ruby
    result = Parser::Base.parseDerived(result)

    # Check for derived contexts
    result = checkForDerived(result, hits)

  end
  
  #
  # This method checks for derived contexts.
  #
  # Parameters:
  #   derived: The result to be checked
  #   check: Parameter to be passed to checkHits
  #
  # Returns:
  #   The check results
  #
  def self.checkForDerived(derived, check)
    
    # Prepare the return array
    returner=[]
    
    # Iterate all derived results
    derived.each do |deriv|
      
      # Get derived context
      context = deriv['context']
      
      # Prepare the SPARQL query
      query = " SELECT ?context ?contextName
                WHERE {
                  <#{context}> context:hasSubContext ?context. ?context rdfs:label ?contextName
                }"
                
      # Execute the SPARQL query      
      result = SesameAdapter.query("#{@prefix} #{query}")

      # Parse the results to ruby
      result = Parser::Base.parseDerived(result)

      # Check hits
      checkedHits = checkHits(result, check)

      # Add to return value
      if checkedHits == true
        returner.push deriv
      end
      
    end
    
    # Return results
    returner
  end  
  
  #
  # This method checks for hits.
  #
  # Parameters:
  #   first: The first context parameter array
  #   second: The second context parameter array
  #
  # Returns:
  #   true or false if hit occured
  #
  def self.checkHits(first, second)

    # Prepare the hits array
    hits=[]
    
    # Iterate all first items
    first.each do |firstItem|
      hit=false
      
      # Iterate all second items
      second.each do |secondItem|
        if(firstItem["context"] == secondItem["context"]) == true
          
          # Hit occured
          hit = true
          
        end
        
      end
      # Add hit
      hits.push firstItem if hit==true
    end
    
    # Return the hits
    hits == first ? true : false
    
  end
  
end