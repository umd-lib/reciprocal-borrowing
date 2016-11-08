require 'test_helper'

class ShibbolethLoginControllerTest < ActionController::TestCase
  test "should get home" do
    get :home
    assert_response :success
  end

  test "should get initiator" do
    get :initiator
    assert_response :success
  end

  test "should get callback" do
    get :callback
    assert_response :success
  end

end
