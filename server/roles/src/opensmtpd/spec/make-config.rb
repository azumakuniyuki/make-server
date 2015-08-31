#   ___                   ____  __  __ _____ ____  ____    __                   
#  / _ \ _ __   ___ _ __ / ___||  \/  |_   _|  _ \|  _ \  / /__ _ __   ___  ___ 
# | | | | '_ \ / _ \ '_ \\___ \| |\/| | | | | |_) | | | |/ / __| '_ \ / _ \/ __|
# | |_| | |_) |  __/ | | |___) | |  | | | | |  __/| |_| / /\__ \ |_) |  __/ (__ 
#  \___/| .__/ \___|_| |_|____/|_|  |_| |_| |_|   |____/_/ |___/ .__/ \___|\___|
#       |_|                                                    |_|              
describe 'src/opensmtpd/boot-script' do
  ansiblevars = MakeServer::Ansible.load_variables
  opensmtpdcf = ansiblevars['role']['opensmtpd']
  configrootd = opensmtpdcf['serverroot'] + '/etc'

  describe 'Files and directories' do
    f = [ configrootd, 'smtpd.conf' ].join('/')
    describe file(f) do
      it { should exist }
      it { should be_file }
    end

    opensmtpdcf['files']['dbmap'].each do |e|
      f = [ configrootd, e ].join('/')
      describe file(f) do
        it { should exist }
        it { should be_file }
      end

      f = f + '.db'
      describe file(f) do
        it { should exist }
        it { should be_file }
      end
    end
  end
end
