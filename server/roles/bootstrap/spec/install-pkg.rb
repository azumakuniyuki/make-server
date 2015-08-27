#  _                 _       _                     __                   
# | |__   ___   ___ | |_ ___| |_ _ __ __ _ _ __   / /__ _ __   ___  ___ 
# | '_ \ / _ \ / _ \| __/ __| __| '__/ _` | '_ \ / / __| '_ \ / _ \/ __|
# | |_) | (_) | (_) | |_\__ \ |_| | | (_| | |_) / /\__ \ |_) |  __/ (__ 
# |_.__/ \___/ \___/ \__|___/\__|_|  \__,_| .__/_/ |___/ .__/ \___|\___|
#                                         |_|          |_|              
describe 'bootstrap/install-pkg' do
  ansiblevars = MakeServer::Ansible.load_variables
  packagelist = ansiblevars['role']['packages']

  packagelist[ os[:family].to_s ].each_key do |e|
    p = packagelist[ os[:family].to_s ][e]
    p.each do |ee|
      describe package(ee) do
        it { should be_installed }
      end
    end
  end
end

