require 'test_helper'

class PasswordResetsTest < ActionDispatch::IntegrationTest
  def setup
    ActionMailer::Base.deliveries.clear
    @user = users(:ariel)
  end

  test "password resets" do
    # Go into the forgot password link
    get new_password_reset_path
    assert_template 'password_resets/new'
    # Input invalid email, flash should contain errors and page should be re rendered
    post password_resets_path, params: { password_reset: { email: "" } }
    assert_not flash.empty?
    assert_template 'password_resets/new'
    # Valid email, reset_digest should be populated, new email should be sent, flash should have success msg and redirection to url
    post password_resets_path, params: { password_reset: { email: @user.email } }
    assert_not_equal @user.reset_digest, @user.reload.reset_digest
    assert_equal 1, ActionMailer::Base.deliveries.size
    assert_not flash.empty?
    assert_redirected_to root_url
    # Password reset form
    user = assigns(:user) # User instance created on password_resets#create
    # Wrong email, should be redirected to root
    get edit_password_reset_path(user.reset_token, email: "")
    assert_redirected_to root_url
    # Inactive user, should be redirected to root
    user.toggle!(:activated)
    get edit_password_reset_path(user.reset_token, email: user.email)
    assert_redirected_to root_url
    user.toggle!(:activated)
    # Right email, wrong token
    get edit_password_reset_path('wrong token', email: user.email)
    assert_redirected_to root_url
    # Right email, right token, should be presented with password reset form
    get edit_password_reset_path(user.reset_token, email: user.email)
    assert_template 'password_resets/edit'
    assert_select "input[name=email][type=hidden][value=?]", user.email
    # Invalid password & confirmation, should render error
    patch password_reset_path(user.reset_token), params: { email: user.email,
                                                           user: { password: "foobaz",
                                                                   password_confirmation: "barquux" } }
    assert_select 'div#error_explanation'
    # Empty password, should render error
    patch password_reset_path(user.reset_token), params: { email: user.email,
                                                           user: { password: "",
                                                                   password_confirmation: "" } }
    assert_select 'div#error_explanation'
    # Valid password & confirmation, should log in the user, show success on flash and should be redirected to user's profile
    patch password_reset_path(user.reset_token), params: { email: user.email,
                                                 user: { password: "foobaz",
                                                         password_confirmation: "foobaz" } }
    assert is_logged_in?
    assert_not flash.empty?
    assert_nil user.reload.reset_digest
    assert_redirected_to user
  end

  test "expired token" do
    get new_password_reset_path
    post password_resets_path, params: { password_reset: { email: @user.email } }
    @user = assigns(:user)
    @user.update_attribute :reset_sent_at, 3.hours.ago
    patch password_reset_path(@user.reset_token), params: { email: @user.email,
                                                 user: { password: "foobaz",
                                                         password_confirmation: "foobaz" } }
    assert_response :redirect
    follow_redirect!
    assert_match /expired/i, response.body
  end
end
