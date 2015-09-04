#      _                          _      __                   
#   __| | _____   _____  ___ ___ | |_   / /__ _ __   ___  ___ 
#  / _` |/ _ \ \ / / _ \/ __/ _ \| __| / / __| '_ \ / _ \/ __|
# | (_| | (_) \ V /  __/ (_| (_) | |_ / /\__ \ |_) |  __/ (__ 
#  \__,_|\___/ \_/ \___|\___\___/ \__/_/ |___/ .__/ \___|\___|
#                                            |_|              
describe 'src/dovecot/compile-src' do
  ansiblevars = MakeServer::Ansible.load_variables
  dovecotconf = ansiblevars['role']['dovecot']

  describe file( dovecotconf['serverroot'] + '/sbin/dovecot' ) do
    it { should exist }
    it { should be_file }
    it { should be_executable }
  end

  [ 'doveadm', 'doveconf' ].each do |e|
    describe file( dovecotconf['serverroot'] + '/bin/' + e ) do
      it { should exist }
      it { should be_file }
      it { should be_executable }
    end
  end
end
