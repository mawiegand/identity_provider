require 'test_helper'

class IndentityTest < ActiveSupport::TestCase

 test "empty identity is not valid" do
   identity = Identity.new
   assert !identity.valid?
 end
 
 test "minimal valid identity is valid" do
   identity = Identity.new(:name => "minimal", 
                           :email =>"minimal@haus.de", 
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
   identity = Identity.new(:name => "minimal", 
                           :email =>"minimal@haus.de", 
                           :password=>"minimal", 
                           :password_confirmation=>"minimal") 
 
   assert identity.save   
   assert identity.has_password?('minimal')
 end
 
 test "does not have wrong passwords" do
   identity = Identity.new(:name => "minimal", 
                           :email =>"minimal@haus.de", 
                           :password=>"minimal", 
                           :password_confirmation=>"minimal") 
 
   assert identity.save   
   assert !identity.has_password?('Minimal')
   assert !identity.has_password?('maximal')
   assert !identity.has_password?('minimal ')
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

