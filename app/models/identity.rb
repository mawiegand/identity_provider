require 'base64'
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
  attr_accessor :password
  
  attr_accessible :nickname, :firstname, :surname, :password, :password_confirmation, :as => :owner
  attr_accessible *accessible_attributes(:owner), :email, :as => :creator # fields accesible during creation
  attr_accessible :nickname, :firstname, :surname, :activated, :deleted, :staff, :as => :staff
  attr_accessible *accessible_attributes(:staff), :admin, :password, :password_confirmation, :as => :admin
    
  attr_readable :nickname, :id, :admin, :staff,               :as => :default 
  attr_readable *readable_attributes(:default), :created_at,  :as => :user
  attr_readable *readable_attributes(:user), :email, :firstname, :surname, :activated, :updated_at, :deleted,         :as => :owner
  attr_readable *readable_attributes(:user), :email, :firstname, :surname, :activated, :updated_at, :deleted, :salt,  :as => :staff
  attr_readable *readable_attributes(:staff),   :as => :admin
  
  email_regex = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  
  validates :email, :presence   => true,
                    :format     => { :with => email_regex },
                    :uniqueness => { :case_sensitive => false }
                    
  validates :nickname,  :length       => { :maximum => 20 },
                        :uniqueness   => { :case_sensitive => false, :allow_blank => true }
                    
  validates :password,  :presence     => true,
                        :confirmation => true,
                        :length       => { :within  => 6..40 },
                        :on           => :create
                       
  validates :password,  :confirmation => true,
                        :length       => { :within  => 6..40, :allow_blank => true },
                        :on           => :update
                       
  validates :firstname, :length       => { :maximum => 20 } 
  
  validates :surname,   :length       => { :maximum => 30 }
  
  has_many  :log_entries;
  
  default_scope :order => 'identities.nickname ASC'
                       
  before_save :set_encrypted_password
  
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
    identity = find_by_email_and_deleted(login, false)
    identity = find_by_nickname_and_deleted(login, false) if identity.nil? # user may have specified valid nickname?
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
  
  def self.valid_identifer?(identifer)
    self.valid_id?(identifer) || self.valid_nickname?(identifer)
  end
  
  def self.valid_id?(id)
    id.index(/^[1-9]\d*$/) != nil
  end
  
  def self.valid_nickname?(name)
    false
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
  
  # this is just a stub and most be replaced by an appropriate
  # implementation that tries to somehow return the correct
  # gender of the user.
  def gender?
    return :unknown
  end

  # returns the most informal address that could be constructed
  # from the known user data
  def address_informal(fallback_to_email = true)
    return nickname unless nickname.blank?
    return firstname unless firstname.blank?
    return email if fallback_to_email
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
    return I18n.translate('general.address.mr') if gender? == :male
    return I18n.translate('general.address.mrs') if gender? == :unknwon
    return I18n.translate('general.address.mrmrs') 
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
  
  
  private
  
    # create salt, if not already set, and set the encrypted
    # password by salting and encrypting the plain-text
    # password sent by the user.
    def set_encrypted_password
      self.salt = make_salt if new_record? # salt will be created once for a new record
      if !password.blank?
        self.encrypted_password = encrypt_password(self.password)
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
    
    # create a random-string with 64-chars to be used as salt
    def make_salt
      chars = ('a'..'z').to_a + ('A'..'Z').to_a
      (0..64).collect { chars[Kernel.rand(chars.length)] }.join
    end
    
    
    
end

