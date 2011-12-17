require 'test_helper'
require 'sessions_helper'

class IdentitiesControllerTest < ActionController::TestCase

  test "no unauthorized access to index" do
    get :index
    assert_response :redirect    
    assert_redirected_to signin_path
  end

end
