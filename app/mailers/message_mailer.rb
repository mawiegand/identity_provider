class MessageMailer < ActionMailer::Base
  default from: "chef@wack-a-doo.de"

  def message_email(identity, message)    
    mail :to => identity.email, :subject => message.subject do |format|
      format.text { render :text => message.body }
      format.html { render :text => message.body.gsub(/\n/,'<br />') }
    end
  end
  
end
