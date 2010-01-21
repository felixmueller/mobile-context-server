require 'rubygems'
require 'sinatra'
require 'haml'
require 'active_support'
require 'curb'
require 'json'

require 'lib/parser'
require 'lib/sparqlFactory'
require 'lib/sesameAdapter'
require 'lib/helper'

get '/contexts.xml' do
  #Beispiel: http://localhost:4567/contexts.xml?user=FelixMueller
  params[:type]="Context" if params[:type].nil?
  if params[:attributes].nil?
    result = SparqlFactory.getAllContexts(params[:user],params[:type])
    content_type 'text/xml', :charset => 'utf-8'
    haml :contexts,:locals => {:result => result}
  #http://localhost:4567/contexts.xml?user=FelixMueller&type=LocationContext&attributes={%27longitude%27=%3E%2761%27,%27latitude%27=%3E%2761%27}
  else
    raise "ERROR: Fehlerhafter Parameter 'user'" if params[:user].nil? 
    raise "ERROR: Fehlerhafter Parameter 'attributes'" if params[:attributes].nil? 
    # attributes hash auflösen
    attributes=eval(params[:attributes])
    result = SparqlFactory.getContext(params[:user],params[:type],attributes)
    content_type 'text/xml', :charset => 'utf-8'
    # template context mit lokal result->result
    haml :contexts,:locals => {:result => result}
  end
end

# get '/predicates.xml' do
#   result = SparqlFactory.getAllPredicates()
#   haml :predicates,:locals => {:result => result}
# end