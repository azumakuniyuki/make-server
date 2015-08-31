#   ___                   ____  __  __ _____ ____  ____    __                   
#  / _ \ _ __   ___ _ __ / ___||  \/  |_   _|  _ \|  _ \  / /__ _ __   ___  ___ 
# | | | | '_ \ / _ \ '_ \\___ \| |\/| | | | | |_) | | | |/ / __| '_ \ / _ \/ __|
# | |_| | |_) |  __/ | | |___) | |  | | | | |  __/| |_| / /\__ \ |_) |  __/ (__ 
#  \___/| .__/ \___|_| |_|____/|_|  |_| |_| |_|   |____/_/ |___/ .__/ \___|\___|
#       |_|                                                    |_|              
describe 'src/opensmtpd/compile-src' do
  ansiblevars = MakeServer::Ansible.load_variables
  opensmtpdcf = ansiblevars['role']['opensmtpd']
  maildropcnf = ansiblevars['role']['maildrop']

  describe file( opensmtpdcf['serverroot'] + '/sbin/smtpd' ) do
    it { should exist }
    it { should be_file }
    it { should be_executable }
  end

  describe file( maildropcnf['install'] + '/bin/maildrop' ) do
    it { should exist }
    it { should be_file }
    it { should be_executable }
  end
end

