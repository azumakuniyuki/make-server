#           _ _                      __                   
#  ___  ___| (_)_ __  _   ___  __   / /__ _ __   ___  ___ 
# / __|/ _ \ | | '_ \| | | \ \/ /  / / __| '_ \ / _ \/ __|
# \__ \  __/ | | | | | |_| |>  <  / /\__ \ |_) |  __/ (__ 
# |___/\___|_|_|_| |_|\__,_/_/\_\/_/ |___/ .__/ \___|\___|
#                                        |_|              
describe 'env/selinux/make-config' do
  ansiblevars = MakeServer::Ansible.load_variables
  v = ansiblevars['role']['selinux']

  if ['debian', 'ubuntu'].include?(os[:family]) then
    if v['disabled'] then
      describe selinux do
        it { should be_disabled }
      end
    else
      describe selinux do
        it { should be_enabled }
      end
    end
  end
end



