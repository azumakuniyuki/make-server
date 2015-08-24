#                          __          _              __                   
#  _ __ _ __  _ __ ___    / / __ _   _| |__  _   _   / /__ _ __   ___  ___ 
# | '__| '_ \| '_ ` _ \  / / '__| | | | '_ \| | | | / / __| '_ \ / _ \/ __|
# | |  | |_) | | | | | |/ /| |  | |_| | |_) | |_| |/ /\__ \ |_) |  __/ (__ 
# |_|  | .__/|_| |_| |_/_/ |_|   \__,_|_.__/ \__, /_/ |___/ .__/ \___|\___|
#      |_|                                   |___/        |_|              
describe 'rpm/ruby/install-pkg' do
  installpkg = {
    :redhat => %w|ruby ruby-irb rubygems|,
  }

  installpkg[ os[:family].to_sym ].each do |e|
    describe package(e) do
      it { should be_installed }
    end
  end
end

