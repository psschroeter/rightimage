rightscale_marker :begin
class Chef::Recipe
  include RightScale::RightImage::Helper
end

class Chef::Resource::BlockDevice
  include RightScale::RightImage::Helper
end

block_device ri_lineage do
  cloud "ec2"
  lineage ri_lineage
  mount_point target_raw_root 
  vg_data_percentage "50"

  action :snapshot
end

block_device ri_lineage do
  cloud "ec2"
  lineage ri_lineage
  mount_point target_raw_root 
  vg_data_percentage "50"

  action :primary_backup
end
rightscale_marker :end
