#              _                __                   
#  _ __   __ _(_)_ __ __  __   / /__ _ __   ___  ___ 
# | '_ \ / _` | | '_ \\ \/ /  / / __| '_ \ / _ \/ __|
# | | | | (_| | | | | |>  <  / /\__ \ |_) |  __/ (__ 
# |_| |_|\__, |_|_| |_/_/\_\/_/ |___/ .__/ \___|\___|
#        |___/                      |_|              
describe 'src/nginx/create-user' do
  ansiblevars = MakeServer::Ansible.load_variables
  v = ansiblevars['role']['nginx']
  u = v['user']

  describe 'User and group for running nginx' do
    describe user(u['username']) do
      it { should exist }
      it { should belong_to_group u['group'] }
      it { should have_uid u['uid'] }
      it { should have_login_shell u['shell'] }
      it { should have_home_directory v['serverroot'] }
    end

    describe group(u['group']) do
      it { should exist }
      it { should have_gid u['gid'] }
    end
  end
end
