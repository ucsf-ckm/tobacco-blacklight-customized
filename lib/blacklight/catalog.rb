# author: rtang
# date: 22-April-2014

require "#{Blacklight.root}/lib/blacklight/catalog.rb"

module Blacklight::Catalog

  #override
  #to take care of grouped responses
  def render_search_results_as_json
    case
      when (@response.grouped?)
        {response: {grouped: @response.group, facets: search_facets_as_json, pages:pagination_info(@response)}}
      else
        {response: {docs: @document_list, facets: search_facets_as_json, pages: pagination_info(@response)}}
    end
  end

  # override
  # citation action, call get_solr_response_for_field_values_for_bookmarks
  def citation
    @response, @documents = get_solr_response_for_field_values_for_bookmarks(SolrDocument.unique_key,params[:id])
    respond_to do |format|
      format.html
      format.js { render :layout => false }
    end
  end

  #override
  # Email Action (this will render the appropriate view on GET requests and process the form and send the email on POST requests)
  def email
    @response, @documents = get_solr_response_for_field_values_for_bookmarks(SolrDocument.unique_key, params[:id])

     @documents.each do |d|
        b = Bookmark.find_by_document_id_and_user_id(d.id, current_or_guest_user.id)
        if !b.nil?
          b.last_action = "Emailed "
          b.last_action_date = Time.now
          b.save
        end
      end

    if request.post? and validate_email_params
      
      email = BookmarkMailer.email_bookmarks(@documents, {:to => params[:to], :message => params[:message]}, url_options, current_or_guest_user, request.host_with_port)

      #email = RecordMailer.email_record(@documents, {:to => params[:to], :message => params[:message]}, url_options)
      email.deliver

      flash[:success] = I18n.t("blacklight.email.success")

      respond_to do |format|
        format.html { redirect_to catalog_path(params['id']) }
        format.js { render 'email_sent' }
      end and return
    end

    respond_to do |format|
      format.html
      format.js { render :layout => false }
    end
  end
end
