require "#{Blacklight.root}/app/controllers/search_history_controller.rb"

# -*- encoding : utf-8 -*-
class SearchHistoryController < ApplicationController
  include Blacklight::Configurable

  def index
    @searches = searches_from_history.sort_by {|s| s.created_at }
  end

  def update    
    search = searches_from_history.find(params[:id])
    search.notes = params[:notes]
    
    if !current_or_guest_user.nil? && search.save
      #flash[:notice] = I18n.t('blacklight.saved_searches.add.success')
    else
      flash[:error] = I18n.t('blacklight.saved_searches.add.failure')
    end
    redirect_to :back
  end

  
  # Email Action (this will render the appropriate view on GET requests and process the form and send the email on POST requests)
  def email
     
     @searches = Array.new
     
     if request.get?
       if !params[:id].nil?
         params[:id].each do |value|
            s = Search.find(value.to_i)
            s.last_action = "Emailed"
            s.last_action_date = Time.now
            s.save
           @searches << s
         end
       else
         redirect_to :back and return
       end
     end
     
     if request.post?
       #if !params[:search_id].nil?
         params[:id].each do |param|
            s = Search.find(param[0].to_i)
            s.last_action = "Emailed"
            s.last_action_date = Time.now
            s.save
           @searches << s
         end
       #else
      #   redirect_to :back and return
      # end
     end
              
     if request.post? and params[:email_selected].blank? and validate_email_params
       
        email = SearchMailer.email_search(@searches, @comments, {:to => params[:to], :message => params[:message]}, url_options, request.host_with_port)
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
  
  
  # Download search history records
  def download
     
     @searches = Array.new
    
     if request.get?
       if !params[:id].nil?
         params[:id].each do |value|
           s = Search.find(value.to_i)
           s.last_action = "Downloaded"
           s.last_action_date = Time.now
           s.save
           @searches << Search.find(value.to_i)
         end
       else
         redirect_to :back and return
       end
     end
  
         download = ""  
      
         if params[:download_format] == "txt"
                        
           @searches.each do |s|
             
             download << "Date: " + (l s.created_at, format: :long) + "\n"
             download << "Search: " + s.query_params['q'] + "\n"
             download << "Results: " + s.numfound.to_s +  "\n"
             download << "Notes: " + s.notes + "\n"
             download << "URL: http://#{request.host_with_port}/catalog?" + (s.query_params.except(:action, :controller, :only_path, :saved)).to_query + "\n"
             download << "Saved: " + (!s.user_id.nil?).to_s+ "\n\n"
           end
         
         elsif params[:download_format] == "csv"
         
            download << "Date,Search,Results,Notes,URL,Saved\n"
            @searches.each do |s|
              download << "\"" + (l s.created_at, format: :long) + "\","
              download << s.query_params['q'] + ","
              download << s.numfound.to_s + ","
              download << s.notes + ","
              download << "http://#{request.host_with_port}/catalog?" + (s.query_params.except(:action, :controller, :only_path, :saved)).to_query + ","
              download << (!s.user_id.nil?).to_s + "\n"
            end
         
         else
           download << "Date\tSearch\tResults\tNotes\tURL\tSaved\n"
           @searches.each do |s|
             download << "\"" + (l s.created_at, format: :long) + "\"\t"
             download << s.query_params['q'] + "\t"
             download << s.numfound.to_s + "\t"
             download << s.notes + "\t"
             download << "http://#{request.host_with_port}/catalog?" + (s.query_params.except(:action, :controller, :only_path, :saved)).to_query + "\t"
             download << (!s.user_id.nil?).to_s + "\n"
           end
         
         end
         
         send_data(download, :filename => 'searches.' + params[:download_format])
         return
         
  end
  
  
  
  def validate_email_params
    case
    when params[:to].blank?
      flash[:error] = I18n.t('blacklight.email.errors.to.blank')
    when !params[:to].match(defined?(Devise) ? Devise.email_regexp : /^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}$/)
      flash[:error] = I18n.t('blacklight.email.errors.to.invalid', :to => params[:to])
    end

    flash[:error].blank?
  end
  
  def remove_search
    searches_from_history.each do |s|
      if s.id.to_s == params[:id]
        searches_from_history.delete(s)
      end
    end
    redirect_to :back
  end
  
  #TODO we may want to remove unsaved (those without user_id) items from the database when removed from history
   def clear
     if session[:history].clear
       #flash[:notice] = I18n.t('blacklight.search_history.clear.success')
     else
       flash[:error] = I18n.t('blacklight.search_history.clear.failure') 
     end
     redirect_to :back
   end
  
end
