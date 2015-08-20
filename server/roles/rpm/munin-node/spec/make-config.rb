#                        _                             _         __                   
#  _ __ ___  _   _ _ __ (_)_ __        _ __   ___   __| | ___   / /__ _ __   ___  ___ 
# | '_ ` _ \| | | | '_ \| | '_ \ _____| '_ \ / _ \ / _` |/ _ \ / / __| '_ \ / _ \/ __|
# | | | | | | |_| | | | | | | | |_____| | | | (_) | (_| |  __// /\__ \ |_) |  __/ (__ 
# |_| |_| |_|\__,_|_| |_|_|_| |_|     |_| |_|\___/ \__,_|\___/_/ |___/ .__/ \___|\___|
#                                                                    |_|              
describe 'rpm/munin-node/make-config' do
  ansiblevars = MakeServer::Ansible.load_variables
  configfiles = %w|/etc/munin/munin-node.conf /etc/logrotate.d/munin-node|
  v = ansiblevars['role']['munin']['node']

  describe 'Configuration files' do
    configfiles.each do |e|
      describe file(e) do
        it { should exist }
        it { should be_file }
        it { should be_readable }
        its(:size) { should > 0 }
      end
    end
  end

  describe 'Relevant directory' do
    describe file(v['logdirectory']) do
      it { should exist }
      it { should be_directory }
      it { should be_readable }
      it { should be_writable }
      it { should be_executable }
      it { should be_owned_by('munin') }
      it { should be_grouped_into('munin') }
      it { should be_mode('755') }
    end
  end
end

