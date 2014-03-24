require 'test_helper'

class GoodsControllerTest < ActionController::TestCase
  setup do
    @good = goods(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:goods)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create good" do
    assert_difference('Good.count') do
      post :create, good: { main_image_id: @good.main_image_id, name: @good.name }
    end

    assert_redirected_to good_path(assigns(:good))
  end

  test "should show good" do
    get :show, id: @good
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @good
    assert_response :success
  end

  test "should update good" do
    patch :update, id: @good, good: { main_image_id: @good.main_image_id, name: @good.name }
    assert_redirected_to good_path(assigns(:good))
  end

  test "should destroy good" do
    assert_difference('Good.count', -1) do
      delete :destroy, id: @good
    end

    assert_redirected_to goods_path
  end
end
