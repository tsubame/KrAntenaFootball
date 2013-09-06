require 'test_helper'

class SiteControllerTest < ActionController::TestCase
  
  
  
  test "should get index" do
    get :index
    assert_response :success
  end

  test "should get new" do
    get :new
    assert_response :success
  end
  
  test "create_from_ranking" do
    #get :new
    #assert_response :success
    sites = Site.all
    
    sites.each do |site|
      p site
    end
    
    #min_expected = 50
    #assert min_expected <= sites.size
  end

end
