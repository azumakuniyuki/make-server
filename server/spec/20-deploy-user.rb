#                         __  _            _                                       
#  ___ _ __   ___  ___   / /_| | ___ _ __ | | ___  _   _       _   _ ___  ___ _ __ 
# / __| '_ \ / _ \/ __| / / _` |/ _ \ '_ \| |/ _ \| | | |_____| | | / __|/ _ \ '__|
# \__ \ |_) |  __/ (__ / / (_| |  __/ |_) | | (_) | |_| |_____| |_| \__ \  __/ |   
# |___/ .__/ \___|\___/_/ \__,_|\___| .__/|_|\___/ \__, |      \__,_|___/\___|_|   
#     |_|                           |_|            |___/                           
# Test code for server/20-deploy-user.yml
describe '20-deploy-user' do
  describe 'Users and groups' do
    describe group('deploy') do
      it { should exist }
    end

    describe user('deploy') do
      it { should exist }
    end
  end

  describe 'sudo file to be included' do
    if os[:family] == 'freebsd' then
      # FreeBSD
      describe file('/usr/local/etc/sudoers.d/deploy') do
        it { should exist }
        it { should be_mode('440') }
        its(:content) { should match(/^%deploy/) }
      end
    else
      # Redhat, Debian, OpenBSD
      describe file('/etc/sudoers.d/deploy') do
        it { should exist }
        it { should be_mode('440') }
        its(:content) { should match(/^%deploy/) }
      end
    end
  end
end
