require 'test_helper'

class LoggingTest < ActionDispatch::IntegrationTest
  fixtures :all

  test "sign-in and sign-out create correct log entries" do
    # sign-in failure
    
    # sign-in success
    
    # sign-out
  end
  
  test "registration creates correct log entries" do
    # sign-up failure
    # sign-up success (=> also check sign-in entry!)
  end

end
