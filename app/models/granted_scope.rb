class GrantedScope < ActiveRecord::Base
  
  belongs_to  :identity,  :class_name => "Identity", :foreign_key => :identity_id, :inverse_of => :grants
  belongs_to  :client,    :class_name => "Client",   :foreign_key => :client_id, :inverse_of => :grants


  def scope_authorized?(scope)
    return scopes.split(' ').include?(scope.downcase())
  end
  
end
