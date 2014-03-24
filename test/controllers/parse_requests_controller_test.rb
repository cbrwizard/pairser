require 'test_helper'

class ParseRequestsControllerTest < ActionController::TestCase
  setup do
    @parse_request = parse_requests(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:parse_requests)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create parse_request" do
    assert_difference('ParseRequest.count') do
      post :create, parse_request: { count: @parse_request.count, domain: @parse_request.domain }
    end

    assert_redirected_to parse_request_path(assigns(:parse_request))
  end

  test "should show parse_request" do
    get :show, id: @parse_request
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @parse_request
    assert_response :success
  end

  test "should update parse_request" do
    patch :update, id: @parse_request, parse_request: { count: @parse_request.count, domain: @parse_request.domain }
    assert_redirected_to parse_request_path(assigns(:parse_request))
  end

  test "should destroy parse_request" do
    assert_difference('ParseRequest.count', -1) do
      delete :destroy, id: @parse_request
    end

    assert_redirected_to parse_requests_path
  end
end
