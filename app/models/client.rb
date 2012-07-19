class Client < ActiveRecord::Base
  
  has_many  :grants,  :class_name => "GrantedScope", :foreign_key => :client_id, :inverse_of => :client
  
  SIGNUP_MODES = []
  SIGNUP_MODE_NORMAL = 1
  SIGNUP_MODES[SIGNUP_MODE_NORMAL] = :normal
  SIGNUP_MODE_OFF = 2
  SIGNUP_MODES[SIGNUP_MODE_OFF] = :off
  SIGNUP_MODE_INVITATION = 3  
  SIGNUP_MODES[SIGNUP_MODE_INVITATION] = :invitation
  
  SIGNIN_MODES = []
  SIGNIN_MODE_ON = 1
  SIGNIN_MODES[SIGNIN_MODE_ON] = :on
  SIGNIN_MODE_OFF = 2
  SIGNIN_MODES[SIGNIN_MODE_OFF] = :off
  
  def scope_authorized?(scope)
    return scopes.split(' ').include?(scope.downcase())
  end
  
  def grant_type_allowed?(grant_type)
    return grant_types.split(' ').include?(grant_type.downcase())
  end
  
end
