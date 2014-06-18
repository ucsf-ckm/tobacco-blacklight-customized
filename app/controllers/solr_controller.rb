require 'rsolr'

class SolrController < ApplicationController  

  def select
    # Direct connection
    
    solr = RSolr.connect :url => Blacklight.solr_yml[Rails.env]['url']
    
    response = solr.get 'select', :params => params.except(:action, :controller) 

    render json: response
  end
  
end
