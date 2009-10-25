require 'test_helper'

class RepositoryTest < ActiveSupport::TestCase

  should_have_many :permissions
  should_have_many :public_keys

  context "validation" do

    setup do
      create_test_gitosis_config
      Factory(:repository)
    end

    teardown do
      delete_test_gitosis_config
    end

    should_allow_values_for :name, 'valid_repository', 'validrepository', 'validrepository_3'
    should_not_allow_values_for :name, 'InValidRepository', 'invalid repository', 'invalid-repository', '123numbersfirst', nil
    should_allow_values_for :email, 'test123@namics.com', 'my.email-is@gmail.com'
    should_not_allow_values_for :email, 'test123.namics.com', 'my.email@gmail .com', '', nil
    should_validate_uniqueness_of :name
  end

  context "config file" do

    setup do
      create_test_gitosis_config
    end

    teardown do
      delete_test_gitosis_config
    end

    context "on create" do
      should "include new group after save" do
        r = Factory.create(:repository, :name => 'test_repo')
        match = nil
        File.open(gitosis_test_config).each do |line|
          match = true if line.match(/^\[test_repo\]$/)
        end
        assert match
      end

      should "include new writable line after save" do
        r = Factory.create(:repository, :name => 'test_repo')
        match = nil
        File.open(gitosis_test_config).each do |line|
          match = true if line.match(/^writable = test_repo$/)
        end
        assert match
      end
    end

    context "on update" do
      should "include new group after updating name" do
        r = Factory.create(:repository, :name => 'test_repo')
        r.update_attributes(:name => 'renamed_test_repo')

        match = nil
        File.open(gitosis_test_config).each do |line|
          match = true if line.match(/^\[renamed_test_repo\]$/)
        end
        assert match
      end

      should "no longer include old group after updating name" do
        r = Factory.create(:repository, :name => 'test_repo')
        r.update_attributes(:name => 'renamed_test_repo')

        match = nil
        File.open(gitosis_test_config).each do |line|
          match = true if line.match(/^\[test_repo\]$/)
        end
        assert_equal match, nil
      end

      should "include new writable line after updating name" do
        r = Factory.create(:repository, :name => 'test_repo')
        r.update_attributes(:name => 'renamed_test_repo')

        match = nil
        File.open(gitosis_test_config).each do |line|
          match = true if line.match(/^writable = renamed_test_repo$/)
        end
        assert match
      end

      should "no longer include old writable line after updating name" do
        r = Factory.create(:repository, :name => 'test_repo')
        r.update_attributes(:name => 'renamed_test_repo')

        match = nil
        File.open(gitosis_test_config).each do |line|
          match = true if line.match(/^writable = test_repo$/)
        end
        assert_equal match, nil
      end
    end

    context "on destroy" do

      should "no longer include old group" do
        r = Factory.create(:repository, :name => 'deleting_test_repo')
        r.destroy
        match = nil
        File.open(gitosis_test_config).each do |line|
          puts line
          match = true if line.match(/^\[deleting_test_repo\]$/)
          match = true if line.match(/^writable = deleting_test_repo$/)
        end
        assert_equal match, nil
      end

    end
  end

end
