require "#{Blacklight.root}/lib/blacklight/catalog/search_context.rb"

module Blacklight::Catalog::SearchContext
  extend ActiveSupport::Concern
  
  protected

  def find_or_initialize_search_session_from_params params
    params_copy = params.reject { |k,v| blacklisted_search_session_params.include?(k.to_sym) or v.blank? }

    return if params_copy.reject { |k,v| [:action, :controller].include? k.to_sym }.blank?

    saved_search = searches_from_history.select { |x| x.query_params == params_copy }.first

    # we've moved this to the controller
    #saved_search ||= begin
    #  s = Search.create(:query_params => params_copy)
    #  add_to_search_history(s)
    #  s
    #end
  end

end
