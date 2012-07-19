class Client < ActiveRecord::Base
  
  has_many  :grants,  :class_name => "GrantedScope", :foreign_key => :client_id, :inverse_of => :client
  
  def scope_authorized?(scope)
    return scopes.split(' ').include?(scope.downcase())
  end
  
  def grant_type_allowed?(grant_type)
    return grant_types.split(' ').include?(grant_type.downcase())
  end
  
end
