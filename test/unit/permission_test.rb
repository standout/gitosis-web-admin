require 'test_helper'

class PermissionTest < ActiveSupport::TestCase

  should_belong_to :public_key
  should_belong_to :repository 

  context "config file" do

    setup do
      create_test_gitosis_config
    end

    teardown do
      delete_test_gitosis_config
    end

    should "include new member after save" do
      repository = Factory.create(:repository, :name => 'project_with_one_key')
      public_key = Factory.create(:public_key)
      repository.public_keys << public_key

      match = nil
      File.open(gitosis_test_config).each do |line|
        match = true if line.match(/^members = test@namics\.com-#{public_key.id}\.pub$/)
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
        match = true if line.match(/^members = test1@namics\.com-#{first_public_key.id}\.pub test2@namics\.com-#{second_public_key.id}\.pub$/)
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
        match = true if line.match(/^members = test2@namics\.com-#{second_public_key.id}\.pub$/)
      end
      assert match
    end
  end

end
