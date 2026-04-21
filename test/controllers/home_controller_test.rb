require "test_helper"

class HomeControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get root_url
    assert_response :success
    assert_match "home", response.body

  end

  test "unauthinticated should get user_home" do
    get home_url
    assert_response :redirect
    assert_redirected_to new_user_session_path
    follow_redirect!
    assert_match "user", response.body
  end

  test "should get user_home" do
    user = users(:one)
    sign_in user
    get home_url
    assert_response :success
    assert_match "user", response.body
  end
end
