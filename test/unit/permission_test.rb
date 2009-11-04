require 'test_helper'

class PermissionTest < ActiveSupport::TestCase

  def setup
    create_test_gitosis_config
    stub_git
  end

  def teardown
    delete_test_gitosis_config
  end

  context "associations" do
    should_belong_to :public_key
    should_belong_to :repository
  end

  context "config file" do

    should "include new member after save" do
      repository = Factory.create(:repository, :name => 'project_with_one_key')
      public_key = Factory.create(:public_key)
      repository.public_keys << public_key

      match = nil
      File.open(gitosis_test_config).each do |line|
        match = true if line.match(/^members = publickey-#{public_key.id}/)
      end
      assert match
    end

    should "get added a key to the list of members" do
      repository = Factory.create(:repository, :name => 'project_with_two_keys')
      first_public_key = Factory.create(:public_key, :source => 'ssh-rsa 123123123123', :email => 'test1@namics.com')
      second_public_key = Factory.create(:public_key, :source => 'ssh-rsa 456456456456', :email => 'test2@namics.com')

      repository.public_keys << first_public_key
      repository.public_keys << second_public_key

      match = nil
      File.open(gitosis_test_config).each do |line|
        match = true if line.match(/^members = publickey-#{first_public_key.id} publickey-#{second_public_key.id}$/)
      end
      assert match
    end

    should "get removed a key to the list of members" do
      repository = Factory.create(:repository, :name => 'project_with_two_keys')
      first_public_key = Factory.create(:public_key, :source => 'ssh-rsa 123123123123', :email => 'test1@namics.com')
      second_public_key = Factory.create(:public_key, :source => 'ssh-rsa 456456456456', :email => 'test2@namics.com')

      repository.public_keys << first_public_key
      repository.public_keys << second_public_key
      Permission.find_by_public_key_id(first_public_key).destroy

      match = nil
      File.open(gitosis_test_config).each do |line|
        match = true if line.match(/^members = publickey-#{second_public_key.id}$/)
      end
      assert match
    end
  end

  context "gitosis-admin" do

    context "on create" do

      should "push a new config to git" do
        GitosisAdmin.any_instance.expects(:push_config).twice() # repository and permission
        Factory.create(:permission)
      end

      should "initialize repository if repository has no commit yet" do
        GitosisAdmin.any_instance.expects(:push_config).twice() # repository and permission
        mg = mock('git')
        Git.expects(:init).returns(mg)
        mg.expects(:log).returns([])
        mg.expects(:add_remote)
        mg.expects(:add)
        mg.expects(:commit_all)
        mg.expects(:push)
        Factory.create(:permission)
      end

      should "initialize repository if repository already has commits" do
        GitosisAdmin.any_instance.expects(:push_config).twice() # repository and permission
        mg = mock('git')
        Git.expects(:init).returns(mg)
        mg.expects(:log).returns(mock('Git::Log'))
        Factory.create(:permission)
      end

    end

    context "on destroy" do

      should "push a new config to git" do
        GitosisAdmin.any_instance.expects(:push_config).twice() # repository and permission
        p = Factory.create(:permission)
        GitosisAdmin.any_instance.expects(:push_config) # destroy
        p.destroy
      end

    end
  end

end
