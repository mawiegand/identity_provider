class IdentityMailer < ActionMailer::Base
  default from: "no-reply@5dlab.com"
  
  def validation_email(identity)
    @identity = identity
    @validation_url = root_url(:host => 'wack-a-doo.de')  + "/identities/#{identity.id}/validation?code=#{identity.validation_code}"
    
    mail :to => identity.email, :subject => "Welcome to Wack-a-doo."
  end
end
