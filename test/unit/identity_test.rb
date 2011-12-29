require 'test_helper'

class IndentityTest < ActiveSupport::TestCase

 test "invalid identities are invalid" do
   identity = Identity.new
   assert !identity.valid?
   assert !Identity.new({:email =>"minimal@min.de", 
                         :password=>"minimal", 
                         :password_confirmation=>"minimal2"}, :as => :default).valid?
 end
 
 test "minimal valid identity is valid" do
   identity = Identity.new({:email =>"minimal@min.de", 
                            :password=>"minimal", 
                            :password_confirmation=>"minimal"}, :as => :creator)
                           
   assert identity.valid?
 end
 
  test "cannot save invalid identity" do
   identity = Identity.new
   assert !identity.save
 end
 
  test "can save valid identity without protection" do
   identity = Identity.new({:nickname =>"minimal", 
                            :email    =>"minimal@haus.de", 
                            :password =>"minimal", 
                            :password_confirmation=>"minimal"}, :without_protection => true)
   assert identity.save
 end
 
 
 test "can save valid identity with protection" do
   identity = Identity.new({:nickname =>"minimal", 
                            :email    =>"minimal@haus.de", 
                            :password =>"minimal", 
                            :password_confirmation=>"minimal"}, :as => :creator)
                           
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
   identity = Identity.new({:email    =>"minimal@haus.de", 
                            :password =>"minimal", 
                            :password_confirmation=>"minimal"}, :as => :creator)
   assert identity.valid?
   assert identity.save

   identity = Identity.new({:nickname =>"", 
                            :email    =>"minimal@haus2.de", 
                            :password =>"minimal", 
                            :password_confirmation=>"minimal"}, :as => :creator)
   assert identity.valid?
   assert identity.save

   identity = Identity.new({:nickname =>"",              # second (third) user wihtout nick
                            :email    =>"minimal@haus3.de", 
                            :password =>"minimal", 
                            :password_confirmation=>"minimal"}, :as => :creator)
   assert identity.valid?
   assert identity.save
 end
 
 test "nicknames must be unique if specified" do
   identity = Identity.new({:nickname =>"nick", 
                            :email    =>"minimal@haus.de", 
                            :password =>"minimal", 
                            :password_confirmation=>"minimal"}, :as => :creator)
   assert identity.valid?
   assert identity.save

   identity = Identity.new({:nickname =>"nick", 
                            :email    =>"minimal@haus2.de", 
                            :password =>"minimal", 
                            :password_confirmation=>"minimal"}, :as => :creator)
   assert !identity.valid?
   assert !identity.save  
 end
 
 test "new users are not activated by default" do
   identity = Identity.new({:nickname =>"minimal", 
                            :email    =>"minimal@haus.de", 
                            :password =>"minimal", 
                            :password_confirmation=>"minimal"}, :as => :creator)
   assert identity.valid?
   assert identity.activated.nil? 
 end
 
 test "generated activation code is validated correctly" do
   identity1 = identities(:user)
   identity2 = identities(:admin)
                           
   code = identity1.validation_code
   
   assert !code.blank?
   assert identity1.has_validation_code?(code)
   assert !identity2.has_validation_code?(code)
   assert !identity1.has_validation_code?("")
   assert !identity1.has_validation_code?(nil)
   
   assert !code.include?('\n')
   assert !code.include?('\r')
   assert !code.include?(' ')
 end
 
 
 
  test "read access properly set" do
    assert Identity.readable_attributes(:default).include?  'nickname'
    assert Identity.readable_attributes(:default).include?  'id'
    assert Identity.readable_attributes(:owner).include?  'email'
    assert Identity.readable_attributes(:admin).include? 'created_at'

    assert !Identity.readable_attributes(:user).include?('email')
    assert !Identity.readable_attributes(:default).include?('email')    
    assert !Identity.readable_attributes(:default).include?('salt')    
    assert !Identity.readable_attributes(:user).include?('salt')    
    assert !Identity.readable_attributes(:owner).include?('salt')    
    assert !Identity.readable_attributes(:user).include?('surname')
    assert !Identity.readable_attributes(:default).include?('surname')
    assert !Identity.readable_attributes(:unknown).include?('nickname')
  end
  
  test "no-one cann read encrypted password" do
    assert !Identity.readable_attributes(:default).include?('encrypted_password')    
    assert !Identity.readable_attributes(:user).include?('encrypted_password')    
    assert !Identity.readable_attributes(:owner).include?('encrypted_password')    
    assert !Identity.readable_attributes(:staff).include?('encrypted_password')    
    assert !Identity.readable_attributes(:admin).include?('encrypted_password')    
    assert !Identity.readable_attributes.include?('encrypted_password')    
    assert !Identity.readable_attributes(:unknown).include?('encrypted_password')    
  end

  test "write access properly set" do
    assert !Identity.accessible_attributes(:user).include?('surname')
    assert !Identity.accessible_attributes(:default).include?('nickname')
    assert !Identity.accessible_attributes(:unknown).include?('nickname')
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

