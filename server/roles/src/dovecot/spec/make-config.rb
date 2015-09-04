#      _                          _      __                   
#   __| | _____   _____  ___ ___ | |_   / /__ _ __   ___  ___ 
#  / _` |/ _ \ \ / / _ \/ __/ _ \| __| / / __| '_ \ / _ \/ __|
# | (_| | (_) \ V /  __/ (_| (_) | |_ / /\__ \ |_) |  __/ (__ 
#  \__,_|\___/ \_/ \___|\___\___/ \__/_/ |___/ .__/ \___|\___|
#                                            |_|              
describe 'src/dovecot/make-config' do
  ansiblevars = MakeServer::Ansible.load_variables
  dovecotconf = ansiblevars['role']['dovecot']
  configrootd = dovecotconf['serverroot'] + '/etc'

  [ 'tls', 'conf.d' ].each do |e|
    f = [ configrootd, e ].join('/')

    describe file(f) do
      it { should exist }
      it { should be_directory }
      it { should be_owned_by 'root' }
      it { should be_mode 755 }
    end
  end

  [ 'dovecot.conf', 'openssl.conf', 'disabled-users', 'virtuser-passwd' ].each do |e|
    f = [ configrootd, e ].join('/')

    describe file(f) do
      it { should exist }
      it { should be_file }
      it { should be_owned_by 'root' }
      it { should be_mode 644 }
    end
  end

  [ 'var/log', 'var/run' ].each do |e|
    f = [ dovecotconf['serverroot'], e ].join('/')
    u = dovecotconf['user']

    describe file(f) do
      it { should exist }
      it { should be_directory }
      it { should be_owned_by u['daemon']['username'] }
      it { should be_grouped_into u['daemon']['group'] }
      it { should be_mode 755 }
    end
  end
end
