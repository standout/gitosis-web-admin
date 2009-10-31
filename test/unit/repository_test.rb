require 'test_helper'

class RepositoryTest < ActiveSupport::TestCase

  def setup
    create_test_gitosis_config
    stub_git
  end

  def teardown
    delete_test_gitosis_config
  end

  context "associations" do
    should_have_many :permissions
    should_have_many :public_keys
  end

  context "validation" do

    setup do
      # create first object
      Factory(:repository)
    end

    should_allow_values_for :name, 'valid_repository', 'validrepository', 'validrepository_3'
    should_not_allow_values_for :name, 'InValidRepository', 'invalid repository', 'invalid-repository', '123numbersfirst', nil
    should_allow_values_for :email, 'test123@namics.com', 'my.email-is@gmail.com'
    should_not_allow_values_for :email, 'test123.namics.com', 'my.email@gmail .com', '', nil
    should_validate_uniqueness_of :name
  end

  context "config file" do 

    context "on create" do

      setup do
        Factory.create(:repository, :name => 'test_repo1')
        Factory.create(:repository, :name => 'test_repo2')
      end

      should "include parent group gitosis once" do
        matches = []
        File.open(gitosis_test_config).each do |line|
          matches << true if line.match(/^\[gitosis\]$/)
        end
        assert_equal matches.length, 1
      end

      should "include new group after save" do
        match = nil
        File.open(gitosis_test_config).each do |line|
          match = true if line.match(/^\[test_repo1\]$/)
        end
        assert match

        match = nil
        File.open(gitosis_test_config).each do |line|
          match = true if line.match(/^\[test_repo2\]$/)
        end
        assert match
      end

      should "include new writable line after save" do
        match = nil
        File.open(gitosis_test_config).each do |line|
          match = true if line.match(/^writable = test_repo1$/)
        end
        assert match

        match = nil
        File.open(gitosis_test_config).each do |line|
          match = true if line.match(/^writable = test_repo2$/)
        end
        assert match
      end
    end

    context "on update" do
      setup do
        Factory.create(:repository, :name => 'test_repo1')
        @r = Factory.create(:repository, :name => 'test_repo2')
        @r.update_attributes(:name => 'renamed_test_repo')
      end

      should "still include untouched repository" do
        match = nil
        File.open(gitosis_test_config).each do |line|
          match = true if line.match(/^\[test_repo1\]$/)
        end
        assert match
      end

      should "include new group after updating name" do
        match = nil
        File.open(gitosis_test_config).each do |line|
          match = true if line.match(/^\[renamed_test_repo\]$/)
        end
        assert match
      end

      should "no longer include old group after updating name" do
        match = nil
        File.open(gitosis_test_config).each do |line|
          match = true if line.match(/^\[test_repo2\]$/)
        end
        assert_equal match, nil
      end

      should "include new writable line after updating name" do
        match = nil
        File.open(gitosis_test_config).each do |line|
          match = true if line.match(/^writable = renamed_test_repo$/)
        end
        assert match
      end

      should "no longer include old writable line after updating name" do
        match = nil
        File.open(gitosis_test_config).each do |line|
          match = true if line.match(/^writable = test_repo$/)
        end
        assert_equal match, nil
      end

      should "readd members for renamed repository" do
        public_key = Factory.create(:public_key)
        @r.public_keys << public_key
        @r.update_attributes(:name => 'new_name_of_repo')

        match = nil
        File.open(gitosis_test_config).each do |line|
          match = true if line.match(/^members = #{public_key.keyfilename}$/)
        end
        assert match
      end
      
    end

    context "on destroy" do

      setup do
        Factory.create(:repository, :name => 'existing_test_repo')
        r = Factory.create(:repository, :name => 'deleting_test_repo')
        r.destroy
      end

      should "still include existing group" do
        match = nil
        File.open(gitosis_test_config).each do |line|
          match = true if line.match(/^\[existing_test_repo\]$/)
        end
        assert_equal match, true
      end

      should "no longer include deleted group" do
        match = nil
        File.open(gitosis_test_config).each do |line|
          match = true if line.match(/^\[deleting_test_repo\]$/)
        end

        assert_equal match, nil

        match = nil
        File.open(gitosis_test_config).each do |line|
          match = true if line.match(/^writable = deleting_test_repo/)
        end
        assert_equal match, nil
      end
    end
  end

  context "gitosis-admin" do

    context "on save" do

      should "push a new config to git" do
        GitosisAdmin.any_instance.expects(:push_config)
        Factory.create(:repository, :name => 'test_repo1')
      end

    end

    context "on destroy" do

      should "push a new config to git" do
        GitosisAdmin.any_instance.expects(:push_config)
        r = Factory.create(:repository, :name => 'deleting_test_repo')

        GitosisAdmin.any_instance.expects(:push_config)        
        r.destroy
      end

    end
  end

end
