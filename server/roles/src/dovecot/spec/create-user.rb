#      _                          _      __                   
#   __| | _____   _____  ___ ___ | |_   / /__ _ __   ___  ___ 
#  / _` |/ _ \ \ / / _ \/ __/ _ \| __| / / __| '_ \ / _ \/ __|
# | (_| | (_) \ V /  __/ (_| (_) | |_ / /\__ \ |_) |  __/ (__ 
#  \__,_|\___/ \_/ \___|\___\___/ \__/_/ |___/ .__/ \___|\___|
#                                            |_|              
describe 'src/dovecot/create-user' do
  ansiblevars = MakeServer::Ansible.load_variables
  dovecotconf = ansiblevars['role']['dovecot']

  dovecotconf['user'].each_key do |e|
    # Test each user
    u = dovecotconf['user'][ e ]
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
