require 'gitosis_config'

class Repository < ActiveRecord::Base

  has_many :public_keys, :through => :permissions
  has_many :permissions, :dependent => :destroy

  validates_uniqueness_of :name
  validates_format_of :name, :with => %r{^[a-z]+[0-9a-z_-]+$} # repository name may only contain lowercase letters, numbers, dashes and underscores
  validates_format_of :email, :with => %r{^(?:[_a-z0-9-]+)(\.[_a-z0-9-]+)*@([a-z0-9-]+)(\.[a-zA-Z0-9\-\.]+)*(\.[a-z]{2,4})$}i 

  after_create :save_config, :add_to_git
  after_update :update_config, :add_to_git
  after_destroy :remove_from_config, :remove_from_git

  def remote_git_repository_url
    configatron.remote_git_repository+":#{self.name}.git"
  end

  def public_key_filenames
    self.public_keys.collect(&:keyfilename).join(' ').gsub(/\.pub/, '')
  end

private
 
  def save_config 
    logger.info("Adding new repository #{self.name} to config")
    config = GitosisConfig.new
    config.lock do
      config.parse
      config.add_section(self.name)
      config.add_param_to_section(self.name, 'writable', self.name)
      config.save
    end
  end

  def update_config
    logger.info("Removing repository #{self.name_was} from config")
    logger.info("Adding new repository #{self.name} to config")
    config = GitosisConfig.new
    config.lock do
      config.parse
      config.remove_section(self.name_was)
      config.add_section(self.name)
      config.add_param_to_section(self.name, 'writable', self.name)
      config.add_param_to_section(self.name, 'members', self.public_key_filenames)
      config.save
    end 
  end  
   
  def remove_from_config  
    logger.info("Removing repository #{self.name} from config")
    config = GitosisConfig.new 
    config.lock do
      config.parse
      config.remove_section(self.name)
      config.save  
    end
  end 

  def add_to_git
    logger.info("Push config with new repository to git")
    git = GitosisAdmin.new
    git.push_config("Added new repository #{self.name}")
  end

  def remove_from_git
    logger.info("Push config with deleted repository to git")
    git = GitosisAdmin.new
    git.push_config("Removed repository #{self.name}")
  end

end
