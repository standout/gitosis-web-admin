

namespace :gitosis do

  desc "Imports the data from your gitosis.conf to your database"
  task :import => :environment  do
    # TODO: manage all notations
    
    PublicKey.all.collect(&:destroy_without_callbacks)
    Permission.all.collect(&:destroy_without_callbacks)    
    Repository.all.collect(&:destroy_without_callbacks)
    old_keyfiles = []

    config = GitosisConfig.new
    config.lock do
      puts "\nYour current config"
      puts "-" * 50
      puts config.output

      puts "\nE-Mail address that will be associated with the data"
      puts "-" * 50
      owner = STDIN.gets.chomp

      puts "\nMigrating config"
      puts "-" * 50
      
      config.structure.each do |key, value|
        if value.is_a?(Hash)
          # is a repository
          r = Repository.new(:name => key, :email => owner)
          raise "Repository #{r.name} not valid: #{r.errors.full_messages.inspect}" unless r.valid?
          r.send(:create_without_callbacks)
          puts "++ Created repository #{r.name}"

          value.each do |k, v|
            # is a member
            if k == 'members'
              members = v.split(' ')
              members.each do |member|

                # Get key content
                key_parts = []
                keyfilename = File.join(configatron.gitosis_admin_root, configatron.gitosis_keydir, member+".pub")
                File.read(keyfilename).each { |line| key_parts << line }
                key_content = key_parts.join("\n")

                # save to database
                pk = PublicKey.find_or_initialize_by_source(key_content)
                if pk.new_record?
                  pk.email = owner
                  pk.description = "Public key #{member} imported by gitosis web admin rake task"
                  raise "Public key #{pk.name} not valid: #{r.errors.full_messages.inspect}" unless pk.valid?
                  pk.send(:create_without_callbacks)
                  new_keyfile = File.new(File.join(configatron.gitosis_admin_root, configatron.gitosis_keydir, pk.keyfilename), 'w')
                  new_keyfile.puts pk.source
                  new_keyfile.close
                  old_keyfiles << keyfilename 

                  puts "++ Created public key #{member}"
                end

                p = Permission.find_or_initialize_by_repository_id_and_public_key_id(r.id, pk.id)
                if p.new_record?
                  p.send(:create_without_callbacks)
                  puts "++ Associated public key #{member} with repository #{r.name}"
                end
              end
              puts "-" * 20
            end
          end

          r.reload
          config.add_param_to_section(r.name, 'members', r.public_key_filenames)
        end
      end

      # Update configuration file
      puts config.output
      config.save
    end
    
    # cleanup file system and commit to git
    puts "\nPushing changes to git repository"
    puts "-" * 50    
    repository = Git.open(configatron.gitosis_admin_root)
    repository.config('user.name', 'Gitosis web admin rake task')
    repository.pull
    old_keyfiles.each do |keyfile|
      repository.remove(keyfile)
    end
    repository.add('.')
    repository.add('gitosis.conf')      
    repository.commit_all('Migrating configuration to gitosis web admin')
    repository.push

    puts "Finished migrating your configuration to gitosis web admin.\n"
  end

end