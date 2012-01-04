class Chef::Resource::RightimageUpload
  include RightScale::RightImage::Helper
end

class Chef::Resource::RubyBlock
  include RightScale::RightImage::Helper
end


["libxml2-devel", "libxslt-devel"].each do |p| 
  r = package p do 
    action :nothing 
  end
  r.run_action(:install)
end

r = gem_package "nokogiri" do
  gem_binary "/opt/rightscale/sandbox/bin/gem"
  version "1.4.3.1"
  action :nothing
end
r.run_action(:install)
Gem.clear_paths

rightimage_upload "Upload cloudstack image" do
  provider "rightimage_upload_vmops"
  hypervisor node[:rightimage][:virtual_environment]
  file_ext image_file_ext
  action :upload
end

