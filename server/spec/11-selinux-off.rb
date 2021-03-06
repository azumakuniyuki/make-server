#                         __        _ _                              __  __ 
#  ___ _ __   ___  ___   / /__  ___| (_)_ __  _   ___  __      ___  / _|/ _|
# / __| '_ \ / _ \/ __| / / __|/ _ \ | | '_ \| | | \ \/ /____ / _ \| |_| |_ 
# \__ \ |_) |  __/ (__ / /\__ \  __/ | | | | | |_| |>  <_____| (_) |  _|  _|
# |___/ .__/ \___|\___/_/ |___/\___|_|_|_| |_|\__,_/_/\_\     \___/|_| |_|  
#     |_|                                                                   
# Test code for server/11-selinux-off.yml
describe '11-selinux-off' do
  if ['debian', 'ubuntu'].include?(os[:family]) then
    describe selinux do
      it { should be_disabled }
    end
  end
end

