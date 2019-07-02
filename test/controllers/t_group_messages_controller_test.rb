require 'test_helper'

class TGroupMessagesControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get t_group_messages_show_url
    assert_response :success
  end

end
