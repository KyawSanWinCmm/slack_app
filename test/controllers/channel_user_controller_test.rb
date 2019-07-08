require 'test_helper'

class ChannelUserControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get channel_user_show_url
    assert_response :success
  end

  test "should get create" do
    get channel_user_create_url
    assert_response :success
  end

  test "should get destroy" do
    get channel_user_destroy_url
    assert_response :success
  end

end
