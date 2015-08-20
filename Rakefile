require 'rake'
require 'rspec/core/rake_task'
require './lib/ansible_helper'

task :spec    => 'spec:all'
task :default => :spec

RolesDir = './server/roles'
RSpecDir = './server/spec'

namespace :spec do
  # Serverspec related targets
  hosttable  = MakeServer::Ansible.load_inventory( ENV["INVENTORY"] || "vagrant" )
  roleindex  = MakeServer::Ansible.make_roleindex
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
    ENV['SPEC_THEGROUP'] = hosttable[v]['group']
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
        # Define spec:<hostname>:<role name> task
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

