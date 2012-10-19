class Resource::Signup < ActiveRecord::Base
  
  belongs_to  :identity,  :class_name => "Identity",       :foreign_key => :identity_id
  belongs_to  :client,    :class_name => "Client",         :foreign_key => :client_id

  
end
