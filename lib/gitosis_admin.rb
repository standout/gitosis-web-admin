class GitosisAdmin

  def initialize
    @repository = Git.open(configatron.gitosis_admin_root) #, :log => Logger.new(STDOUT)
    @repository.config('user.name', 'Gitosis web admin')      
  end

  def push_config(message)
    push(message) do
      @repository.add(File.join(configatron.gitosis_admin_root, configatron.gitosis_config))
    end
  end

  def push_key(filename, message)
    push(message) do
      @repository.add(File.join(configatron.gitosis_admin_root, configatron.gitosis_config))
      @repository.add(File.join(configatron.gitosis_admin_root, configatron.gitosis_keydir, filename))
    end
  end

  def remove_key(filename, message)
    push(message) do
      @repository.add(File.join(configatron.gitosis_admin_root, configatron.gitosis_config))
      @repository.remove(File.join(configatron.gitosis_admin_root, configatron.gitosis_keydir, filename))
    end
  end

private  

  def push(message)
    @repository.pull
    yield
    @repository.commit(message)
    @repository.push
  end

end