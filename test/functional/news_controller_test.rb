require 'test_helper'

class NewsControllerTest < ActionController::TestCase
  test "should get get_todays_post" do
    get :get_todays_post
    assert_response :success
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should get index" do
    get :index
    assert_response :success
  end

end
