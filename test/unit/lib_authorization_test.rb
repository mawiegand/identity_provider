require 'test_helper'

class LibAuthorizationTest < ActiveSupport::TestCase
  fixtures :all

  test "can set read access for different roles" do
    idenity = Identity.new
    assert Identity.readable_attributes(:user).include?  'nickname'
    assert Identity.readable_attributes(:staff).include? 'surname'
  end

  test "no unauthorized readers" do
    idenity = Identity.new
    assert !Identity.readable_attributes(:user).include?('surname')
    assert !Identity.readable_attributes(:default).include?('surname')
    assert !Identity.readable_attributes(:unknown).include?('nickname')
  end

end