require 'rake'
require 'rspec/core/rake_task'
require 'yaml'

task :spec    => 'spec:all'
task :default => :spec

RolesDir = './server/roles'
RSpecDir = './serer/spec'

namespace :spec do
  # Serverspec related targets

  # Ansible related functions
  def make_hosttable
    # Returns host table as a hash
    inventory = './server/' + ( ENV['INVENTORY'] || 'vagrant' )
    groupvars = {}
    hosttable = {}

    # Load inventory file from ./server directory
    File.open(inventory) do |f|
      # Open inventory file
      currenthn = nil
      currentgn = nil

      varstable = {
        'ansible_ssh_host' => 'hostname',
        'ansible_ssh_port' => 'sshdport',
        'ansible_ssh_user' => 'username',
        'ansible_ssh_pass' => 'password',
        'ansible_ssh_private_key_file' => 'identity',
      }

      f.each_line do |line|
        # Read each line of inventory
        next if line.match(/\A#/)
        next if line.match(/\A\s*\z/)
        line = line.gsub( /\s\z/, '' )

        if line.match(/\A\[(.+):vars\]\s*\z/) then
          # Start group variables section, eg) [product:vars]
          currentgn = $1

        elsif line.match(/\A\[(.+)\]\s*\z/) then
          # Start group section, eg) [product]
          currentgn = $1

        else
          # Each host entry or variable
          if line.match(/\A[^\s]+\s+[^\s]+\z/) then
            # This line includes 1 or more space character like
            #   vm ansible_ssh_host=192.0.2.2
            line.split(' ').each do |e|
              # Check each token splited by ' '
              if e.match(/(.+)=(.+)/) then
                # Variable: ex) ansible_ssh_port=2022
                hosttable[currenthn][varstable[$1]] = $2

              else
                # Deal as hostname or IP address
                hosttable[e] ||= {}
                hosttable[e]['hostname'] = e
                hosttable[e]['group'] = currentgn
                currenthn = e
              end
            end

          elsif line.match(/([^\s]+)=([^\s]+)/) then
            # The line may be in [group:vars] section
            next unless varstable.key?($1)
            groupvars[currentgn] ||= {}
            groupvars[currentgn][varstable[$1]] = $2

          else
            # Deal as hostname or IP address, eg) 192.0.2.1
            hosttable[line] ||= {}
            hosttable[line]['hostname'] = line
            hosttable[line]['group'] = currentgn
            currenthn = line

          end # End of line.match(2)
          currenthn = ''

        end # End of line.match(1)

      end # End of f.each_line

      hosttable.each_key do |e|
        # Fill values in hosttable with groupvars
        next unless hosttable[e]['group']
        v = hosttable[e]['group']

        groupvars[v].each_key do |x|
          # Set values if the value in hosttable is empty
          hosttable[e][x] ||= groupvars[v][x]
        end

        # Default values
        hosttable[e]['sshdport'] ||= 22
        hosttable[e]['username'] ||= 'root'
        hosttable[e]['identity'] ||= '~/.ssh/id_rsa'

      end # End of hosttable.each_key

    end # End of File.open(inventory)

    return hosttable

  end

  def make_roleindex
    # Find roles from ./server/role directory
    medialist = [ 'src', 'rpm', 'deb', 'pkg' ]
    roleindex = []

    medialist.each do |e|
      # Find role directories
      rolespath = sprintf( "%s/%s/*", RolesDir, e )

      Dir.glob(rolespath).each do |role|
        next unless File.directory?(role)
        role = role.gsub( RolesDir + '/', '' )
        roleindex << role
      end
    end # End of medialist.each

    return roleindex
  end

  hosttable  = make_hosttable
  roleindex  = make_roleindex
  rolespecs  = {}
  tasknames  = []
  roleindex.unshift('bootstrap')

  roleindex.each do |role|
    # Find *.rb files in spec directory from all the roles
    rolespath = sprintf( "%s/%s/spec/*.rb", RolesDir, role )

    Dir.glob(rolespath).each do |file|
      next unless File.exist?(file)
      rolespecs[role] ||= []
      rolespecs[role]  << File.basename(file)
    end

  end # End of roleindex.each

  hosttable.each_key do |v|
    # Build environment variable for spec_helper.rb
    hostname  = hosttable[v]['hostname']
    tasknames = []

    ENV['SPEC_HOSTNAME'] = hostname
    ENV['SPEC_USERNAME'] = hosttable[v]['username']
    ENV['SPEC_SSHDPORT'] = hosttable[v]['sshdport']
    ENV['SPEC_IDENTITY'] = hosttable[v]['identity']

    if hosttable[v]['password'] then
      ENV['SPEC_PASSWORD'] = hosttable[v]['password']
    end

    rolespecs.each_key do |role|
      # Build each target and task
      thistask   = sprintf("%s:%s", hostname, role )
      tasknames << thistask

      desc sprintf( "Run serverspec tests to %s(%s)", hostname, role )
      RSpec::Core::RakeTask.new(thistask) do |task|
        task.pattern = sprintf( "%s/%s/spec/*.rb", RolesDir, role )
        task.verbose = true
      end

    end # End of rolespecs.each_key

    desc 'Run tests for Ansible environment'
    RSpec::Core::RakeTask.new(hostname + ':ansible-env') do |task|
      task.pattern = RSpecDir + '/[0-9][0-9]-*.rb'
    end

    tasknames.unshift( hostname + ':ansible-env' )
    # tasknames << hostname + ':ansible-env'
    desc sprintf( "Run all the serverspec tests to %s", hostname )
    task hostname + ':all' => tasknames

  end # End of hosttable.each_key

  task :all     => tasknames
  task :default => ':all'

end # End of namespace :spec

