class ApplicationController < ActionController::Base
  # Adds a few additional behaviors into the application controller 
   include Blacklight::Controller
  # Please be sure to impelement current_user and user_session. Blacklight depends on 
  # these methods in order to perform user specific actions. 

  layout 'blacklight'

  protect_from_forgery
  
  after_filter :store_location
  
  helper_method :blank_if_not_nil
  helper_method :unknown_if_not_nil
  helper_method :format_citation

  def store_location
    # store last url - this is needed for post-login redirect to whatever the user last visited.
    if (request.fullpath != "/users/sign_in" &&
        request.fullpath != "/users/sign_up" &&
        request.fullpath != "/users/password" &&
        request.fullpath != "/users/sign_out" &&
        !request.xhr?) # don't store ajax calls
      session[:previous_url] = request.fullpath 
    end
  end

  def after_sign_in_path_for(resource)
        
    if request.inspect.include?("%2Fsaved_searches%2Fsave%2F")
      session[:previous_url] = "/saved_searches"
    elsif request.inspect.include?("search_history/download")
      session[:previous_url] = "/search_history"
    elsif request.inspect.include?("bookmarks/download")
      session[:previous_url] = "/bookmarks"
    else
      session[:previous_url] || root_path
    end
  end
  
  def blank_if_not_nil(attribute)
    if (!attribute.nil? && attribute.kind_of?(Array))
      if attribute.length == 1
        attribute = attribute.first
      else
        attribute = attribute.join('; ')
      end
    end
    return attribute.nil? ? "" : attribute.gsub('[','').gsub(']','')
  end
  
  def unknown_if_not_nil(attribute)
    
    if attribute.nil? 
      attribute = "Unknown"
    end
    
    if attribute.kind_of?(Array)
      if attribute.length == 1
        attribute = attribute.first
      else
        attribute = attribute.join('; ')
      end
    end
    
    return attribute.nil? ? "" : attribute.gsub('[','').gsub(']','')
  end
  
  def format_citation(attribute)
    return attribute.nil? ? "" : blank_if_not_nil(attribute) + "."
  end
end
