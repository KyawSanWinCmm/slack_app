require 'test_helper'

class MUsersControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get m_users_new_url
    assert_response :success
  end

end
