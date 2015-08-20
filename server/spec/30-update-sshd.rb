#                         __               _       _                     _         _ 
#  ___ _ __   ___  ___   / /   _ _ __   __| | __ _| |_ ___       ___ ___| |__   __| |
# / __| '_ \ / _ \/ __| / / | | | '_ \ / _` |/ _` | __/ _ \_____/ __/ __| '_ \ / _` |
# \__ \ |_) |  __/ (__ / /| |_| | |_) | (_| | (_| | ||  __/_____\__ \__ \ | | | (_| |
# |___/ .__/ \___|\___/_/  \__,_| .__/ \__,_|\__,_|\__\___|     |___/___/_| |_|\__,_|
#     |_|                       |_|                                                  
# Test code for server/30-update-sshd.yml
describe '30-update-sshd' do
  xdescribe file('/etc/ssh/sshd_config') do
    its(:content) { should match(/^PermitRootLogin no/) }
  end
end
