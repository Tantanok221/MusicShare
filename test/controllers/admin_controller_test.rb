require "test_helper"

class AdminControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test "should get home" do
    admin_user = users(:admin)

    sign_in admin_user

    get admin_home_url
    assert_response :success
  end
end
