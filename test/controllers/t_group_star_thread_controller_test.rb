require 'test_helper'

class TGroupStarThreadControllerTest < ActionDispatch::IntegrationTest
  test "should get create" do
    get t_group_star_thread_create_url
    assert_response :success
  end

  test "should get destroy" do
    get t_group_star_thread_destroy_url
    assert_response :success
  end

end
