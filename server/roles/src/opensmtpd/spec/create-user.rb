#   ___                   ____  __  __ _____ ____  ____    __                   
#  / _ \ _ __   ___ _ __ / ___||  \/  |_   _|  _ \|  _ \  / /__ _ __   ___  ___ 
# | | | | '_ \ / _ \ '_ \\___ \| |\/| | | | | |_) | | | |/ / __| '_ \ / _ \/ __|
# | |_| | |_) |  __/ | | |___) | |  | | | | |  __/| |_| / /\__ \ |_) |  __/ (__ 
#  \___/| .__/ \___|_| |_|____/|_|  |_| |_| |_|   |____/_/ |___/ .__/ \___|\___|
#       |_|                                                    |_|              
describe 'src/opensmtpd/create-user' do
  ansiblevars = MakeServer::Ansible.load_variables
  opensmtpdcf = ansiblevars['role']['opensmtpd']

  opensmtpdcf['user'].each_key do |e|
    # Test each user
    u = opensmtpdcf['user'][ e ]
    describe group(u['group']) do
      it { should exist }
      it { should have_gid u['gid'] }
    end

    describe user(u['username']) do
      it { should exist }
      it { should belong_to_group u['group'] }
      it { should have_uid u['uid'] }
      it { should have_home_directory u['home'] }
      it { should have_login_shell u['shell'] }
    end
  end
end
