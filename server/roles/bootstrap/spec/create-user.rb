#  _                 _       _                     __                   
# | |__   ___   ___ | |_ ___| |_ _ __ __ _ _ __   / /__ _ __   ___  ___ 
# | '_ \ / _ \ / _ \| __/ __| __| '__/ _` | '_ \ / / __| '_ \ / _ \/ __|
# | |_) | (_) | (_) | |_\__ \ |_| | | (_| | |_) / /\__ \ |_) |  __/ (__ 
# |_.__/ \___/ \___/ \__|___/\__|_|  \__,_| .__/_/ |___/ .__/ \___|\___|
#                                         |_|          |_|              
# create-user
unixusers = %w|admin|

unixusers.each do |v|
  # Test each user
  describe user(v) do
    it { should exist }
    it { should have_home_directory('/home/' + v ) }
  end
end

