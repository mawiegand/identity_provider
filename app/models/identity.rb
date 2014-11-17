require 'base64'
require 'five_d'

# Managing, authenticating and serving the identities is the main
# purpose of the IdentityProvider. Each identity represents a 
# registered user of the system, where the users register and
# authenticate with their credentials consisting of email or
# nick and matching password.
#
# For security reasons, plain-text passwords are *not* stored in 
# the database. Instead, the passwords are salted (to prevent
# attacks with rainbow tables) and hashed before storing them.
# User-sent passwords are salted and hashed in exactly the 
# same way and then compared to the stored hash; if both match
# we can assume the user has sent the correct password. See the
# SessionsController's helpers for details of this matching
# procedure.
#
# To make things secure and prevent several knwown attacks,
# the implementation has to make sure the following things:
# * salts are long enough and have high enough entropy
# * different salts are used for each user
# * the hashing function must be cryptographic
# * plain-text passwords must not be stored in log files!
#
# What options exist for finding and authenticating a specific
# Identity
# * the identifier: case-sensitive exact match is needed
# * the nickname: case-insensitive match is needed
# * the email: case-insensitive match is needed
# Furthermore, the same rules hold for the uniqueness-condition
# on identifiers, emails and nicknames in the system; no
# two persons can register with the same email or nickname
# differing only in case (e.g. Sascha & sascha identify the
# same identity).
#
# Please note: emails are stored in downcase (and checked 
# using the downcase version), nicknames are not modified.
#
# It's only possible ot authenticate against non-deleted
# Identities (value of attribute "deleted" is not "true").
#
# == Schema Information
#
# Table name: identities
#
#  id                 :integer         not null, primary key
#  name               :string(255)
#  email              :string(255)
#  salt               :string(255)
#  created_at         :datetime
#  updated_at         :datetime
#  encrypted_password :string(255)
#  admin              :boolean(255)
#  staff              :boolean(255)
#
class Identity < ActiveRecord::Base
  
  has_many  :log_entries
  has_many  :grants,                :class_name => "GrantedScope",                 :foreign_key => :identity_id,  :inverse_of => :identity
  has_many  :waiting_list_entries,  :class_name => "Resource::WaitingList",        :foreign_key => :identity_id,  :inverse_of => :identity
  
  has_many  :results,               :class_name => "Resource::Result",             :foreign_key => :identity_id,  :inverse_of => :identity
  has_many  :events,                :class_name => "Resource::History",            :foreign_key => :identity_id,  :inverse_of => :identity
  has_many  :character_properties,  :class_name => "Resource::CharacterProperty",  :foreign_key => :identity_id,  :inverse_of => :identity
  has_many  :signup_gifts,          :class_name => "Resource::SignupGift",         :foreign_key => :identity_id,  :inverse_of => :identity
  has_many  :sent_messages,         :class_name => "Message",                      :foreign_key => :sender_id,    :inverse_of => :sender
  has_many  :received_messages,     :class_name => "Message",                      :foreign_key => :recipient_id, :inverse_of => :recipient
  
  has_many  :device_users,          :class_name => "InstallTracking::DeviceUser",  :foreign_key => :identity_id,  :inverse_of => :identity
  has_many  :devices,               :through    => :device_users,                                                 :inverse_of => :identities
  
  has_many  :install_users,         :class_name => "InstallTracking::InstallUser", :foreign_key => :identity_id,  :inverse_of => :identity
  has_many  :installs,              :through    => :install_users,                                                :inverse_of => :identities

  has_many  :push_tokens,           :class_name => "InstallTracking::PushNotificationToken", :primary_key => :identifier, :foreign_key => :identifier, :inverse_of => :identity

  has_many  :sign_ins,              :class_name => "LogEntry",                     :foreign_key => :identity_id,  :conditions => {:event_type => 'signin_success'}, :order => 'created_at DESC'
  has_many  :auth_successes,        :class_name => "LogEntry",                     :foreign_key => :identity_id,  :conditions => "event_type ='signin_success' OR event_type = 'auth_token_success'", :order => 'created_at DESC'

  has_many  :payments,              :class_name => "Stats::MoneyTransaction",      :foreign_key => :identity_id,  :inverse_of => :identity

  default_scope :order => 'identities.email ASC'
  scope         :since_date,  lambda { |date| where(['created_at > ?', date]) }
    
  attr_accessor :password
  
  attr_accessible :nickname, :firstname, :surname, :password, :password_confirmation, :as => :owner
  attr_accessible *accessible_attributes(:owner), :email, :gc_player_id, :fb_player_id, :as => :creator # fields accesible during creation
  attr_accessible :nickname, :firstname, :surname, :activated, :deleted, :staff, :insider_since, :platinum_lifetime_since, :divine_supporter_since, :image_set_id, :banned, :ban_reason, :ban_ended_at, :generic_email, :generic_nickname, :generic_password, :gc_player_id, :gc_rejected_at, :gc_player_id_connected_at, :fb_player_id, :fb_rejected_at, :fb_player_id_connected_at, :as => :staff
  attr_accessible *accessible_attributes(:staff), :email, :admin, :password, :password_confirmation, :as => :admin
  attr_accessible :nickname, :password, :password_confirmation, :platinum_lifetime_since, :divine_supporter_since, :image_set_id, :gc_player_id, :gc_rejected_at, :gc_player_id_connected_at, :fb_player_id, :fb_rejected_at, :fb_player_id_connected_at, :as => :game

  attr_readable :identifier, :nickname, :id, :insider_since, :admin, :staff,               :as => :default
  attr_readable *readable_attributes(:default), :created_at,                               :as => :user
  attr_readable *readable_attributes(:default), :insider_since, :platinum_lifetime_since, :divine_supporter_since, :image_set_id, :gender, :created_at, :gc_player_id, :gc_rejected_at, :gc_player_id_connected_at, :fb_player_id, :fb_rejected_at, :fb_player_id_connected_at,  :as => :game
  attr_readable *readable_attributes(:user),    :email, :firstname, :surname, :gender, :activated, :updated_at, :deleted,                         :ban_reason, :banned, :ban_ended_at, :generic_email, :generic_nickname, :generic_password, :gc_player_id, :gc_rejected_at, :gc_player_id_connected_at, :fb_player_id, :fb_rejected_at, :fb_player_id_connected_at,   :as => :owner
  attr_readable *readable_attributes(:user),    :email, :firstname, :surname, :gender, :activated, :updated_at, :deleted, :salt, :password_token, :ban_reason, :banned, :ban_ended_at, :generic_email, :generic_nickname, :generic_password, :gc_player_id, :gc_rejected_at, :gc_player_id_connected_at, :fb_player_id, :fb_rejected_at, :fb_player_id_connected_at, :num_payments, :first_payment, :earnings, :num_chargebacks, :chargeback_costs, :platinum_lifetime_since, :divine_supporter_since, :image_set_id,  :as => :staff
  attr_readable *readable_attributes(:staff),   :as => :admin
  
  @email_regex      = /(?:[a-z0-9!#$\%&'*+\/=?^_`{|}~-]+(?:\.[a-z0-9!#$\%&'*+\/=?^_`{|}~-]+)*|"(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21\x23-\x5b\x5d-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])*")@(?:(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\[(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21-\x5a\x53-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])+)\])/i
  #/\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  @nickname_regex   = /^[^\d\s]+[^\s]*$/i
  @identifier_regex = /[a-z]{16}/i
  
  validates :email, :presence   => true,
                    :format     => { :with => @email_regex },
                    :uniqueness => { :case_sensitive => false }
                    
  validates :nickname,  :length       => { :maximum => 20 },
                        :uniqueness   => { :case_sensitive => false, :allow_blank => true },
                        :format       => { :with => @nickname_regex, :allow_blank => true }
                    
  validates :password,  :presence     => true,
                        :confirmation => true,
                        :length       => { :within  => 6..40 },
                        :on           => :create
                       
  validates :password,  :confirmation => true,
                        :length       => { :within  => 6..40, :allow_blank => true },
                        :on           => :update
                       
  validates :firstname, :length       => { :maximum => 20 } 
  
  validates :surname,   :length       => { :maximum => 30 }
  
  validates :identifier, :uniqueness => { :case_sensitive => true }
  
  
                                              
  before_save :set_encrypted_password, :set_unique_identifier
  
  before_save :update_facebook_on_manual_edit
  before_save :update_gamecenter_on_manual_edit
  
  after_save  :track_account_updates
  
  after_create :send_validation_email
  
  def self.find_by_nickname_case_insensitive(nickname, options = {})
    options = { 
      :find_deleted => false,    # by default: don't return deleted users
    }.merge(options).delete_if { |key, value| value.nil? }  # merge 'over' default values
    
    identity = Identity.find(:first, :conditions => ["lower(nickname) = lower(?)", nickname])
    
    identity = nil if identity && identity.deleted && options[:find_deleted] == false    #don't return delted users if not explicitly being told so
    
    identity
  end
  
  
  def self.find_by_id_identifier_or_nickname(user_identifier, options = {})
    options = { 
      :find_deleted => false,    # by default: don't return deleted users
    }.merge(options).delete_if { |key, value| value.nil? }  # merge 'over' default values
    
    identity = Identity.find_by_id(user_identifier) if Identity.valid_id?(user_identifier)
    identity = Identity.find_by_identifier(user_identifier) if identity.nil? && Identity.valid_identifier?(user_identifier)
    identity = Identity.find(:first, :conditions => ["lower(nickname) = lower(?)", user_identifier]) if identity.nil? && Identity.valid_nickname?(user_identifier)
    # article about a method to generate a case-insensitive dynamic finder to replace the
    # code above: http://devblog.aoteastudios.com/2009/12/add-case-insensitive-finders-by.html
    
    identity = nil if identity && identity.deleted && options[:find_deleted] == false    #don't return delted users if not explicitly being told so
    
    return identity
  end
  
  def self.find_by_email_case_insensitive(email)
    Identity.find(:first, :conditions => ["lower(email) = lower(?) AND (deleted IS NULL OR NOT deleted)", email])
  end

  def self.create_with_fb_player_id_access_token_and_client(fb_player_id, fb_access_token, client, params = {})
    begin
      fb_user = FbGraph::User.me(fb_access_token)
      fb_user = fb_user.fetch(:fields => "age_range,gender,username,email,name,first_name,birthday,locale") # wanna know age-range and birthday
      
      if !fb_user.email.blank?  # make sure the email is unique; try to return (sign in) the already existing user otherwise.
        ident = Identity.find_by_email_case_insensitive(fb_user.email)
        if !ident.nil?
          if ident.fb_player_id.nil?
            ident.connect_to_facebook(fb_player_id)
            return ident        # have already another user with that email address. access that particular user.
          else
            logger.error "ERROR DURING SIGNUP: there is already another facebook user with the same email address #{ fb_user.email }."
            # use a generic email address to signup this new fb-user
          end
        else     # email not found
          params[:email]  = fb_user.email       
        end
      end
      
      params[:nickname]     = fb_user.first_name   unless fb_user.first_name.blank?
      params[:gender]       = fb_user.gender       unless fb_user.gender.blank?
      params[:fb_name]      = fb_user.name         unless fb_user.name.blank?
      params[:fb_age_range] = fb_user.age_range    unless fb_user.age_range.blank?
      params[:fb_birthday]  = fb_user.birthday     unless fb_user.birthday.blank?
      params[:fb_username]  = fb_user.username     unless fb_user.username.blank?
      
    rescue
      logger.error "ERROR DURING SIGNUP: Failed to fetch and process facebook open graph /me. Due to invalid access token? FbPlayerId: #{fb_player_id} Token: #{ fb_access_token }"
    end
    
    Identity.create_with_fb_player_id_and_client(fb_player_id, client, params)
  end  
  
  def self.create_with_fb_player_id_and_client(fb_player_id, client, params = {})
    raise BadRequestError.new("No valid facebook user id") if fb_player_id.nil?
    raise BadRequestError.new("No valid client") if client.nil?
    raise BadRequestError.new("Client's scope not valid")             if not client.scopes.include?('5dentity')
    raise BadRequestError.new(I18n.translate "error.fbplayerid")        if Identity.find_by_fb_player_id(fb_player_id)
    
    i = 0
        
    # STEP ONE: create identity
        
    saved = false
    nickname = params[:nickname]
        
    begin
      base_name = if !nickname.blank? && !(nickname =~ /^[^\d\s]+[^\s]*$/i).nil?
        nickname
      else
        "WackyUser"
      end
          
      disambiguated_name = base_name
          
      # OPTIMIZE: the following is a very simple algorithm and should be replaced
      # at some point in time.
      while !Identity.find(:first, :conditions => [ "lower(nickname) = ?", disambiguated_name.downcase ]).nil?
        if i == 0 
          disambiguated_name = "#{ base_name }#{(Identity.count || 0)}"
        else
          disambiguated_name = "#{ base_name }#{((Identity.count || 0) + i).to_s}"
        end
        i = i+1
      end
      
      password = if !params[:password].blank?
        params[:password]
      else 
        (0...8).map{ ('a'..'z').to_a[rand(26)] }.join
      end
      
      password_confirmation = password
          
      email = if !params[:email].blank?
        params[:email]
      elsif client.signup_without_email?
        "generic_fb_#{(0...8).map{ ('a'..'z').to_a[rand(26)] }.join}_#{Identity.maximum(:id).to_i + 1}@5dlab.com"
      else
        nil
      end

      identity = Identity.new
      identity.nickname = disambiguated_name
      identity.email = email
      identity.gender = params[:gender]
      identity.locale = I18n.locale
      identity.referer = params[:referer].blank? ? "facebook_canvas" : params[:referer][0..250]
      identity.password = password
      identity.password_confirmation = password_confirmation
      identity.generic_nickname = params[:nickname].blank?
      identity.generic_email    = params[:email].blank?
      identity.generic_password = params[:password].blank? 
      identity.sign_up_with_client_id = client.id

      if !fb_player_id.nil? 
        identity.connect_to_facebook(fb_player_id)
      end

      identity.fb_name      = params[:fb_name]         unless params[:fb_name].blank?
      identity.fb_age_range = params[:fb_age_range]    unless params[:fb_age_range].blank?
      identity.fb_brithday  = params[:fb_brithday]     unless params[:fb_brithday].blank?
      identity.fb_username  = params[:fb_username]     unless params[:fb_username].blank?
          
      if !identity.valid?
        logger.error "ERROR DURING SIGNUP: identity is invalid #{ identity.nickname }, #{ identity.identifier }, #{ identity.email }, #{ identity.password}==#{ identity.password_confirmation } with params #{ params.inspect }."
        logger.error "ERROR: validity of nickname #{ Identity.valid_nickname?(identity.nickname) }"
        raise BadRequestError.new(I18n.translate "error.identityInvalid")
      end
                  
      saved = identity.save          
    end while !identity.errors.messages[:nickname].nil?    # did save fail due to duplicate nickname? 
        
    # STEP TWO: now 'sign up' the identity to the client's scopes (that is, grant the corresponding scopes to the identity)
        
    if saved
      LogEntry.create_signup_success(params, identity, params[:remote_ip])
          
      # try to signup the identity for the cient's scopes
      client.signup_existing_identity(identity, params[:invitation], params[:referer], params[:request_url])
    end
    
    identity
  end


  def gc_rejected?
    !gc_rejected_at.nil?
  end
  
  def fb_rejected?
    !fb_rejected_at.nil?
  end

  def insider?
    !insider_since.nil?
  end

  def platinum_lifetime?
    !platinum_lifetime_since.nil? && platinum_lifetime_since < Time.now
  end

  def divine_supporter?
    !divine_supporter_since.nil? && divine_supporter_since < Time.now
  end



  # checks a potentialPassword (plain-text) against the "stored"
  # password of the identity. This is done by salting and hashing
  # the potentialPassword in the same way as the real password
  # has been encrypted and stored in the database. 
  def has_password?(potentialPassword)
    encrypted_password == encrypt_password(potentialPassword)
  end
  
  # returns true, when the user has clicked on the validation link
  # in the email that has been sent to him.
  def activated?
    return !activated.nil?
  end
  
  # authenticates login (email or nickname) and password and 
  # returns an identity iff
  # * the login matches an email or nickname in the database
  # * the submittedPassword matches the password of that identity.
  # It returns nil otherwise.
  def self.authenticate(login, submittedPassword)
    return nil if login.blank? || submittedPassword.blank?    
    identity = Identity.find(:first, :conditions => ["lower(email) = lower(?) AND (deleted IS NULL OR NOT deleted)", login])  if identity.nil?
    identity = find_by_identifier_and_deleted(login, false) if identity.nil?
    identity = Identity.find(:first, :conditions => ["lower(nickname) = lower(?) AND (deleted IS NULL OR NOT deleted)", login]) if identity.nil? && Identity.valid_nickname?(login)
    return nil if identity.nil?
    return identity if identity.has_password?(submittedPassword)
  end
  
  # authenticates the current user with the salt that has been
  # stored in his cookie. This method is needed for session 
  # tracking and permanent login (remember token) in order to not 
  # have to remember password and email for the session. 
  def self.authenticate_with_salt(id, cookie_salt)
    identity = find_by_id_and_deleted(id, false)
    return nil if identity.nil?
    return identity if identity.salt == cookie_salt
  end
  
  def self.valid_user_identifier?(user_identifier)
    self.valid_id?(user_identifier) || self.valid_identifier?(user_identifier) || self.valid_nickname?(user_identifier)
  end
  
  def self.valid_identifier?(identifier)
    !identifier.nil? && identifier.index(@identifier_regex) != nil
  end
  
  def self.valid_id?(id)
    !id.nil? && id.index(/^[1-9]\d*$/) != nil
  end
  
  def self.valid_nickname?(name)
    !name.nil? && name.index(@nickname_regex) != nil    # does not start with digit, no whitespaces
  end
  
  def self.free_gc_player_id?(pid)
    !pid.nil? && find_by_gc_player_id(pid).nil?
  end
  
  def self.average_lifetime
    total = 0.0
    Identity.all.each do |identity|
      total += identity.lifetime
    end
    total / (Identity.count || 1.0)
  end
  
  # returns a string representation of the identities role
  def role_string
    return role.to_s
  end
  
  def role
    return :admin if admin
    return :staff if staff
    return :user
  end
  
  def last_sign_in
    sign_ins.nil? || sign_ins.empty? ? nil : sign_ins.first
  end
  
  def last_succesful_auth
    auth_successes.empty? ? nil : auth_successes.first
  end

  
  def lifetime
    last_succesful_auth.nil? ? 0.0 : (last_succesful_auth.created_at - created_at) 
  end
  
  # this is just a stub and most be replaced by an appropriate
  # implementation that tries to somehow return the correct
  # gender of the user.
  def gender?
    return :unknown
  end
  
  def gravatar_hash
    return Digest::MD5.hexdigest(email.strip.downcase)
  end
  
  def gravatar_url(options = {})
    options = { 
      :size => 100, 
      :default => :identicon,
    }.merge(options).delete_if { |key, value| value.nil? }  # merge 'over' default values
    
    GravatarImageTag::gravatar_url( email.strip.downcase, options )
  end

  # returns the most informal address that could be constructed
  # from the known user data
  def address_informal(role = :default, fallback_to_email = true)
    hash = sanitized_hash(role)
    return hash[:nickname] unless hash[:nickname].blank?
    return hash[:firstname] unless hash[:firstname].blank?
    return hash[:email] if fallback_to_email && !hash[:email].blank?
    return address_role
  end
  
  # Returns the most formal address that could be constructed from the
  # known user data. Does contain a translated (and possibly gendered)
  # address-prefix (Mr. / Mrs.).
  def address_formal(fallback_to_email = true)
    return address_prefix + " #{surname}" unless surname.blank?
    return firstname unless firstname.blank?
    return nickname unless nickname.blank?
    return email if fallback_to_email
    return address_role
  end
  
  # Returns a string addressing the user according to his role
  # (user, admin, staff)
  def address_role 
    return I18n.translate('general.address.admin') if admin?
    return I18n.translate('general.address.staff') if staff?
    return I18n.translate('general.address.user')
  end
  
  # Returns a gendered and translated address prefix (Mr. / Mrs.) 
  # matching the present user. If gender is unkown, returns something
  # in the line of "Mr. or Mrs. Lange".
  def address_prefix
    return I18n.translate('general.address.mr') if gender? == 'male'
    return I18n.translate('general.address.mrs') if gender? == 'female'
    return I18n.translate('general.address.mrmrs') 
  end
  
  # connects the identity to the given game center player id
  def connect_to_game_center(new_gc_player_id)
    self.gc_player_id   = new_gc_player_id
    self.gc_rejected_at = nil
    self.gc_player_id_connected_at = DateTime.now
    return self
  end
  
  # remove game_center connection
  def disconnect_from_game_center
    self.gc_player_id   = nil
    self.gc_rejected_at = DateTime.now
    self.gc_player_id_connected_at = nil
    return self
  end
  
  def reject_game_center
    self.gc_rejected_at = DateTime.now
  end
  
  def rejected_game_center?
    !self.gc_rejected_at.nil?
  end
  
  def connected_to_game_center?
    !self.gc_player_id.nil?
  end
  
  def portable?
    connected_to_game_center? || !self.generic_password?
  end
  
  
  # connects the identity to the given facebook player id
  def connect_to_facebook(new_fb_player_id)
    self.fb_player_id   = new_fb_player_id
    self.fb_rejected_at = nil
    self.fb_player_id_connected_at = DateTime.now
    return self
  end
  
  # remove game_center connection
  def disconnect_from_facebook
    self.fb_player_id   = nil
    self.fb_rejected_at = DateTime.now
    self.fb_player_id_connected_at = nil
    return self
  end
  
  def reject_facebook
    self.fb_rejected_at = DateTime.now
  end
  
  def rejected_faceobook?
    !self.fb_rejected_at.nil?
  end
  
  def connected_to_facebook?
    !self.fb_player_id.nil?
  end
  
  # generates a validation code for this identitie's email address.
  # The implementation relies on the identitie's salt to never change.
  # Since the identity's random-generated salt can not be deduced from 
  # other values of the identity, it can be used as validation-token.
  def validation_code
    str = "#{email}.#{salt}"  
    strb64 = Base64.encode64(str);   # Base 64 encoding just to make sure it can be part of an URL. No encryption neceesary!
    return strb64.gsub(/[\n\r ]/,'') # no line breaks and spaces...
  end

  # checks whether the given activation code matches the identity.
  def has_validation_code?(code)
    return validation_code().eql? code
  end
  
  # create a random-string with len chars
  def make_random_string(len = 64)
    chars = ('a'..'z').to_a + ('A'..'Z').to_a
    (0..(len-1)).collect { chars[Kernel.rand(chars.length)] }.join
  end    

  def send_validation_email
    IdentityMailer.validation_email(self).deliver unless self.generic_email?   # send email validation email
    true
  end
  
  def update_num_payments
    self.num_payments = self.payments.non_sandbox.completed.payment_booking.not_charged_back.count
  end
  
  def update_earnings
    self.earnings = self.payments.non_sandbox.completed.payment_booking.not_charged_back.sum(:earnings)
  end
  
  def update_num_chargebacks
    self.num_chargebacks = self.payments.non_sandbox.completed.charge_back_booking.count
  end
  
  def update_chargeback_costs
    self.chargeback_costs = self.payments.non_sandbox.completed.payment_booking.charged_back.sum(:earnings) - self.payments.non_sandbox.completed.charge_back_booking.sum(:earnings)
  end

  def update_first_payment
    first_payment = self.payments.sorted_by_date.limit(1).first
    if first_payment.nil?
      self.first_payment = nil
    else 
      self.first_payment = first_payment.updatetstamp
    end
  end
  
  def update_all_stats
    if self.payments.count > 0
      update_num_payments
      update_earnings
      update_num_chargebacks
      update_chargeback_costs
      update_first_payment
    end
  end
  
  def self.update_stats_of_all_identities
    Identity.all.each do |identity|
      identity.update_all_stats
      identity.save(:validate => false)
    end
  end
  
  private

    def track_account_updates
      if self.ref_id_changed? || self.sub_id_changed? || self.email_changed? || self.gender_changed? || self.fb_player_id_changed? || self.referer_changed?
        tracker = FiveD::EventTracker.new

        event = {
          user_id:             self.identifier,
          timestamp:           DateTime.now
        }; 
        
        event[:email]         = self.email         unless self.email.blank?
        event[:gender]        = self.gender        unless self.gender.blank?
        event[:facebook_id]   = self.fb_player_id  unless self.fb_player_id.blank?
        event[:http_referrer] = self.referer       unless self.referer.blank?

        if !self.ref_id.blank? 
          event.ad_referer   = self.ref_id
          event.ad_campaign  = self.sub_id
        end
        
        begin
          tracker.track('udpate', 'account', event);
        rescue
          Logger.error "Could not send account update event for user with identifier #{ self.identifier }."
        end
      end
      
      true
    end

    # adds a unique identifier to every newly created user that
    # must not match any existing nickname 
    def set_unique_identifier
      if new_record?
        begin
          self.identifier = make_random_string(16)
        end while !Identity.find_by_identifier(self.identifier).nil? || !Identity.find(:first, :conditions => ["lower(nickname) = lower(?)", self.identifier]).nil?
      end
    end

    # create salt, if not already set, and set the encrypted
    # password by salting and encrypting the plain-text
    # password sent by the user.
    def set_encrypted_password
      self.salt = make_random_string if new_record? # salt will be created once for a new record
      if !password.blank?
        self.encrypted_password = encrypt_password(self.password)
        puts self.encrypted_password
      end
    end
    
    # combine password and salt and then call the encryption
    # function on the string.
    def encrypt_password(string)
      encrypt("#{self.salt}--#{string}")
    end
    
    # encrypt the given string using a cryptographic hash 
    # function
    def encrypt(string)
      Digest::SHA2.hexdigest(string)
    end  
    
    def update_facebook_on_manual_edit
      if fb_player_id_changed?
        if fb_player_id.blank?     && !fb_player_id_connected_at.nil?
          self.fb_player_id_connected_at = nil
        elsif !fb_player_id.blank? &&  fb_player_id_connected_at.nil?
          self.fb_player_id_connected_at = DateTime.now
        end
      end
    end
    
    def update_gamecenter_on_manual_edit
      if gc_player_id_changed?
        if gc_player_id.blank?     && !gc_player_id_connected_at.nil?
          self.gc_player_id_connected_at = nil
        elsif !gc_player_id.blank? &&  gc_player_id_connected_at.nil?
          self.gc_player_id_connected_at = DateTime.now
        end
      end
    end
    
end

