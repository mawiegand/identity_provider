class Client < ActiveRecord::Base
  
  has_many  :grants,                :class_name => "GrantedScope",                :foreign_key => :client_id,    :inverse_of => :client
  has_many  :keys,                  :class_name => "Key",                         :foreign_key => :client_id,    :inverse_of => :client
  has_many  :waiting_list_entries,  :class_name => "Resource::WaitingList",       :foreign_key => :client_id,    :inverse_of => :client
  has_many  :names,                 :class_name => "ClientName",                  :foreign_key => :client_id,    :inverse_of => :client

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
  
  def grant_scopes_to_identity(identity, invitation, automatic, referer=nil, request_url=nil)
    identity.grants.create({
      client_id: self.id,
      scopes:    self.scopes,
      key_id:    invitation.nil? ? nil : invitation.id,
    })         
    register_signup(identity, invitation, automatic, referer, request_url)    
    remove_from_waiting_list(identity)
  end

  def remove_from_waiting_list(identity)
    waiting_list_entry = self.waiting_list_entries.where(identity_id: identity.id).first
    waiting_list_entry.destroy   unless waiting_list_entry.nil? 
  end
  
  def signup_existing_identity(identity, invitation_string, referer=nil, request_url=nil)
    if self.signup_mode == Client::SIGNUP_MODE_NORMAL  ||     # normal mode -> always grant all scopes.
       self.signup_mode == Client::SIGNUP_MODE_INVITATION     # invitation mode -> only grand all scopes if invitation is present and valid
       
      invitation = self.keys.where(key: invitation_string).first     unless invitation_string.blank?
      if !invitation.nil? && invitation.num_used >= invitation.number
        invitation = nil   # invitation link is used up
      elsif !invitation.nil?
        invitation.increment(:num_used)
        invitation.grant_gift(identity)
        invitation.save 
      end
      
      if invitation.nil? && self.signup_mode == Client::SIGNUP_MODE_INVITATION 
        add_to_waiting_list(identity, invitation_string)   
        return 
      else
        grant_scopes_to_identity(identity, invitation, true, referer, request_url)
        IdentityMailer.automatically_granted_access_email(identity, self).deliver  # send email validation email
      end
    else
      add_to_waiting_list(identity, invitation_string)   
    end
  end
  
  def add_to_waiting_list(identity, invitation_string)
    if !waiting_list_entries.where(identity_id: identity.id).first.nil? 
      return false   # already on waiting list
    end
    
    invitation = client.keys.where(key: invitation_string).first     unless invitation_string.blank?
    
    Resource::WaitingList.create({
      client_id:   self.id,
      identity_id: identity.id,
      key_id:      invitation.nil? ? nil : invitation.id,
#      ip:          request.remote_ip,
    })
  end
  
  def register_signup(identity, invitation, automatic=false, referer=nil, request_url=nil)
    Resource::Signup.create({
      client_id:   self.id,
      identity_id: identity.id,
      automatic:   automatic,
      referer:     referer.blank? ? "unknown" : referer[0..250],
      request_url: request_url.blank? ? "unknown" : request_url,
#     ip:          request.remote_ip, 
      invitation:  invitation.nil? ? nil : invitation.key,
      key_id:      invitation.nil? ? nil : invitation.id  
    })
  end
  
  def localized_name
    client_name = self.names.where({lang: I18n.locale}).first
    unless client_name.nil?
      return client_name.name
    end
  end
  
  def localized_description
    client_name = self.names.where({lang: I18n.locale}).first
    unless client_name.nil?
      return client_name.description
    end
  end
end
