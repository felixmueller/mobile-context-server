module Helper
  class Base

    # überprüfung der regeln und filtern
    def self.filterResults(results,attributes,predicates)
      res=[]
      pres = map(predicates)
      results.each do |result|
        hit=true
        bool=false
        result.each do |k,v|
          if (k!="contextName" && k!= "contextType")
            if pres[k]['type']!= "http://www.w3.org/2001/XMLSchema#time"
              bool = eval("#{v} #{pres[k]['operator']} #{attributes[pres[k]['variable']]}") 
            else
              bool = eval("Time.parse('#{v}') #{pres[k]['operator']} Time.parse('#{attributes[pres[k]['variable']]}')")
            end
          end
          hit=bool if bool==false
        end
        res.push result if hit==true
      end
      res
    end 
    
    def self.map(predicates)
      hash={}
      predicates.each do |pre|
        hash[pre['sparql']] = {"variable"=>pre['variable'],"operator"=>pre['operator'],"type"=>pre['type']} 
      end
      hash
    end
  end
end