require 'test_helper'

class PublicKeyTest < ActiveSupport::TestCase

  context "validateion" do

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
  end


  should "persist key in file on save" do
    pk = Factory.create(:public_key)
    match = nil
    File.open(pk.keyfile).each do |line|
      match = true if line.strip == pk.source.strip
    end
    assert match
  end

  context "remove keyfile on destroy" do
    pk = Factory.create(:public_key)
    keyfile = pk.keyfile
    pk.destroy
    should_raise(Errno::ENOENT) do
      File.open(keyfile)
    end
  end


end
