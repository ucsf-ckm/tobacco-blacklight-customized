RSolr::Client.module_eval do
  
  def execute request_context

    #puts "rsolr request context***"
    #puts request_context[:uri].to_s

    raw_response = connection.execute self, request_context
    
    #puts "raw response***"
    #puts raw_response

    while retry_503?(request_context, raw_response)
      request_context[:retry_503] -= 1
      sleep retry_after(raw_response)
      raw_response = connection.execute self, request_context
    end

    adapt_response(request_context, raw_response) unless raw_response.nil?
  end

end
