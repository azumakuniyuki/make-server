#                         ___           _ _     _           _                   
#  ___ _ __   ___  ___   / / |__  _   _(_) | __| |      ___| |_ __ _  __ _  ___ 
# / __| '_ \ / _ \/ __| / /| '_ \| | | | | |/ _` |_____/ __| __/ _` |/ _` |/ _ \
# \__ \ |_) |  __/ (__ / / | |_) | |_| | | | (_| |_____\__ \ || (_| | (_| |  __/
# |___/ .__/ \___|\___/_/  |_.__/ \__,_|_|_|\__,_|     |___/\__\__,_|\__, |\___|
#     |_|                                                            |___/      
# Test code for server/10-build-stage.yml
describe '10-build-stage' do
  describe 'Python environment' do
    describe command('which python') do
      its(:stdout) { should match( %r|/bin/python| ) }
    end

    describe command('python --version') do
      its(:stderr) { should match( %r|2[.][67]| ) }
    end
  end

  describe 'Users and groups' do
    describe group('wheel') do
      it { should exist }
    end

    describe user('root') do
      it { should belong_to_group('wheel') }
    end
  end

  describe 'sudo program and files' do
    describe package('sudo') do
      it { should be_installed }
    end

    if os[:family] == 'freebsd' then
      # FreeBSD
      describe file('/usr/local/etc/sudoers') do
        its(:content) { should match(/^%wheel/) }
      end
    else
      # Redhat, Debian, OpenBSD
      describe file('/etc/sudoers') do
        its(:content) { should match(/^%wheel/) }
      end
    end
  end
end
