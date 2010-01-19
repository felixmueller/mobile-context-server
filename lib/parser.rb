module Parser
  class Base
    def self.predicates(json_document)
      predicates=[]
      json_document = JSON.parse(json_document)
      json_document["results"]["bindings"].each do |binding|
        predicate = binding["predicate"]["value"]
        variable = binding["variable"]["value"]
        operator = binding["operator"]["value"]
        sparql = binding["sparql"]["value"]
        type = binding["type"]["value"]
        hash={"predicate"=>predicate,"variable"=>variable,"operator"=>operator,"sparql"=>sparql,"type"=>type}
        predicates.push hash
      end
      predicates
    end
    
    def self.contextName(json_document)
      contexts=[]
      json_document = JSON.parse(json_document)
      vars =[]
      json_document["head"]["vars"].each do |var|
        vars.push var
      end
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
      validate(contexts)
    end
    
    def self.parseAllPredicates(json_document)
      predicates=[]
      json_document = JSON.parse(json_document)
      json_document["results"]["bindings"].each do |binding|
        name = binding["predicate"]["value"]
        predicates.push name
      end
      predicates
    end
    
    def self.validate(array)
      ret=[]
      array.each do |arr|
        result=true
        arr.values.each do |value|
          result=false if value.nil?
        end
        ret.push arr unless result==false
      end
      ret
end

  end
end