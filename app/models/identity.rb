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
  attr_accessible :name, :email
  
  email_regex = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  
  validates :email, :presence   => true,
                    :format     => { :with => email_regex },
                    :uniqueness => { :case_sensitive => false }
                    
  validates :name,  :length     => { :maximum => 20 },
                    :uniqueness => { :case_sensitive => false }
  
end

