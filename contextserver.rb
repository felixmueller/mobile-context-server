#
#  contextserver.rb
#  ContextServer
#  This is the Sinatra main web application
#
#  Created by Felix on 19.01.10.
#  Copyright 2009 Felix Mueller (felixmueller@mac.com). All rights reserved.
#
#  Special thanks to Stephan Pavlovic for his hints & support!
#

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

#
# Use HTTP Basic authentication
#
#use Rack::Auth::Basic do |username, password|  
#  [username, password] == ['user', 'pass']
#end

#
# This method delivers the ontology file for semantic consistency
#
# Parameters:
#   none
#
# Examples:
#   GET http://contextserver.felixmueller.name/context#
#
# Returns:
#   context.owl: The ontology
#
get '/context' do
  
  # Deliver the ontology file
  send_file('ontology/context.owl')

end

#
# This method delivers all matching contexts via HTTP-GET
#
# Parameters:
#   user (optional): The name of the user the contexts belong to
#   type (optional): The type of the contexts
#   attributes (optional): The attributes with its values gathered from the client
#
# Examples:
#   GET http://localhost:4567/contexts.xml?user=FelixMueller
#   GET http://localhost:4567/contexts.xml?user=FelixMueller&type=LocationContext&attributes={'longitude'=>'61','latitude=>'59'}
#
# Returns:
#   contexts.xml: The results as XML rendered through the template "views/contexts.haml"
#
get '/contexts.xml' do
  
  # The default type is "Context" if none is specified
  params[:type]="Context" if params[:type].nil?
  
  # No attributes were specified
  if params[:attributes].nil?
    
    # Check if "user" parameter was specified
    raise "Error with parameter 'user'" if params[:user].nil? 
    
    # All contexts for the given user are requested from the sparql factory
    result = SparqlFactory.getAllContexts(params[:user], params[:type])

  # Attributes were specified
  else
    
    # Check if "attributes" parameter was specified
    raise "Error with parameter 'attributes'" if params[:attributes].nil?
    
    # The attributes are read from the attributes array
    attributes = eval(params[:attributes])
    
    # All contexts for the given matching the given attributes are requested from the sparql factory
    result = SparqlFactory.getContext(params[:user], params[:type],attributes)
  
  end
  
  # The returning XML file is set up
  content_type 'text/xml', :charset => 'utf-8'

  # The returning template is the "contexts.haml" template
  haml :contexts, :locals => {:result => result}
end

# get '/predicates.xml' do
#   result = SparqlFactory.getAllPredicates()
#   haml :predicates,:locals => {:result => result}
# end