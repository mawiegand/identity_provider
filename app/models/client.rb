class Client < ActiveRecord::Base
  
  has_many  :grants,  :class_name => "GrantedScope", :foreign_key => :client_id, :inverse_of => :client
  has_many  :keys,    :class_name => "Key",          :foreign_key => :client_id, :inverse_of => :client

  attr_readable :as => :default 
  attr_readable :signup_mode, :signin_mode,      :as => :owner 
  attr_readable *accessible_attributes(:owner),  :id, :identifier, :created_at, :updated_at, :name, :identity_id, :password, :refresh_token_secret, :description, :homepage, :grant_types, :scopes,  :as => :staff 
  attr_readable *accessible_attributes(:staff),  :as => :admin 
  
  SIGNUP_MODES = []
  SIGNUP_MODE_OFF = 0
  SIGNUP_MODES[SIGNUP_MODE_OFF] = :off
  SIGNUP_MODE_NORMAL = 1
  SIGNUP_MODES[SIGNUP_MODE_NORMAL] = :normal
  SIGNUP_MODE_INVITATION = 2  
  SIGNUP_MODES[SIGNUP_MODE_INVITATION] = :invitation
  
  SIGNIN_MODES = []
  SIGNIN_MODE_OFF = 0
  SIGNIN_MODES[SIGNIN_MODE_OFF] = :off
  SIGNIN_MODE_ON = 1
  SIGNIN_MODES[SIGNIN_MODE_ON] = :on
  
  def self.find_by_id_or_identifier(client_identifier)
    client = Client.find_by_id(client_identifier) if Client.valid_id?(client_identifier)
    client = Client.find_by_identifier(client_identifier) if client.nil?
    
    return client
  end
  
  def scope_authorized?(scope)
    return scopes.split(' ').include?(scope.downcase())
  end
  
  def grant_type_allowed?(grant_type)
    return grant_types.split(' ').include?(grant_type.downcase())
  end
  
  def self.valid_id?(id)
    id.index(/^[1-9]\d*$/) != nil
  end
  
end
