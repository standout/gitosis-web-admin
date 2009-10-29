require 'test_helper'

class PublicKeysControllerTest < ActionController::TestCase

  def setup
    create_test_gitosis_config
    @public_key ||= Factory(:public_key)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:public_keys)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create public_key" do
    assert_difference('PublicKey.count') do
      post :create, :public_key => Factory.attributes_for(:public_key)
    end

    assert_redirected_to public_key_path(assigns(:public_key))
  end

  test "should create public_key for given repository" do
    create_test_gitosis_config
    @repository = Factory(:repository)
    assert_difference('@repository.public_keys.count') do
      post :create, :public_key => Factory.attributes_for(:public_key), :repository_id => @repository.to_param
    end

    assert_redirected_to repository_path(assigns(:repository))
    delete_test_gitosis_config
  end

  test "should show public_key" do
    get :show, :id => @public_key.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @public_key.to_param
    assert_response :success
  end

  test "should update public_key" do
    put :update, :id => @public_key.to_param, :public_key => Factory.attributes_for(:public_key)
    assert_redirected_to public_key_path(assigns(:public_key))
  end

  test "should destroy public_key" do
    assert_difference('PublicKey.count', -1) do
      delete :destroy, :id => @public_key.to_param
    end

    assert_redirected_to public_keys_path
  end
 
end
