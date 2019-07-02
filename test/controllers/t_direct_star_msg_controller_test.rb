require 'test_helper'

class TDirectStarMsgControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get t_direct_star_msg_new_url
    assert_response :success
  end

end
