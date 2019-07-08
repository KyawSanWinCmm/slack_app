require 'test_helper'

class MemberInvitationControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get member_invitation_new_url
    assert_response :success
  end

  test "should get invite" do
    get member_invitation_invite_url
    assert_response :success
  end

end
