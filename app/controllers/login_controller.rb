class LoginController < ApplicationController
  include Blacklight::Configurable

  def myaccess
    @user = User.find_by_email(request.headers['eduPersonPrincipalName'])  # shib parameter
    
    if @user.nil?
      @user = User.new(:email => request.headers['eduPersonPrincipalName'], :password => 'password', :password_confirmation => 'password')
      @user.save
    end
    
    sign_in @user
    
    redirect_to '/'
  end
  
end
