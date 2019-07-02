require 'test_helper'

class MChannelsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get m_channels_new_url
    assert_response :success
  end

  test "should get show" do
    get m_channels_show_url
    assert_response :success
  end

end
