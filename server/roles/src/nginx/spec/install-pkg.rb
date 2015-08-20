#              _                __                   
#  _ __   __ _(_)_ __ __  __   / /__ _ __   ___  ___ 
# | '_ \ / _` | | '_ \\ \/ /  / / __| '_ \ / _ \/ __|
# | | | | (_| | | | | |>  <  / /\__ \ |_) |  __/ (__ 
# |_| |_|\__, |_|_| |_/_/\_\/_/ |___/ .__/ \___|\___|
#        |___/                      |_|              
describe 'src/nginx/install-pkg' do
  installpkg = {
    :redhat => %w[pcre pcre-devel],
    :debian => %w[libpcre3 libpcre3-dev],
  }

  installpkg[ os[:family].to_sym ].each do |e|
    describe package(e) do
      it { should be_installed }
    end
  end
end

