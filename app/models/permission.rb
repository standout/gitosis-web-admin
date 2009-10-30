class Permission < ActiveRecord::Base

  belongs_to :repository
  belongs_to :public_key

  after_save :add_key_to_config
  after_destroy :remove_key_from_config

private  

  def add_key_to_config
    logger.info("Adding key #{self.public_key.keyfilename} to repository #{self.repository.name}")
    @config ||= GitosisConfig.new
    @config.lock do
      @config.parse
      @config.add_param_to_section(self.repository.name, 'members', self.repository.public_key_filenames)
      @config.save
    end
  end

  def remove_key_from_config
    logger.info("Removing key #{self.public_key.keyfilename} from repository #{self.repository.name}")
    @config ||= GitosisConfig.new
    @config.lock do
      @config.parse
      @config.add_param_to_section(self.repository.name, 'members', self.repository.public_key_filenames)
      @config.save
    end
  end   


end
