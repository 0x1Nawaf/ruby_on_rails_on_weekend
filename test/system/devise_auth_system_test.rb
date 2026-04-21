require "application_system_test_case"

class DeviseAuthSystemTest < ApplicationSystemTestCase
  test "index page for all" do
    visit root_url
    take_screenshot()

  end

  test "user_home not for unauthenticated users" do
    visit home_url
    assert_text "You need to sign in or sign up"
    take_screenshot()

  end

  test "sign in existing user" do
    user = users(:one)
    sign_in user

    visit home_url
    assert_text "Your uploads"
    take_screenshot()

  end

  test "sign in new user" do
    email = "test3@test3.com"
    password = "123123"
    user = User.create(email: email, password: password)
    visit home_url
    fill_in "Email", with: email
    fill_in "Password", with: password
    click_button "Log in"
    assert_current_path home_url
    assert_text "Your uploads"
    take_screenshot()

  end
end