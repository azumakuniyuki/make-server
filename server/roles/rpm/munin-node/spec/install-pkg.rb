#                        _                             _         __                   
#  _ __ ___  _   _ _ __ (_)_ __        _ __   ___   __| | ___   / /__ _ __   ___  ___ 
# | '_ ` _ \| | | | '_ \| | '_ \ _____| '_ \ / _ \ / _` |/ _ \ / / __| '_ \ / _ \/ __|
# | | | | | | |_| | | | | | | | |_____| | | | (_) | (_| |  __// /\__ \ |_) |  __/ (__ 
# |_| |_| |_|\__,_|_| |_|_|_| |_|     |_| |_|\___/ \__,_|\___/_/ |___/ .__/ \___|\___|
#                                                                    |_|              
# install-pkg
describe package('munin-node') do
  it { should be_installed }
end

if false then
  # these tests fail...
  modules = %w|LWP::UserAgent IPC::Cmd JSON::Syck Net::CIDR|
  modules.each do |e|
    describe package(e) do
      it { should be_installed }
    end
  end
end
