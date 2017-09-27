require 'test_helper'

class UsersIndexTest < ActionDispatch::IntegrationTest
  def setup
    @admin = users(:ariel)
    @non_admin = users(:archer)
  end

  test "index including pagination and delete links and only show activated users" do
    log_in_as(@admin)
    get users_path
    assert_template 'users/index'
    assert_select 'nav.pagination', count: 2
    User.paginate(page: 1).each do |user|
      # Validate link only if the user is activeted
      if user.activated?
        assert_select 'a[href=?]', user_path(user), text: user.name
        unless user == @admin
          assert_select 'a[href=?]', user_path(user), text: 'Delete'
        end
      else
        # If not activated, validate that is not in the page
        assert_select 'a[href=?]', user_path(user), text: user.name, count: 0
      end
    end
    assert_difference 'User.count', -1 do
      delete user_path(@non_admin)
    end
  end
end
