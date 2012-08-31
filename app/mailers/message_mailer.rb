class MessageMailer < ActionMailer::Base
  default from: "no-reply@wack-a-doo.de"
  
  def message_email(identity, message)
    mail :to => identity.email, :subject => message.subject, :body => message.body
  end
  
end
