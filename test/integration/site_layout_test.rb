require 'test_helper'

class SiteLayoutTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:ariel)
  end

  test "layout links for non-logged-in user" do
    get root_path
    assert_template 'static_pages/home'
    assert_select "a[href=?]", root_path, count: 2
    assert_select "a[href=?]", help_path
    assert_select "a[href=?]", about_path
    assert_select "a[href=?]", contact_path
    assert_select "a[href=?]", signup_path
    assert_select "a[href=?]", login_path
    assert_select "a[href=?]", users_path, count: 0
    assert_select "a[href=?]", user_path(@user), count: 0 # Current user's Profile link test
    assert_select "a[href=?]", edit_user_path(@user), count: 0 # Current user's setting link test
    assert_select "a[href=?]", logout_path, count: 0
    get contact_path
    assert_select "title", full_title("Contact")
  end

  test "layout links for logged-in user" do
    log_in_as @user
    get root_path
    assert_select "a[href=?]", help_path
    assert_select "a[href=?]", about_path
    assert_select "a[href=?]", contact_path
    assert_select "a[href=?]", signup_path, count: 0
    assert_select "a[href=?]", login_path, count: 0 # Validate no login link found
    assert_select "a[href=?]", users_path
    assert_select "a", "Account"
    assert_select "a[href=?]", user_path(@user) # Current user's Profile link test
    assert_select "a[href=?]", edit_user_path(@user) # Current user's setting link test
    assert_select "a[href=?]", logout_path
  end
end
