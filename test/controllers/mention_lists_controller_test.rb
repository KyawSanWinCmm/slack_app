require 'test_helper'

class MentionListsControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get mention_lists_show_url
    assert_response :success
  end

end
