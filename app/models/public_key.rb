class PublicKey < ActiveRecord::Base

  has_many :repositories, :through => :permissions
  has_many :permissions

  validates_format_of :email, :with => %r{^(?:[_a-z0-9-]+)(\.[_a-z0-9-]+)*@([a-z0-9-]+)(\.[a-zA-Z0-9\-\.]+)*(\.[a-z]{2,4})$}i
  validates_presence_of :description
  validates_presence_of :source
  validates_format_of :source, :with => %r{^(-+\s?BEGIN \w*\s*PUBLIC|ssh-rsa )}i, :allow_blank => true, :allow_nil => true # accept keys beginning with 'ssh-rsa' or something like 'BEGIN PUBLIC KEY' 

  after_save :persist_publickey
  after_destroy :delete_publickey

  def keyfile
    File.join(configatron.gitosis_admin_root, configatron.gitosis_keydir, "#{self.email}-#{self.id}.pub")    
  end

  def label
    [self.description, self.email].join(', ')
  end 

private

  def persist_publickey
    File.open(keyfile, 'w') do |file|
      file.puts self.source
    end
  end

  def delete_publickey
   File.delete(keyfile)
  end

end