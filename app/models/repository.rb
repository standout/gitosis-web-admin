require 'gitosis_config'

class Repository < ActiveRecord::Base

  validates_uniqueness_of :name
  validates_format_of :name, :with => %r{^[a-z]+[0-9a-z_]+$} # repository name may only contain lowercase letters, numbers and underscores
  validates_format_of :email, :with => %r{^(?:[_a-z0-9-]+)(\.[_a-z0-9-]+)*@([a-z0-9-]+)(\.[a-zA-Z0-9\-\.]+)*(\.[a-z]{2,4})$}i 

  before_save :save_config
  # TODO: after_destroy

  def to_param
    self.name  
  end

private

  def save_config
    if self.new_record?
      # add new group
      @config ||= GitosisConfig.new
      @config.add_group(self.name)
      @config.add_to_group(self.name, 'writable', self.name)
      @config.save
    elsif self.name_changed?
      # rename group (delete old, add new)
      @config ||= GitosisConfig.new
      @config.remove_group(self.name_was)
      @config.add_group(self.name)
      @config.add_to_group(self.name, 'writable', self.name)
      @config.save
    end
  end

end
