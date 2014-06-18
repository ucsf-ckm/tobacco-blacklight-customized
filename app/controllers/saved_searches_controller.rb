require "#{Blacklight.root}/app/controllers/saved_searches_controller.rb"

# -*- encoding : utf-8 -*-
class SavedSearchesController < ApplicationController
  include Blacklight::Configurable

  def index
    @searches = Search.find_all_by_user_id(current_user.id).sort_by {|s| s.created_at }
  end

  # Only dereferences the user rather than removing the item in case it
  # is in the session[:history]
  def forget
    if search = current_user.searches.find(params[:id])
      search.user_id = nil
      search.save

      #flash[:notice] =I18n.t('blacklight.saved_searches.remove.success')
    else
      flash[:error] = I18n.t('blacklight.saved_searches.remove.failure')
    end
    redirect_to :back
  end

  def save    
    
    search = searches_from_history.find(params[:id])
    
    if !params[:notes].blank?
      search.notes = params[:notes]
    end
    search.save
    current_user.searches << search
    
    
    if current_user.save
      #flash[:notice] = I18n.t('blacklight.saved_searches.add.success')
    else
      flash[:error] = I18n.t('blacklight.saved_searches.add.failure')
    end
    
    redirect_to :back
  end

end
