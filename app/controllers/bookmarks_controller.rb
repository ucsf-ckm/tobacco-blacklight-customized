require "#{Blacklight.root}/app/controllers/bookmarks_controller"

# -*- encoding : utf-8 -*-
# note that while this is mostly restful routing, the #update and #destroy actions
# take the Solr document ID as the :id, NOT the id of the actual Bookmark action. 
class BookmarksController < CatalogController

  before_filter :verify_user

  ##
  # Give Bookmarks access to the CatalogController configuration
  include Blacklight::Configurable
  include Blacklight::SolrHelper

  copy_blacklight_config_from(CatalogController)
 
  def list
     @bookmarks = current_or_guest_user.bookmarks {|b| b.created_at }
     bookmark_ids = @bookmarks.collect { |b| b.created_at }

     @response, @document_list = get_solr_response_for_field_values_for_bookmarks(SolrDocument.unique_key, bookmark_ids)
     
  end

  def index
    
     @bookmarks = current_or_guest_user.bookmarks {|b| b.created_at }
     bookmark_ids = @bookmarks.collect { |b| b.document_id.to_s }

     @response, @document_list = get_solr_response_for_field_values_for_bookmarks(SolrDocument.unique_key, bookmark_ids)
  end

  # For adding a single bookmark, suggest use PUT/#update to 
  # /bookmarks/$docuemnt_id instead.
  # But this method, accessed via POST to /bookmarks, can be used for
  # creating multiple bookmarks at once, by posting with keys
  # such as bookmarks[n][document_id], bookmarks[n][title]. 
  # It can also be used for creating a single bookmark by including keys
  # bookmark[title] and bookmark[document_id], but in that case #update
  # is simpler. 
  def create
    
    if params[:note]
      
      bookmark = Bookmark.find_by_document_id_and_user_id(params[:id], current_or_guest_user.id) || Bookmark.create(:document_id => params[:id], user_id => current_or_guest_user.id)

      bookmark.notes = params[:notes]      
      
      bookmark.user = current_or_guest_user
      bookmark.save
      @bookmarks = [{ :document_id => params[:id] }]
      success = true
    else    
      if params[:bookmarks]
        @bookmarks = params[:bookmarks]
      else
        @bookmarks = [{ :document_id => params[:id] }]
      end

      current_or_guest_user.save! unless current_or_guest_user.persisted?

      success = @bookmarks.all? do |bookmark|
        current_or_guest_user.bookmarks.create(bookmark) unless current_or_guest_user.existing_bookmark_for(bookmark[:document_id])
      end
    end
    
    if request.xhr?
      success ? head(:no_content) : render(:text => "", :status => "500")
    else
      if @bookmarks.length > 0 && success
        #flash[:notice] = I18n.t('blacklight.bookmarks.add.success', :count => @bookmarks.length)
      elsif @bookmarks.length > 0
        flash[:error] = I18n.t('blacklight.bookmarks.add.failure', :count => @bookmarks.length)
      end

      redirect_to :back
    end
  end
  
  def clear    
    if Bookmark.delete_all(:user_id => current_or_guest_user.id)
      flash[:notice] = I18n.t('blacklight.bookmarks.clear.success') 
    else
      flash[:error] = I18n.t('blacklight.bookmarks.clear.failure') 
    end
    redirect_to :action => "index"
  end
  
  def download
    download = ""  
    bookmark_ids = []
    
    if request.get?
      params[:id].each do |value|
        b = Bookmark.find_by_document_id_and_user_id(value, current_or_guest_user.id)
        if !b.nil?
          b.last_action = "Downloaded "
          b.last_action_date = Time.now
          b.save
        end
        bookmark_ids << value
      end
    end
 
    @response, @document_list = get_solr_response_for_field_values_for_bookmarks(SolrDocument.unique_key, bookmark_ids)

    #legacy
    #Title	Author	Corporate Author	Date	Bates	Collection	Bookmark	Notes

    if params[:download_format] == "txt"
                    
    @document_list.each do |document|
      
      download << "Author: " + blank_if_not_nil(document['au']).to_s + "\n"
      download << "Title: " + blank_if_not_nil(document['ti']) + "\n"
      download << "Date: " + blank_if_not_nil(document['ddu']).to_s + "\n"
      download << "Source: " + blank_if_not_nil(document['source']) + "\n"
      download << "URL: http://#{request.host_with_port}/catalog/#{document.id}\n"
      download << "Bates: " + blank_if_not_nil(document['bn']) + "\n"
      download << "Notes: " + (Bookmark.find_by_document_id_and_user_id(document.id, current_or_guest_user.id).notes.nil? ? "" : Bookmark.find_by_document_id_and_user_id(document.id, current_or_guest_user.id).notes) + "\n"
      download << "\n"
    end
     
     elsif params[:download_format] == "csv"
     
        download << "Author,Title,Date,Bates,Source,URL,Notes\n"
        
        @document_list.each do |document|

          download << "\"" + blank_if_not_nil(document['au']).to_s.gsub("\"", "") + "\","
          download << "\"" + blank_if_not_nil(document['ti']).gsub("\"", "") + "\","
          download << "\"" + blank_if_not_nil(document['ddu']).to_s.gsub("\"", "") + "\","
          download << "\"" + blank_if_not_nil(document['bn']).gsub("\"", "") + "\","
          download << "\"" + blank_if_not_nil(document['source']).gsub("\"", "") + "\","
          download << "\"" + "http://#{request.host_with_port}/catalog/#{document.id}\","
          download << "\"" + (Bookmark.find_by_document_id_and_user_id(document.id, current_or_guest_user.id).notes.nil? ? "" : Bookmark.find_by_document_id_and_user_id(document.id, current_or_guest_user.id).notes).gsub("\"", "") + "\""
          download << "\n"
        end
        
      elsif params[:download_format] == "endnote.txt" || params[:download_format] == "refworks.txt" 
         @document_list.each do |document|
           download << "%A " + blank_if_not_nil(document['au']).to_s + "\n"
           download << "%T " + blank_if_not_nil(document['ti']).to_s + "\n"
           if document['ddu'].nil?
             download << "%8 " + "No Date" + "\n"
           else
             download << "%8 " + blank_if_not_nil(document['ddu'][0]).to_s[0..-5] + "\n"
           end
           if document['ddu'].nil?
             download << "%D " + "000" + "\n"
           else
             download << "%D " + blank_if_not_nil(document['ddu'][0]).to_s[-4..-1] + "\n"
           end
           download << "%C " + blank_if_not_nil(document['source']).to_s + "\n"
           download << "%P " + blank_if_not_nil(document['bn']) + "\n"
      
           download << "%Z " + (Bookmark.find_by_document_id_and_user_id(document.id, current_or_guest_user.id).notes.nil? ? "" : Bookmark.find_by_document_id_and_user_id(document.id, current_or_guest_user.id).notes) + "\n"
           download << "%U " + "http://#{request.host_with_port}/catalog/#{document.id}\n"
           download << "%2 " + blank_if_not_nil(document['pg']).to_s + "\n"
           download << "\n"
           
         end
     
     else
       download << "Author\tTitle\tDate\tBates\tSource\tBookmark\tNotes\n"
       @document_list.each do |document|
         download << blank_if_not_nil(document['au']).to_s + "\t"
         download << blank_if_not_nil(document['ti']) + "\t"
         download << blank_if_not_nil(document['ddu']).to_s + "\t"
         download << blank_if_not_nil(document['bn']) + "\t"
         download << blank_if_not_nil(document['source']) + "\t"
         download << "http://#{request.host_with_port}/catalog/#{document.id}\t"
         download << (Bookmark.find_by_document_id_and_user_id(document.id, current_or_guest_user.id).notes.nil? ? " " : Bookmark.find_by_document_id_and_user_id(document.id, current_or_guest_user.id).notes) + "\t"
         download << "\n"
       end     
     end

    send_data(download, :filename => 'downloads.' + params[:download_format])
     
  end
  
  def citation_example
    respond_to do |format|
      format.html
      format.js { render :layout => false }
    end
  end
  
  # require a user login because we are persisting bookmarks with notes
  protected
  def verify_user
    #flash[:notice] = I18n.t('blacklight.bookmarks.need_login') and raise Blacklight::Exceptions::AccessDenied  unless current_or_guest_user
    raise Blacklight::Exceptions::AccessDenied  unless current_or_guest_user
  end
  
end