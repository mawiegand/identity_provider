class MessageMailer < ActionMailer::Base
  default from: "chef@wack-a-doo.de"

  def do_not_deliver!
    Rails.logger.debug "Stopped delivery of email."
    def self.deliver! ; false ; end
  end  
  
  def message_email(identity, message)
    do_not_deliver! if identity.generic_email? 
    
    mail :to => identity.email, :subject => message.subject do |format|
      format.text { render :text => message.body }
      format.html { render :text => message.body.gsub(/\n/,'<br />') }
    end
  end
  
end
