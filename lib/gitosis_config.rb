require 'parse_config'

class GitosisConfig < ParseConfig

  # Initializes the gitosis.conf
  def initialize
    @configuration_file = File.join(configatron.gitosis_admin_root, configatron.gitosis_config)
    super(@configuration_file)
  end

  # Overrides a key / value pair in the specified group
  def override_group_value(group, param, value)
    self.instance_eval("@#{group}[\"#{param}\"] = \"#{value}\"")
  end

  # Adds a new group to the config file
  def add_group(group_name)
    self.add(group_name, {})
    self.groups.push(group_name)    
  end

  # Removes a group from the config file
  def remove_group(group_name)  
    self.groups.delete(group_name)
  end

  # Saves gitosis.conf to disk
  def save
    file = open(@configuration_file, 'w')
    self.write(file)
    file.close
  end 

end