# -*- encoding : utf-8 -*-
# Only works for documents with a #to_marc right now.
class SearchMailer < ActionMailer::Base

   def email_search(searches, comments, details, url_gen_params, host)
      subject = ("LTDL Search History - " + Time.now.to_s)

      @searches = searches
      @comments = comments
      @message = details[:message]
      @url_gen_params = url_gen_params
      @host = host

      mail(:from => "youremail@yourserver.edu", :to => details[:to], :subject => subject)
   end
end