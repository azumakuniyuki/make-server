#                  _    __                   
#  _ __   ___ _ __| |  / /__ _ __   ___  ___ 
# | '_ \ / _ \ '__| | / / __| '_ \ / _ \/ __|
# | |_) |  __/ |  | |/ /\__ \ |_) |  __/ (__ 
# | .__/ \___|_|  |_/_/ |___/ .__/ \___|\___|
# |_|                       |_|              
describe 'src/perl/compile-src' do
  ansiblevars = MakeServer::Ansible.load_variables
  v = ansiblevars['role']['perl']

  describe 'Perl binary' do
    b = v['install'] + '/bin/perl'

    describe file( b ) do
      it { should be_exist }
      it { should be_file }
      it { should be_executable }
      it { should be_mode('755') }
      it { should be_owned_by('root') }
    end

    describe command( b + ' --version' ) do
      its(:stdout) { should match /Larry Wall/ }
      its(:stdout) { should match %r(v#{v['version']}) }
    end
  end
end

