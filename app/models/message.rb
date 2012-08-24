class Message < ActiveRecord::Base

  belongs_to  :recipient,  :class_name => "Identity",       :foreign_key => :recipient_id, :inverse_of => :received_messages
  belongs_to  :sender,     :class_name => "Identity",       :foreign_key => :sender_id,    :inverse_of => :sent_messages
  
    
  def send_message_via_email
  end

end
