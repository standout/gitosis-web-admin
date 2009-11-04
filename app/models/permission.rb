class Permission < ActiveRecord::Base

  belongs_to :repository
  belongs_to :public_key

  after_create :add_key_to_config, :add_to_git, :initialize_repository
  after_destroy :remove_key_from_config, :remove_from_git

private  

  def add_key_to_config
    logger.info("Adding key #{self.public_key.keyfilename} to repository #{self.repository.name}")
    config = GitosisConfig.new
    config.lock do
      config.parse
      config.add_param_to_section(self.repository.name, 'members', self.repository.public_key_filenames)
      config.save
    end
  end

  def remove_key_from_config
    logger.info("Removing key #{self.public_key.keyfilename} from repository #{self.repository.name}")
    config = GitosisConfig.new
    config.lock do
      config.parse
      config.add_param_to_section(self.repository.name, 'members', self.repository.public_key_filenames)
      config.save
    end
  end   

  def add_to_git
    logger.info("Push config with key #{self.public_key.keyfilename} added to repository #{self.repository.name}")
    git = GitosisAdmin.new
    git.push_config("Added key #{self.public_key.keyfilename} to repository #{self.repository.name}")
  end

  def remove_from_git
    logger.info("Push config with key #{self.public_key.keyfilename} removed from repository #{self.repository.name}")
    git = GitosisAdmin.new
    git.push_config("Removed key #{self.public_key.keyfilename} from repository #{self.repository.name}")
  end

  def initialize_repository
    # Do initial push to initialize trigger creation if it's the first key
    if self.repository.public_keys == [self.public_key]
      git_tmp_path = File.join(RAILS_ROOT, 'tmp', 'repositories', self.repository.name)
      git_tmp = Git.init(git_tmp_path)
      if git_tmp.log.blank? # no commits yet
        git_tmp.add_remote("origin", self.repository.remote_git_repository_url)
        git_tmp.add('.')
        git_tmp.commit_all('Initialized repository')
        git_tmp.push
      end
      FileUtils.rm_rf(git_tmp_path)
    end
  end

end
