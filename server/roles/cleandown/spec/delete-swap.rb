#       _                    _                        __                   
#   ___| | ___  __ _ _ __ __| | _____      ___ __    / /__ _ __   ___  ___ 
#  / __| |/ _ \/ _` | '__/ _` |/ _ \ \ /\ / / '_ \  / / __| '_ \ / _ \/ __|
# | (__| |  __/ (_| | | | (_| | (_) \ V  V /| | | |/ /\__ \ |_) |  __/ (__ 
#  \___|_|\___|\__,_|_|  \__,_|\___/ \_/\_/ |_| |_/_/ |___/ .__/ \___|\___|
#                                                         |_|              
xdescribe 'cleardown/delete-swap' do
  ansiblevars = MakeServer::Ansible.load_variables
  describe file( ansiblevars['all']['swapfile'] ) do
    it { should_not exist }
  end
end
