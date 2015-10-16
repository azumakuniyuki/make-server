require "yaml"

module MakeServer
  module Ansible
    # Helper class for Ansible files
    class << self
      @@RootDir  = 'server'
      @@RoleDir = @@RootDir + '/roles'
      @@SpecDir = @@RootDir + '/spec'

      def load_inventory(inventory)
        # Load inventory file from ./server directory
        inventory = @@RootDir + '/' + inventory
        groupvars = {}
        hosttable = {}

        File.open(inventory) do |f|
          # Open inventory file
          currhostname  = nil
          currgroupname = nil

          varstable = {
            'ansible_ssh_host' => 'hostname',
            'ansible_ssh_port' => 'sshdport',
            'ansible_ssh_user' => 'username',
            'ansible_ssh_pass' => 'password',
            'ansible_ssh_private_key_file' => 'identity',
          }

          f.each_line do |line|
            # Read each line of inventory
            next if line.match %r/\A#/
            next if line.match %r/\A\s*\z/
            line = line.gsub %r/\s\z/, ''

            if line.match %r/\A\[(.+):vars\]\s*\z/ then
              # Start group variables section, eg) [product:vars]
              currgroupname = $1

            elsif line.match %r/\A\[(.+)\]\s*\z/ then
              # Start group section, eg) [product]
              currgroupname = $1

            else
              # Each host entry or variable
              if line.match %r/\A[^\s]+\s+[^\s]+\z/ then
                # This line includes 1 or more space character like
                #   vm ansible_ssh_host=192.0.2.2
                line.split(' ').each do |e|
                  # Check each token splited by ' '
                  if e.match %r/(.+)=(.+)/ then
                    # Variable: ex) ansible_ssh_port=2022
                    hosttable[currhostname][varstable[$1]] = $2

                  else
                    # Deal as hostname or IP address
                    hosttable[e] ||= {}
                    hosttable[e]['hostname'] = e
                    hosttable[e]['group'] = currgroupname
                    currhostname = e
                  end
                end

              elsif line.match %r/([^\s]+)=([^\s]+)/ then
                # The line may be in [group:vars] section
                next unless varstable.key?($1)
                groupvars[currgroupname] ||= {}
                groupvars[currgroupname][varstable[$1]] = $2

              else
                # Deal as hostname or IP address, eg) 192.0.2.1
                hosttable[line] ||= {}
                hosttable[line]['hostname'] = line
                hosttable[line]['group'] = currgroupname
                currhostname = line
              end # End of line.match(2)

              currhostname = ''
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
        medialist = [ 'src', 'rpm', 'deb', 'pkg', 'env' ]
        roleindex = []

        medialist.each do |e|
          # Find role directories
          rolespath = sprintf( "%s/%s/*", @@RoleDir, e )

          Dir.glob(rolespath).each do |role|
            next unless File.directory?(role)
            role = role.gsub( @@RoleDir + '/', '' )
            roleindex << role
          end
        end # End of medialist.each

        return roleindex
      end

      def load_variables( f = 'main.yml' )
        # Function to load server/roles/*/vars/main.yml
        # or load the first argument file in vars/ directory
        variables = { 'role' => nil, 'host' => nil, 'group' => nil, 'all' => nil }

        # Role variables
        v = caller[0].split(':')[0]
        v = v.gsub( %r|\A.+/(#{@@RoleDir}/.+)/spec/.+[.]rb|, '\1/vars/' + f )

        if File.exists?(v) then
          # Load server/roles/*/vars/main.yml
          variables['role'] = YAML.load_file(v)
        end

        # Host variables
        v = @@RootDir + '/host_vars/' + ENV['SPEC_HOSTNAME']
        if File.exists?(v) then
          # Load server/host_vars/<hostname>
          variables['host'] = YAML.load_file(v)

        elsif File.exists?( v + '.yml' ) then
          # Try to load the file with ".yml"
          variables['host'] = YAML.load_file( v + '.yml' )
        end

        # Group variables
        v = @@RootDir + '/group_vars/' + ENV['SPEC_THEGROUP']
        if File.exists?(v) then
          # Load server/group_vars/<hostname>
          variables['group'] = YAML.load_file(v)

        elsif File.exists?( v + '.yml' ) then
          # Try to load the file with ".yml"
          variables['group'] = YAML.load_file( v + '.yml' )
        end

        # All group variables
        v = @@RootDir + '/group_vars/all'
        if File.exists?(v) then
          # Load server/group_vars/<hostname>
          variables['all'] = YAML.load_file(v)

        elsif File.exists?( v + '.yml' ) then
          # Try to load the file with ".yml"
          variables['all'] = YAML.load_file( v + '.yml' )
        end

        return variables
      end

    end # End of class << self
  end # End of module Ansible
end # End of module MakeServer

