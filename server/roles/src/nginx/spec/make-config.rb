#              _                __                   
#  _ __   __ _(_)_ __ __  __   / /__ _ __   ___  ___ 
# | '_ \ / _` | | '_ \\ \/ /  / / __| '_ \ / _ \/ __|
# | | | | (_| | | | | |>  <  / /\__ \ |_) |  __/ (__ 
# |_| |_|\__, |_|_| |_/_/\_\/_/ |___/ .__/ \___|\___|
#        |___/                      |_|              
describe 'src/nginx/make-config' do
  ansiblevars = MakeServer::Ansible.load_variables
  v = ansiblevars['role']['nginx']

  describe 'nginx binary' do
    b = v['serverroot'] + '/sbin/nginx'

    describe file(b) do
      it { should exist }
      it { should be_executable }
      it { should be_mode '755' }
      its(:size) { should > 0 }
    end

    describe command( b + ' -t' ) do
      its(:stderr) { should match /syntax is ok/ }
    end

    describe command( b + ' -v' ) do
      its(:stderr) { should match %r|nginx version: nginx/#{v['version']}| }
    end

    d = %w|/ /conf /html /logs /sbin|
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


