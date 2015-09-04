#      _                          _      __                   
#   __| | _____   _____  ___ ___ | |_   / /__ _ __   ___  ___ 
#  / _` |/ _ \ \ / / _ \/ __/ _ \| __| / / __| '_ \ / _ \/ __|
# | (_| | (_) \ V /  __/ (_| (_) | |_ / /\__ \ |_) |  __/ (__ 
#  \__,_|\___/ \_/ \___|\___\___/ \__/_/ |___/ .__/ \___|\___|
#                                            |_|              
describe 'src/dovecot/boot-script' do
  ansiblevars = MakeServer::Ansible.load_variables
  dovecotconf = ansiblevars['role']['dovecot']

  if os[:family] == "freebsd" then
    f = '/usr/local/etc/rc.d/' + dovecotconf['initscript']
    describe file(f) do
      it { should exist }
      it { should be_file }
      it { should be_owned_by 'root' }
      it { should be_grouped_into 'wheel' }
      it { should be_mode 755 }
    end

  elsif os[:family] == "redhat" then
    describe service( dovecotconf['initscript'] ) do
      it { should be_enabled }
      it { should be_running }
    end
  end
end
