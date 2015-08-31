#   ___                   ____  __  __ _____ ____  ____    __                   
#  / _ \ _ __   ___ _ __ / ___||  \/  |_   _|  _ \|  _ \  / /__ _ __   ___  ___ 
# | | | | '_ \ / _ \ '_ \\___ \| |\/| | | | | |_) | | | |/ / __| '_ \ / _ \/ __|
# | |_| | |_) |  __/ | | |___) | |  | | | | |  __/| |_| / /\__ \ |_) |  __/ (__ 
#  \___/| .__/ \___|_| |_|____/|_|  |_| |_| |_|   |____/_/ |___/ .__/ \___|\___|
#       |_|                                                    |_|              
describe 'src/opensmtpd/boot-script' do
  ansiblevars = MakeServer::Ansible.load_variables
  opensmtpdcf = ansiblevars['role']['opensmtpd']

  if os[:family] == "freebsd" then
    f = '/usr/local/etc/rc.d/' + opensmtpdcf['initscript']
    describe file(f) do
      it { should exist }
      it { should be_file }
      it { should be_owned_by 'root' }
      it { should be_grouped_into 'wheel' }
      it { should be_mode 755 }
    end

  elsif os[:family] == "redhat" then
    describe service( opensmtpdcf['initscript'] ) do
      it { should be_enabled }
      it { should be_running }
    end
  end

  describe service('sendmail') do
    it { should_not be_enabled }
    it { should_not be_running }
  end
end
