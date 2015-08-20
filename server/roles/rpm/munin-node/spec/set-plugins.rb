#                        _                             _         __                   
#  _ __ ___  _   _ _ __ (_)_ __        _ __   ___   __| | ___   / /__ _ __   ___  ___ 
# | '_ ` _ \| | | | '_ \| | '_ \ _____| '_ \ / _ \ / _` |/ _ \ / / __| '_ \ / _ \/ __|
# | | | | | | |_| | | | | | | | |_____| | | | (_) | (_| |  __// /\__ \ |_) |  __/ (__ 
# |_| |_| |_|\__,_|_| |_|_|_| |_|     |_| |_|\___/ \__,_|\___/_/ |___/ .__/ \___|\___|
#                                                                    |_|              
describe 'rpm/munin-node/set-plugins' do
  ansiblevars = MakeServer::Ansible.load_variables
  v = ansiblevars['role']['munin']['node']

  describe 'Plug-in configuration file' do
    v['plugins'].each_key do |e|
      next unless v['plugins'][e]
      f = '/etc/munin/plugin-conf.d/' + e

      describe file(f) do
        it { should exist }
        it { should be_file }
        it { should be_readable }
        its(:size) { should > 0 }
      end
    end
  end

  describe 'Plug-in symbolic link' do
    v['plugins'].each_key do |e|
      next unless v['plugins'][e]
      before do
        symlinks = []
      end

      File.glob("/etc/munin/plugins/#{e}_*").each do |ee|
        symlinks << ee
      end

      symlinks.each do |ee|
        describe file(ee) do
          it { should exist }
          it { should be_symlink }
        end
      end

    end
  end
end
