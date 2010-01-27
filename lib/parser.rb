#
#  parser.rb
#  ContextServer
#  This class parses query results delivered from the OpenRDF Sesame semantic triple store in JSON format
#
#  Created by Felix on 19.01.10.
#  Copyright 2010 Felix Mueller (felixmueller@mac.com). All rights reserved.
#
#  Special thanks to Stephan Pavlovic for his hints & support!
#

module Parser
  
  class Base
  
    #
    # This method parses predicates out of a JSON document.
    #
    # Parameters:
    #   json_document: The JSON document
    #
    # Returns:
    #   The predicates array
    #
    def self.predicates(json_document)
      
      # Prepare return value
      predicates=[]
      
      # Parse the JSON document
      json_document = JSON.parse(json_document)

      # Bind the results
      json_document["results"]["bindings"].each do |binding|
        predicate = binding["predicate"]["value"]
        variable = binding["variable"]["value"]
        operator = binding["operator"]["value"]
        sparql = binding["sparql"]["value"]
        type = binding["type"]["value"]
        hash={"predicate"=>predicate,"variable"=>variable,"operator"=>operator,"sparql"=>sparql,"type"=>type}
        predicates.push hash
      end
      
      # Return the results
      predicates
      
    end
    
    #
    # This method parses all contexts out of a JSON document.
    #
    # Parameters:
    #   json_document: The JSON document
    #
    # Returns:
    #   The contexts array
    #
    def self.parseAllContexts(json_document)

      # Prepare return value
      results=[]
      
      # Parse the JSON document
      json_document = JSON.parse(json_document)

      # Bind the results
      json_document["results"]["bindings"].each do |binding|
         contextName = binding["contextName"]["value"]
         contextType = binding["contextType"]["value"]
         hash={"contextName"=>contextName,"contextType"=>contextType}
         results.push hash
      end
      
      # Return the results
      results
      
    end
    
    #
    # This method parses all context names out of a JSON document.
    #
    # Parameters:
    #   json_document: The JSON document
    #
    # Returns:
    #   The context names array
    #
    def self.contextName(json_document)
      
      # Prepare return value
      contexts=[]
      
      # Parse JSON document
      json_document = JSON.parse(json_document)

      # Prepare bindings
      vars =[]
      
      # Bind all variables
      json_document["head"]["vars"].each do |var|
        vars.push var
      end
      
      # Bind all results
      json_document["results"]["bindings"].each do |binding|
        context={}
        vars.each do |var|
          if binding[var].nil?
            context[var] = nil 
          else
            context[var] = binding[var]["value"] 
          end
        end
        contexts.push context
      end
      
      # Validate and return the results
      validate(contexts)
      
    end
    
    #
    # This method validates an array.
    #
    # Parameters:
    #   array: The array
    #
    def self.validate(array)
      
      # Iterate array
      array.each do |item|
        item.delete_if {|key, value| value.nil? }
      end
      
    end

    #
    # This method parses all derived contexts out of a JSON document.
    #
    # Parameters:
    #   json_document: The JSON document
    #
    # Returns:
    #   The derived contexts array
    #
    def self.parseDerived(json_document)
      
      # Prepare the return value
      contexts=[]
      
      # Parse the JSON document
      json_document = JSON.parse(json_document)

      # Bind the results
      json_document["results"]["bindings"].each do |binding|
         contexts.push binding["context"]["value"]
      end
      
      # Return results
      contexts
      
    end
    
  end
  
end