require 'test_helper'

class RepositoriesControllerTest < ActionController::TestCase

  def setup
    stub_git
    create_test_gitosis_config
    @repository ||= Factory(:repository)  
  end

  def teardown
    delete_test_gitosis_config
  end

  should "get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:repositories)
  end

  should "get new" do
    get :new
    assert_response :success
  end

  should "create repository" do
    assert_difference('Repository.count') do
      post :create, :repository => Factory.attributes_for(:repository)
    end
    assert_redirected_to new_repository_public_key_path(assigns(:repository))
  end

  should "show repository" do
    get :show, :id => @repository.to_param
    assert_response :success
  end

  should "get edit" do
    get :edit, :id => @repository.to_param
    assert_response :success
  end

  should "update repository" do
    put :update, :id => @repository.to_param, :repository => Factory.attributes_for(:repository)
    assert_redirected_to repository_path(assigns(:repository))
  end

  should "destroy repository" do
    assert_difference('Repository.count', -1) do
      delete :destroy, :id => @repository.to_param
    end

    assert_redirected_to repositories_path
  end

  context "key handling" do


    should "remove key from repository" do
      permission = Factory(:permission)
      repository = permission.repository
      public_key = permission.public_key

      assert_difference('repository.public_keys.count', -1) do
        put :remove_public_key, :id => repository.to_param, :public_key_id => public_key.to_param
      end

      assert_redirected_to repository_path(repository)
    end

    should "add key to repository" do
      public_key = Factory(:public_key)

      assert_difference('@repository.public_keys.count', +1) do
        put :add_public_key, :id => @repository.to_param, :public_key_id => public_key.to_param
      end

      assert_redirected_to repository_path(@repository)
    end
  end

end
