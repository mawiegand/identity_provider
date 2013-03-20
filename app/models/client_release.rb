class ClientRelease < ActiveRecord::Base
  
  belongs_to  :client, :class_name => "Client", :foreign_key => :client_id, :inverse_of => :releases
  
end
