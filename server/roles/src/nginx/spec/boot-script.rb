#              _                __                   
#  _ __   __ _(_)_ __ __  __   / /__ _ __   ___  ___ 
# | '_ \ / _` | | '_ \\ \/ /  / / __| '_ \ / _ \/ __|
# | | | | (_| | | | | |>  <  / /\__ \ |_) |  __/ (__ 
# |_| |_|\__, |_|_| |_/_/\_\/_/ |___/ .__/ \___|\___|
#        |___/                      |_|              
describe 'src/nginx/boot-script' do
  ansiblevars = MakeServer::Ansible.load_variables
  v = ansiblevars['role']['nginx']

  describe service(v['initscript']) do
    it { should be_enabled }     if     v['enabled']
    it { should_not be_enabled } unless v['enabled']
    it { should be_running }     if     v['started']
    it { should_not be_running } unless v['started']
  end
end


