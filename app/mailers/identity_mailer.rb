class IdentityMailer < ActionMailer::Base
  default from: "sascha77@googlemail.com"
  
  def validation_email(identity)
    @identity = identity
    @validation_url = root_url(:host => 'localhost:3000')  + "/identities/#{identity.id}/validation?code=#{identity.validation_code}"
    mail :to => identity.email, :subject => "Welcome to Wackadoo."
  end
end
