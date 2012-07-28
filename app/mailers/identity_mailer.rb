class IdentityMailer < ActionMailer::Base
  default from: "no-reply@5dlab.com"
  
  def validation_email(identity)
    @identity = identity
    @validation_url = root_url(:host => 'wack-a-doo.de')  + "/identities/#{identity.id}/validation?code=#{identity.validation_code}"
    
    mail :to => identity.email, :subject => I18n.t('mailing.validation.subject') 
  end
  
  def waiting_list_email(identity, invitation=nil)
    @identity   = identity
    @invitation = invitation
    @validation_url = root_url(:host => 'wack-a-doo.de')  + "/identities/#{identity.id}/validation?code=#{identity.validation_code}"
    
    mail :to => identity.email, :subject => I18n.t('mailing.waiting_list.subject')   
  end
  

  def password_token_email(identity)
    logger.debug locale.inspect
    @identity           = identity
    @password_token_url = IDENTITY_PROVIDER_CONFIG['portal_base_url'] + '/' + I18n.locale.to_s + "/new_password/#{identity.id}/#{identity.password_token}"
    
    mail :to => identity.email, :subject => I18n.t('mailing.password_token.subject')    
  end
  
  def password_email(identity, password)
    @identity = identity
    @password = password
    
    mail :to => identity.email, :subject => I18n.t('mailing.password.subject')
  end
  
end
