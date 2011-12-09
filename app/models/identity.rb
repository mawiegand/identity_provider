# == Schema Information
#
# Table name: identities
#
#  id         :integer         not null, primary key
#  name       :string(255)
#  email      :string(255)
#  password   :string(255)
#  salt       :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class Identity < ActiveRecord::Base
  attr_accessor :password
  attr_accessible :name, :email, :password, :password_confirmation
  
  email_regex = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  
  validates :email, :presence   => true,
                    :format     => { :with => email_regex },
                    :uniqueness => { :case_sensitive => false }
                    
  validates :name,  :length     => { :maximum => 20 },
                    :uniqueness => { :case_sensitive => false }
                    
  validates :password, :presence     => true,
                       :confirmation => true,
                       :length       => { :within => 6..40 }
                       
  before_save :set_encrypted_password
  
  def has_password?(potentialPassword)
    encrypted_password == encrypt_password(potentialPassword)
  end
  
  def self.authenticate(email, submittedPassword)
    identity = find_by_email(email)
    return nil if identity.nil?
    return identity if identity.has_password?(submittedPassword)
  end
  
  def self.authenticate_with_salt(id, cookie_salt)
    identity = find_by_id(id)
    return nil if identity.nil?
    return identity if identity.salt == cookie_salt
  end
  
  private
  
    def set_encrypted_password
      self.salt = make_salt if new_record?
      self.encrypted_password = encrypt_password(self.password)
    end
    
    def encrypt_password(string)
      encrypt("#{self.salt}--#{string}")
    end
    
    def encrypt(string)
      Digest::SHA2.hexdigest(string)
    end  
    
    def make_salt
      chars = ('a'..'z').to_a + ('A'..'Z').to_a
      (0..64).collect { chars[Kernel.rand(chars.length)] }.join
    end
    
end

