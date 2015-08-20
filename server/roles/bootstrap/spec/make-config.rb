#  _                 _       _                     __                   
# | |__   ___   ___ | |_ ___| |_ _ __ __ _ _ __   / /__ _ __   ___  ___ 
# | '_ \ / _ \ / _ \| __/ __| __| '__/ _` | '_ \ / / __| '_ \ / _ \/ __|
# | |_) | (_) | (_) | |_\__ \ |_| | | (_| | |_) / /\__ \ |_) |  __/ (__ 
# |_.__/ \___/ \___/ \__|___/\__|_|  \__,_| .__/_/ |___/ .__/ \___|\___|
#                                         |_|          |_|              
describe 'bootstrap/make-config' do
  ansiblevars = MakeServer::Ansible.load_variables

  if defined?( ansiblevars['all'] ) then
    v = ansiblevars['all']['buildroot']

    describe file(v) do
      it { should be_directory }
      it { should be_owned_by 'root' }
      it { should be_readable }
      it { should be_writable }
      it { should be_executable }
    end
  end
end
