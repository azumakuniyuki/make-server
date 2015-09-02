#   ___                   ____  __  __ _____ ____  ____    __                   
#  / _ \ _ __   ___ _ __ / ___||  \/  |_   _|  _ \|  _ \  / /__ _ __   ___  ___ 
# | | | | '_ \ / _ \ '_ \\___ \| |\/| | | | | |_) | | | |/ / __| '_ \ / _ \/ __|
# | |_| | |_) |  __/ | | |___) | |  | | | | |  __/| |_| / /\__ \ |_) |  __/ (__ 
#  \___/| .__/ \___|_| |_|____/|_|  |_| |_| |_|   |____/_/ |___/ .__/ \___|\___|
#       |_|                                                    |_|              
describe 'src/opensmtpd/install-pkg' do
  ansiblevars = MakeServer::Ansible.load_variables
  opensmtpdcf = ansiblevars['role']['opensmtpd']
  requiredpkg = opensmtpdcf['packages'][ os[:family].to_s ]['install']

  requiredpkg.each do |e|
    describe package(e) do
      it { should be_installed }
    end
  end
end

