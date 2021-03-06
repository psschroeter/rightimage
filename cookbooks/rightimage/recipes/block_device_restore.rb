rightscale_marker :begin
class Chef::Recipe
  include RightScale::RightImage::Helper
end
class Chef::Resource
  include RightScale::RightImage::Helper
end


# the mounted? check can't be in a not_if, it errors out Marshal.dump->node 
# when the persist flag is set because its can't serialize the Proc
if mounted?
  Chef::Log::info("Block device already mounted")
else
  block_device ri_lineage do
    cloud "ec2"
    lineage ri_lineage
    mount_point target_raw_root
    vg_data_percentage "95"
    volume_size "23"
    stripe_count "1"
    persist true

    action :primary_restore
  end
end

# Delete unneeded loopback file to save disk space.
file loopback_file(!partitioned?) do
  backup false
  action :delete
end

rightscale_marker :end
