class Resource::WaitingList < ActiveRecord::Base

  belongs_to  :identity,   :class_name => "Identity", :foreign_key => :identity_id, :inverse_of => :waiting_list_entries
  belongs_to  :client,     :class_name => "Client",   :foreign_key => :client_id,   :inverse_of => :waiting_list_entries
  belongs_to  :invitation, :class_name => "Key",      :foreign_key => :key_id

  after_create :deliver_email

  
  protected
  
    def deliver_email
      IdentityMailer.waiting_list_email(self.identity, self.client).deliver  # send waiting-list email
    end

  #end protected
end
