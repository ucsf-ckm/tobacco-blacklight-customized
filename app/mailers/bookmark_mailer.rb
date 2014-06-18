# -*- encoding : utf-8 -*-
# Only works for documents with a #to_marc right now.


# gboushey on 4-25-14
# override because smtp mailer requires a from field
# otherwise identical to BookmarkMailer in Blacklight
class BookmarkMailer < ActionMailer::Base

   def email_bookmarks(documents, details, url_gen_params, current_or_guest_user, host)
      subject = ("LTDL Bookmarks - " + Time.now.to_s)

      @documents = documents
      @message = details[:message]
      @url_gen_params = url_gen_params
      @host = host
      
      @current_or_guest_user = current_or_guest_user
      
      mail(:from => "youremail@yourserver.edu", :to => details[:to], :subject => subject)
   end
   
end

