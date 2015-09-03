#      _                          _      __                   
#   __| | _____   _____  ___ ___ | |_   / /__ _ __   ___  ___ 
#  / _` |/ _ \ \ / / _ \/ __/ _ \| __| / / __| '_ \ / _ \/ __|
# | (_| | (_) \ V /  __/ (_| (_) | |_ / /\__ \ |_) |  __/ (__ 
#  \__,_|\___/ \_/ \___|\___\___/ \__/_/ |___/ .__/ \___|\___|
#                                            |_|              
describe 'src/dovecot/install-pkg' do
  ansiblevars = MakeServer::Ansible.load_variables
  dovecotconf = ansiblevars['role']['dovecot']
  requiredpkg = dovecotconf['packages'][ os[:family].to_s ]

  requiredpkg.each_key do |e|
    requiredpkg[e].each do |ee|
      describe package(ee) do
        it { should be_installed }
      end
    end
  end
end


