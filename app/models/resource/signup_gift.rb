class Resource::SignupGift < ActiveRecord::Base

  belongs_to  :identity,   :class_name => "Identity", :foreign_key => :identity_id, :inverse_of => :signup_gifts
  belongs_to  :client,     :class_name => "Client",   :foreign_key => :client_id
  belongs_to  :invitation, :class_name => "Key",      :foreign_key => :key_id

  serialize :data
  
end
