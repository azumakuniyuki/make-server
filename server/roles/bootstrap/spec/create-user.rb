#  _                 _       _                     __                   
# | |__   ___   ___ | |_ ___| |_ _ __ __ _ _ __   / /__ _ __   ___  ___ 
# | '_ \ / _ \ / _ \| __/ __| __| '__/ _` | '_ \ / / __| '_ \ / _ \/ __|
# | |_) | (_) | (_) | |_\__ \ |_| | | (_| | |_) / /\__ \ |_) |  __/ (__ 
# |_.__/ \___/ \___/ \__|___/\__|_|  \__,_| .__/_/ |___/ .__/ \___|\___|
#                                         |_|          |_|              
# create-user
ansiblevars = MakeServer::Ansible.load_variables

ansiblevars['role']['unixusers'].each do |v|
  # Test each user
  describe user(v['username']) do
    it { should exist }
    it { should belong_to_group v['group'] }
    it { should belong_to_group v['groups'] } if v['groups'].length > 0
    it { should have_uid v['uid'] }
    it { should have_home_directory v['home'] }
    it { should have_login_shell v['shell'] }
  end
end

