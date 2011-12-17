require 'test_helper'

class IndentityTest < ActiveSupport::TestCase

 test "empty identity is not valid" do
   identity = Identity.new
   assert !identity.valid?
   assert !Identity.new(:name => "minimal", 
                        :email =>"minimal@min.de", 
                        :password=>"minimal", 
                        :password_confirmation=>"minimal2").valid?
 end
 
 test "minimal valid identity is valid" do
   identity = Identity.new(:name => "minimal", 
                           :email =>"minimal@min.de", 
                           :password=>"minimal", 
                           :password_confirmation=>"minimal")
                           
   assert identity.valid?
 end
 
  test "cannot save invalid identity" do
   identity = Identity.new
   assert !identity.save
 end
 
  test "can save valid identity" do
   identity = Identity.new(:name => "minimal", 
                           :email =>"minimal@haus.de", 
                           :password=>"minimal", 
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

end
# == Schema Information
#
# Table name: indentities
#
#  id         :integer         not null, primary key
#  name       :string(255)
#  email      :string(255)
#  password   :string(255)
#  salt       :string(255)
#  created_at :datetime
#  updated_at :datetime
#

