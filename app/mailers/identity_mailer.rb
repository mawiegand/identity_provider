class IdentityMailer < ActionMailer::Base
  default from: "no-reply@5dlab.com"
  
  def validation_email(identity)
    @identity = identity
    @validation_url = root_url(:host => 'wack-a-doo.de')  + "/identities/#{identity.id}/validation?code=#{identity.validation_code}"
    
    mail :to => identity.email, :subject => "Welcome to Wack-a-Doo."
  end
  
  def waiting_list_email(identity, invitation=nil)
    @identity   = identity
    @invitation = invitation
    @validation_url = root_url(:host => 'wack-a-doo.de')  + "/identities/#{identity.id}/validation?code=#{identity.validation_code}"
    
    mail :to => identity.email, :subject => "You're on the waiting list to Wack-a-Doo."    
  end
  
  def password_token_email(identity)
    @identity           = identity
    @password_token_url = IDENTITY_PROVIDER_CONFIG['portal_base_url'] + "/new_password/#{identity.id}/#{identity.password_token}"
    
    mail :to => identity.email, :subject => "Your Password Link"    
  end
  
  def password_email(identity, password)
    @identity = identity
    @password = password
    
    mail :to => identity.email, :subject => "Your new Password"    
  end
  
end
