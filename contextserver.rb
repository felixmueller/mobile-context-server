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

get '/contexts/:id' do 
  raise "ERROR: Fehlerhafter Parameter 'user'" if params[:user].nil? 
  raise "ERROR: Fehlerhafter Parameter 'attributes'" if params[:attributes].nil? 
  attributes=eval(params[:attributes])
  result = SparqlFactory.getContext(params[:user],params[:id],attributes)
  haml :context,:locals => {:result => result}
end

get '/predicates' do
  result = SparqlFactory.getAllPredicates()
  haml :predicates,:locals => {:result => result}
end
