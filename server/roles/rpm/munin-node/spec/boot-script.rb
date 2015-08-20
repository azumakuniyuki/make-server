#                        _                             _         __                   
#  _ __ ___  _   _ _ __ (_)_ __        _ __   ___   __| | ___   / /__ _ __   ___  ___ 
# | '_ ` _ \| | | | '_ \| | '_ \ _____| '_ \ / _ \ / _` |/ _ \ / / __| '_ \ / _ \/ __|
# | | | | | | |_| | | | | | | | |_____| | | | (_) | (_| |  __// /\__ \ |_) |  __/ (__ 
# |_| |_| |_|\__,_|_| |_|_|_| |_|     |_| |_|\___/ \__,_|\___/_/ |___/ .__/ \___|\___|
#                                                                    |_|              
describe 'rpm/munin-node/boot-script' do
  ansiblevars = MakeServer::Ansible.load_variables
  v = ansiblevars['role']['munin']['node']

  describe service('munin-node') do
    if v['started'] then
      it { should be_running }
    else
      it { should_not be_running }
    end

    if v['enabled'] then
      it { should be_enabled }
    else
      it { should_not be_enabled }
    end
  end
end
