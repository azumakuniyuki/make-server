#  _                 _       _                     __                   
# | |__   ___   ___ | |_ ___| |_ _ __ __ _ _ __   / /__ _ __   ___  ___ 
# | '_ \ / _ \ / _ \| __/ __| __| '__/ _` | '_ \ / / __| '_ \ / _ \/ __|
# | |_) | (_) | (_) | |_\__ \ |_| | | (_| | |_) / /\__ \ |_) |  __/ (__ 
# |_.__/ \___/ \___/ \__|___/\__|_|  \__,_| .__/_/ |___/ .__/ \___|\___|
#                                         |_|          |_|              
# create-user
describe 'create-user' do

  ansiblevars = MakeServer::Ansible.load_variables
  ansiblevars['role']['unixusers'].each do |e|
    # Test each user
    describe user(e['username']) do
      it { should exist }
      it { should belong_to_group e['group'] }
      it { should belong_to_group e['groups'] } if e['groups'].length > 0
      it { should have_uid e['uid'] }
      it { should have_home_directory e['home'] }
      it { should have_login_shell e['shell'] }
    end
  end

end
