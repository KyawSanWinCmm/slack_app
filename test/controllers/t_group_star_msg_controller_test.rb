require 'test_helper'

class TGroupStarMsgControllerTest < ActionDispatch::IntegrationTest
  test "should get create" do
    get t_group_star_msg_create_url
    assert_response :success
  end

  test "should get destroy" do
    get t_group_star_msg_destroy_url
    assert_response :success
  end

end
