#
#  helper.rb
#  ContextServer
#  This class contains helper methods for the context server application
#
#  Created by Felix on 19.01.10.
#  Copyright 2010 Felix Mueller (felixmueller@mac.com). All rights reserved.
#
#  Special thanks to Stephan Pavlovic for his hints & support!
#

module Helper
  
  class Base
    
    #
    # This method filters all results based on the rules defined by the predicates.
    #
    # Parameters:
    #   results: The results to be filtered
    #   attributes: The given attributes
    #   predicates: The given predicates
    #
    # Returns:
    #   The filtered results
    #
    def self.filterResults(results, attributes, predicates)
      
      # Prepare the results array
      res = []
      
      # Iterate all results
      results.each do |result|
        if (result.keys.length > 3)
          res.push result
        end
      end
      
      # Map all predicates
      pres = map(predicates)
      
      # Prepare the return array
      returnArray = []
      
      # Iterate all results
      res.each do |result|
        
        # Prepare the flags
        hit = bool = true
        
        # Iterate all results
        result.each do |k,v|
          if (k != "contextName" && k != "contextType" && k != "context")

            # Check the type
            case pres[k]['type']

              # If the type is "time", the time has to be parsed
              when "http://www.w3.org/2001/XMLSchema#time" 
                then bool = eval("Time.parse('#{v}') #{pres[k]['operator']} Time.parse('#{attributes[pres[k]['variable']]}')")

              # If the type is "string", the string has to be escaped
              when "http://www.w3.org/2001/XMLSchema#string" 
                then bool = eval("'#{v}' #{pres[k]['operator']} '#{attributes[pres[k]['variable']]}'")

              # If the type is other, a numeric evaluation can be done
              else
                bool = eval("#{v} #{pres[k]['operator']} #{attributes[pres[k]['variable']]}") 

             end

             # Save the hit
             hit &= bool

          end

        end

        # Add to results if match occured
        returnArray.push result if hit == true
      end 

      # Prepare and return the results
      result = getDerivedContexts(returnArray)
      returnArray += result
      returnArray
      
    end
    
    
    #
    # This method maps all given predicates.
    #
    # Parameters:
    #   predicates: The predicates array
    #
    # Returns:
    #   The mapped results
    #
    def self.map(predicates)
      
      # Prepate the return value
      hash={}
      
      # Iterate all predicates
      predicates.each do |predicate|
        
        # Map predicates
        hash[predicate['sparql']] = {"variable"=>predicate['variable'],"operator"=>predicate['operator'],"type"=>predicate['type']} 

      end
      
      # Return result
      hash
      
    end
    
    #
    # This method sets up the derived contexts for all given hits.
    #
    # Parameters:
    #   hits: The given hits
    #
    # Returns:
    #   A hash with all derived contexts from the hits
    #
    def self.getDerivedContexts(hits)
      
      # Get all derived contexts from the sparqlFactory
      result = SparqlFactory.getDerivedContexts(hits)
      
      # Prepare the return values
      ret=[]
      
      # Iterate all results
      result.each do |res|
        
        # Add the context name and type to the results hash
        hash = {"contextName"=>res,"contextType"=>"DerivedContext"}
        
        # Add the contexts to the return hash
        ret.push hash
        
      end

      # Return the result hash
      ret
      
    end
    
  end
  
end