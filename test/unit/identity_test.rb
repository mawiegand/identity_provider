require 'test_helper'

class IndentityTest < ActiveSupport::TestCase

 test "invalid identities are invalid" do
   identity = Identity.new
   assert !identity.valid?
   assert !Identity.new(:email =>"minimal@min.de", 
                        :password=>"minimal", 
                        :password_confirmation=>"minimal2").valid?
 end
 
 test "minimal valid identity is valid" do
   identity = Identity.new(:email =>"minimal@min.de", 
                           :password=>"minimal", 
                           :password_confirmation=>"minimal")
                           
   assert identity.valid?
 end
 
  test "cannot save invalid identity" do
   identity = Identity.new
   assert !identity.save
 end
 
  test "can save valid identity" do
   identity = Identity.new(:nickname =>"minimal", 
                           :email    =>"minimal@haus.de", 
                           :password =>"minimal", 
                           :password_confirmation=>"minimal")
                           
   assert identity.save
 end
 
 test "has correct password" do
   assert identities(:user).has_password?('sonnen')
 end
 
 test "does not have wrong passwords" do
   identity = identities(:user)
   assert !identity.has_password?('Sonnen')
   assert !identity.has_password?('sonne')
   assert !identity.has_password?('sonnen ')
   assert !identity.has_password?('')
   assert !identity.has_password?(nil)
 end
 
 test "nil_nicknames are accepted" do
   identity = Identity.new(:email    => "email1@email.com", 
                           :password => "minimal",
                           :password_confirmation => "minimal")
   assert identity.valid?
   assert identity.save

   identity = Identity.new(:nickname => "",
                              :email    => "email2@email.com", 
                              :password => "minimal",
                              :password_confirmation => "minimal")
   assert identity.valid?
   assert identity.save

   identity = Identity.new(:nickname => "",
                              :email    => "email3@email.com", 
                              :password => "minimal",
                              :password_confirmation => "minimal")
   assert identity.valid?
   assert identity.save
 end
 
 test "nicknames must be unique if specified" do
    identity = Identity.new(:nickname => "nick",
                            :email    => "email2@email.com", 
                            :password => "minimal",
                            :password_confirmation => "minimal")
   assert identity.valid?
   assert identity.save

   identity = Identity.new(:nickname => "nick",
                           :email    => "email3@email.com", 
                           :password => "minimal",
                           :password_confirmation => "minimal")
   assert !identity.valid?
   assert !identity.save  
 end

end
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

