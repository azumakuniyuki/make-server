#  _                 _       _                     __                   
# | |__   ___   ___ | |_ ___| |_ _ __ __ _ _ __   / /__ _ __   ___  ___ 
# | '_ \ / _ \ / _ \| __/ __| __| '__/ _` | '_ \ / / __| '_ \ / _ \/ __|
# | |_) | (_) | (_) | |_\__ \ |_| | | (_| | |_) / /\__ \ |_) |  __/ (__ 
# |_.__/ \___/ \___/ \__|___/\__|_|  \__,_| .__/_/ |___/ .__/ \___|\___|
#                                         |_|          |_|              
describe 'bootstrap/install-pkg' do
  installpkg = {
    :redhat => %w|
      autoconf automake gcc gcc-c++ gettext gettext-devel git ncurses 
      ncurses-devel openssl-devel patch pcre pcre-devel perl-core readline
      readline-devel
      bzip2 zip zlib zlib-devel
      python-pip libselinux-python python-virtualenv
      bc wget telnet finger nkf
      |,
    :debian => %w|
      autotools-dev autoconf2.59 automake1.11 gcc gettext git libncurses-dev
      libpcre3 libpcre3-dev libreadline6-dev libreadline6 ncurses-dev openssl
      patch
      bzip2 zip zlib1g zlib1g-dev
      python-pip python-selinux python-virtualenv
      bc wget telnet finger
      |,
  }

  installpkg[ os[:family].to_sym ].each do |p|
    describe package(p) do
      it { should be_installed }
    end
  end
end
