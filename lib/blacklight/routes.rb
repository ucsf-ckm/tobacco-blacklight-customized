require "#{Blacklight.root}/lib/blacklight/routes.rb"

# -*- encoding : utf-8 -*-
require 'deprecation'
module Blacklight
  class Routes
    extend Deprecation

    protected

    module RouteSets
    
      def bookmarks(_)
        add_routes do |options|
          delete "bookmarks/clear", :to => "bookmarks#clear", :as => "clear_bookmarks"
          get "bookmarks/list", :to => "bookmarks#list"
          post "bookmarks/download", :to => "bookmarks#download", :as => "download_bookmarks"
          get "bookmarks/download", :to => "bookmarks#download", :as => "download_bookmarks"
          resources :bookmarks
        end
      end
    
      def saved_searches(_)
        add_routes do |options|
          delete "saved_searches/clear",       :to => "saved_searches#clear",   :as => "clear_saved_searches"
          get "saved_searches",       :to => "saved_searches#index",   :as => "saved_searches"
          post "saved_searches/save/:id",    :to => "saved_searches#save",    :as => "save_search"
          get "saved_searches/forget/:id",  :to => "saved_searches#forget",  :as => "forget_search"
          post "saved_searches/forget/:id",  :to => "saved_searches#forget"
          get "saved_searches/email",       :to => "saved_searches#email",   :as => "email_saved_searches"
          post "saved_searches/email"
        end
      end
      
      def search_history(_)
        add_routes do |options|
          get "search_history",             :to => "search_history#index",   :as => "search_history"
          post "search_history/update/:id",    :to => "search_history#update",    :as => "update_search_history"
          delete "search_history/clear",       :to => "search_history#clear",   :as => "clear_search_history"  
          post "search_history/remove_search/:id",       :to => "search_history#remove_search",   :as => "remove_search"            
          get "search_history/email",       :to => "search_history#email",   :as => "email_search_history"
          get "search_history/download",       :to => "search_history#download",   :as => "download_search_history"
          post "search_history/email_selected_history",       :to => "search_history#email_selected_history",   :as => "email_selected_history"
          post "search_history/email"
        end
      end
      
    end
    include RouteSets
  end
end
