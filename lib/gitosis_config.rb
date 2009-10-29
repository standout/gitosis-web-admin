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

  def write(output_stream=STDOUT)
    self.params.each do |name,value|
      if value.class.to_s != 'Hash'
        #if value.scan(/\w+/).length > 1
        #  output_stream.puts "#{name} = \"#{value}\""
        #else
        output_stream.puts "#{name} = #{value}"
        #end
      end
    end
    output_stream.puts "\n"

    self.groups.each do |group|
      output_stream.puts "[#{group}]"
      self.params[group].each do |param, value|
        #if value.scan(/\w+/).length > 1
        #  output_stream.puts "#{param} = \"#{value}\""
        #else
        output_stream.puts "#{param} = #{value}"
        #end
      end
      output_stream.puts "\n"
    end
  end
end