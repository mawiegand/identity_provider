class MessageMailer < ActionMailer::Base
  default from: "chef@wack-a-doo.de"
  
  def message_email(identity, message)

    if identity.generic_email? 
      Rails.logger.debug "Could not send email to #{ identity.identifier } because this identity has a generic email: #{ identity.email }."
      return
    end    
    
    mail :to => identity.email, :subject => message.subject do |format|
      format.text { render :text => message.body }
      format.html { render :text => message.body.gsub(/\n/,'<br />') }
    end
  end
  
end
