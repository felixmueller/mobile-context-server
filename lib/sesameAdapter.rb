module SesameAdapter
  
  #@url="http://mims03.gm.fh-koeln.de:8282/openrdf-sesame/repositories/channelthing"
  
  #repo = "mobileContext"
  @url="http://mims03.gm.fh-koeln.de:8282/openrdf-sesame/repositories/contextService"
  #@url="http://localhost:8080/openrdf-sesame/repositories/#{repo}"

  DATA_TYPES = {
    :XML => "application/sparql-results+xml",
    :JSON => "application/sparql-results+json"}
  
  def self.query(query, infer=true, options={})
    options = {:result_type => DATA_TYPES[:JSON],:method => :get,:query_language => "sparql"}.merge(options)
    easy = Curl::Easy.new
    easy.headers["Accept"] = options[:result_type]
    easy.url = (@url + "?" + "query=#{ easy.escape(query) }&"+"queryLn=#{ easy.escape(options[:query_language]) }" + "&infer=#{infer}")
     easy.http_get
    return easy.body_str
  end
  
  def self.post(data)
    easy = Curl::Easy.new
    easy.headers["Content-Type"] = "application/x-rdftransaction"
    easy.url = @url + "/statements"
    easy.http_post(data)
  end
  
end