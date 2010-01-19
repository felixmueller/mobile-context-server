module Helper
  class Base
@types={"http://www.w3.org/2001/XMLSchema#time"=>"^^xsd:time","http://www.w3.org/2001/XMLSchema#float"=>"^^xsd:float","http://www.w3.org/2001/XMLSchema#integer"=>"^^xsd:integer"}
    def self.getTypeString(typ)
      resultString=""
      if @types.keys.include?(typ)
        resultString=@types[typ]
      end
      resultString
    end 
  end
end