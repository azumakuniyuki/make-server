require 'serverspec'
require 'net/ssh'

set :backend, :ssh
set :request_pty, true

if ENV['ASK_SUDO_PASSWORD']
  begin
    require 'highline/import'
  rescue LoadError
    fail "highline is not available. Try installing it."
  end
  set :sudo_password, ask("Enter sudo password: ") { |q| q.echo = false }
else
  # The value of ENV['SPEC_PASSWORD'] is set in Rakefile
  set :sudo_password, ENV['SPEC_PASSWORD']
end

# Set values for rspec
sshhost = ENV['SPEC_HOSTNAME']
options = Net::SSH::Config.for(sshhost)

options[:user] = ENV['SPEC_USERNAME'] if ENV['SPEC_USERNAME']
options[:port] = ENV['SPEC_SSHDPORT'] if ENV['SPEC_SSHDPORT']
options[:keys] = ENV['SPEC_IDENTITY'] if ENV['SPEC_IDENTITY']

if ENV['SPEC_USERNAME'] == "vagrant" then
  # To avoid Net::SSH::HostKeyMismatch exception
  options[:paranoid] = false
end

if ENV['SPEC_PASSWORD'] then
  # The value of ENV['SPEC_PASSWORD'] is set in Rakefile
  options[:password] = ENV['SPEC_PASSWORD']
end

set :host,        options[:host_name] || sshhost
set :ssh_options, options
set :disable_sudo,false
set :env,         :LANG => 'C', :LC_MESSAGES => 'C'
set :path,        '/usr/local/bin:/usr/local/sbin:/usr/sbin:/sbin:$PATH'

puts '* hostname = ' + sshhost.to_s
puts '* username = ' + options[:user].to_s
puts '* sshdport = ' + options[:port].to_s
puts '* identity = ' + options[:keys].to_s

