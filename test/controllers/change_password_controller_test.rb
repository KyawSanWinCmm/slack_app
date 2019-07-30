require 'test_helper'

class ChangePasswordControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get change_password_new_url
    assert_response :success
  end

end
