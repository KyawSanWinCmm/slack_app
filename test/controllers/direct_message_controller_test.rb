require 'test_helper'

class DirectMessageControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get direct_message_show_url
    assert_response :success
  end

end
