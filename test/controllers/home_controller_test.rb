require 'test_helper'

class HomeControllerTest < ActionController::TestCase
  test "should get only[:index]" do
    get :only[:index]
    assert_response :success
  end

end
