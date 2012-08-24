class Message < ActiveRecord::Base

  belongs_to  :recipient,  :class_name => "Identity",       :foreign_key => :recipient_id, :inverse_of => :received_messages
  belongs_to  :sender,     :class_name => "Identity",       :foreign_key => :sender_id,    :inverse_of => :sent_messages  
    
  def send_via_email
    raise NotFoundError.new('No valid recipient. Could not send message via email.') if self.recipient.nil?
    
    MessageMailer.message_email(self.recipient, self).deliver      # send email validation email
    
    self.delivered_at  = Time.now
    self.delivered_via = "email"
    self.save
  end

end
