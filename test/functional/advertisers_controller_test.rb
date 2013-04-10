require 'test_helper'

class AdvertisersControllerTest < ActionController::TestCase
  test "should get indes" do
    get :indes
    assert_response :success
  end

end
