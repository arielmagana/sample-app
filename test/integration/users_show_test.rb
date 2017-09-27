require 'test_helper'

class UsersShowTest < ActionDispatch::IntegrationTest
  def setup
    @admin = users(:ariel)
    @no_activated = users(:noactive)
  end

  test "should redirect to root if not activated" do
    log_in_as @admin
    get user_path(@no_activated)
    assert_redirected_to root_url 
  end

  test "should display user when user is activated" do
    log_in_as @admin
    get user_path(@admin)
    assert_template 'users/show'
    assert_select 'h1', @admin.name
  end
end
