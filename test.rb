require 'rubygems'
require 'sinatra'
require 'haml'
require 'lib/parser'
require 'lib/sparqlFactory'
require 'lib/sesameAdapter'
require 'lib/helper'
require 'active_support'
require 'rubygems'
require 'curb'
require 'json'


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