require 'test_helper'

class PublicKeyTest < ActiveSupport::TestCase

  def setup
    stub_git
    create_test_gitosis_config
  end

  def teardown
    delete_test_gitosis_config
  end

  should_have_many :permissions
  should_have_many :repositories

  context "validation" do
    setup do
      Factory(:public_key)
    end

    should_validate_presence_of :description, :source
    should_allow_values_for :email,     'test123@namics.com',
                                        'my.email-is@gmail.com'
    should_not_allow_values_for :email, 'test123.namics.com',
                                        'my.email@gmail .com',
                                        '',
                                        nil
    should_allow_values_for :source,    '-----BEGIN PUBLIC KEY-----\nMIGdMA0GCSqGSIb3DQEBAQUAA4GLADCBhwKBgQC/mID2ohE8oahTW2/v0uXOKe/',
                                        '----- BEGIN PUBLIC KEY-----\nMIGdMA0GCSqGSIb3DQEBAQUAA4GLADCBhwKBgQC/mID2ohE8oahTW2/v0uXOKe/',
                                        '----- BEGIN SSH2 PUBLIC KEY-----\nMIGdMA0GCSqGSIb3DQEBAQUAA4GLADCBhwKBgQC/mID2ohE8oahTW2/v0uXOKe/',
                                        'ssh-rsa AAAAB3NzaC1xc2EAAAABIwAAAQEArkpuwTFR1KlSvO2gntMP6QjvTbQS1y5ENm1/XCttr6cVuQL'
    should_not_allow_values_for :source,'-----BEGIN PRIVATE KEY-----\nMIGdMA0GCSqGSIb3DQEBAQUAA4GLADCBhwKBgQC/mID2ohE8oahTW2/v0uXOKe/',
                                        'AAAAB3NzaC1xc2EAAAABIwAAAQEArkpuwTFR1KlSvO2gntMP6QjvTbQS1y5ENm1/XCttr6cVuQL'
    should_validate_uniqueness_of :source
  end

  context "config file" do

    should "persist key in file on save" do
      pk = Factory.create(:public_key)
      match = nil
      File.open(pk.keyfile).each do |line|
        match = true if line.strip == pk.source.strip
      end
      assert match
    end

    # should remove key file on destroy
    should_raise(Errno::ENOENT) do
      pk = Factory.create(:public_key)
      keyfile = pk.keyfile
      pk.destroy
      File.open(keyfile)
    end
  end
  
  context "gitosis-admin" do

    context "on create" do
      should "push key" do
        GitosisAdmin.any_instance.expects(:push_key)
        Factory.create(:public_key)
      end
    end
    
    context "on destroy" do
      should "remove key" do
        pk = Factory.create(:public_key)

        GitosisAdmin.any_instance.expects(:remove_key)
        pk.destroy
      end
    end
  end


end
