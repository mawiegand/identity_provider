require 'test_helper'

class LoggingTest < ActionDispatch::IntegrationTest
  fixtures :all

  test "sign-in and sign-out create correct log entries" do    
    # sign-in failure
    identity = identities(:staff)
    num_log_entries = LogEntry.count
    
    post_via_redirect "/sessions", :session => { 
      :login => identity.email, 
      :password => "falsches"
    }
    assert_response :success
    assert_template "new"           # login did fail
    assert_equal num_log_entries+1, LogEntry.count
    assert_equal 'none',            LogEntry.first.role
    assert_match /fail/i,           LogEntry.first.description
    
    # sign-in success
    identity = identities(:staff)
    num_log_entries = LogEntry.count
    
    post_via_redirect "/sessions", :session => { 
      :login => identity.email, 
      :password => "sonnen"
    }
    assert_response :success
    assert_template "show"          # login did succeed
    assert_equal num_log_entries+1, LogEntry.count
    assert_equal 'staff',           LogEntry.first.role
    assert_match /succeed/i,        LogEntry.first.description
    
    # sign-out
    num_log_entries = LogEntry.count

    delete signout_path
    assert_response :redirect
    assert_equal num_log_entries+1, LogEntry.count
    assert_equal 'staff',           LogEntry.first.role
    assert_match /signed out/i,     LogEntry.first.description
  end
  
  test "registration creates correct log entries" do
    # sign-up failure
    num_log_entries = LogEntry.count
    
    post_via_redirect "/identities", :identity => { 
      :email    => "my@email.de", 
      :nickname => "MyName",
      :password => "a password",
      :password_confirmation => "doesn't match"
    }
    assert_equal num_log_entries+1, LogEntry.count
    assert_equal 'none',            LogEntry.first.role
    assert_match /did fail/i,       LogEntry.first.description
   
    # sign-up success 
    num_log_entries = LogEntry.count
    
    post_via_redirect "/identities", :identity => { 
      :email    => "my@email.de", 
      :nickname => "MyName",
      :password => "a password",
      :password_confirmation => "a password"
    }
    assert_equal num_log_entries+1, LogEntry.count
    assert_equal 'none',            LogEntry.first.role
    assert_match /Registered/i,     LogEntry.first.description
  end

end
