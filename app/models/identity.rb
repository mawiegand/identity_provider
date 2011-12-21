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
  attr_accessible :nickname, :firstname, :surname, :email, :password, :password_confirmation
  
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
  
  default_scope :order => 'identities.id ASC'
                       
  before_save :set_encrypted_password
  
  # checks a potentialPassword (plain-text) against the "stored"
  # password of the identity. This is done by salting and hashing
  # the potentialPassword in the same way as the real password
  # has been encrypted and stored in the database. 
  def has_password?(potentialPassword)
    encrypted_password == encrypt_password(potentialPassword)
  end
  
  # authenticates the email and password and returns an identity
  # iff
  # * the email matches an identity in the database
  # * the submittedPassword matches the password of that identity.
  # It returns nil otherwise.
  def self.authenticate(email, submittedPassword)
    identity = find_by_email(email)
    return nil if identity.nil?
    return identity if identity.has_password?(submittedPassword)
  end
  
  # authenticates the current user with the salt that has been
  # stored in his cookie. This method is needed for session 
  # tracking and permanent login (remember token) in order to not 
  # have to remember password and email for the session. 
  def self.authenticate_with_salt(id, cookie_salt)
    identity = find_by_id(id)
    return nil if identity.nil?
    return identity if identity.salt == cookie_salt
  end
  
  # returns a string representation of the identities role
  def role_string
    return "admin" if admin
    return "staff" if staff
    return "user"
  end
  
  # this is just a stub and most be replaced by an appropriate
  # implementation that tries to somehow return the correct
  # gender of the user.
  def gender?
    return :unknown
  end

  # returns the most informal address that could be constructed
  # from the known user data
  def address_informal
    return nickname unless nickname.blank?
    return firstname unless firstname.blank?
    return email
  end
  
  # Returns the most formal address that could be constructed from the
  # known user data. Does contain a translated (and possibly gendered)
  # address-prefix (Mr. / Mrs.).
  def address_formal
    return I18n.translate(address_prefix) + " #{surname}" unless surname.blank?
    return firstname unless firstname.blank?
    return nickname unless nickname.blank?
    return email
  end
  
  # Returns a gendered and translated address prefix (Mr. / Mrs.) 
  # matching the present user. If gender is unkown, returns something
  # in the line of "Mr. or Mrs. Lange".
  def address_prefix
    return I18n.translate('general.address.mr') if gender? == :male
    return I18n.translate('general.address.mrs') if gender? == :unknwon
    return I18n.translate('general.address.mrmrs') 
  end
  
  private
  
    # create salt, if not already set, and set the encrypted
    # password by salting and encrypting the plain-text
    # password sent by the user.
    def set_encrypted_password
      if !password.blank?
        self.salt = make_salt if new_record?
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

