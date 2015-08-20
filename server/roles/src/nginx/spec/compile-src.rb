#              _                __                   
#  _ __   __ _(_)_ __ __  __   / /__ _ __   ___  ___ 
# | '_ \ / _` | | '_ \\ \/ /  / / __| '_ \ / _ \/ __|
# | | | | (_| | | | | |>  <  / /\__ \ |_) |  __/ (__ 
# |_| |_|\__, |_|_| |_/_/\_\/_/ |___/ .__/ \___|\___|
#        |___/                      |_|              
describe 'src/nginx/compile-src' do
  ansiblevars = MakeServer::Ansible.load_variables
  v = ansiblevars['role']['nginx']

  describe 'Files and directories' do
    f = [ v['serverroot'] + '/conf/nginx.conf', '/etc/logrotate.d/nginx' ]

    f.each do |e|
      describe file(e) do
        it { should exist }
        it { should be_readable }
        its(:size) { should > 0 }
      end
    end

    d = %w|/keys /conf/virthosts|
    d.each do |e|
      e = v['serverroot'] + e

      describe file(e) do
        it { should exist }
        it { should be_directory }
        it { should be_readable }
        it { should be_executable }
        it { should be_mode '755' }
      end
    end
  end
end

