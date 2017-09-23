require 'test_helper'

class UsersControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = User.new name: "Example User", email: "user@example.com", password: "foobar", password_confirmation: "foobar"
  end

  test "should get new" do
    get signup_path
    assert_response :success
  end

  test "authenticated? should return false for a user with nil digest" do
    assert_not @user.authenticated?('')
  end

end
