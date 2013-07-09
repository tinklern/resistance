require 'test_helper'

class PlayerControllerTest < ActionController::TestCase
  test "should get ready" do
    get :ready
    assert_response :success
  end

end
