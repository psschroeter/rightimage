maintainer       "RightScale, Inc."
maintainer_email "support@rightscale.com"
description      "A cookbook for building RightImages"
version          "1.0.0"

depends "rightimage_tester"
depends "loopback_fs"
depends "rightscale"
depends "block_device"

recipe "rightimage::default", "starts builds image automatically at boot. See 'manual_mode' input to enable." 
recipe "rightimage::build_image", "build image based on host platform"
recipe "rightimage::build_base", "build base image based on host platform"
recipe "rightimage::clean", "cleans everything" 
recipe "rightimage::rebundle", "coordinate a rebundled image build (redhat on on ec2 or rackspace)"
recipe "rightimage::base_os", "build a base image"
recipe "rightimage::enable_debug", "enables a root login on image for debugging purposes"
recipe "rightimage::rightscale_install", "installs rightscale"
recipe "rightimage::cloud_add", "configures base os image for a specific cloud"
recipe "rightimage::cloud_package", "packages RightImage for a specific cloud"
recipe "rightimage::do_create_mci", "creates RightScale MultiCloudImage (MCI) for image (only ec2 currently supported)"
recipe "rightimage::cloud_upload", "upload and register image with cloud"
recipe "rightimage::upload_image_s3", "bundle and upload private cloud image to s3 bucket for distribution/download"
recipe "rightimage::base_upload", "upload raw image to s3"
recipe "rightimage::ec2_download_bundle","Downloads bundled image from EC2 S3."
recipe "rightimage::image_tests", "run some basic tests on mounted image such as grepping for credentials"

# Block device recipes
recipe "rightimage::block_device_create", "creates, formats, and mounts a brand new EBS volume"
recipe "rightimage::block_device_backup", "creates an EBS snapshot from attached EBS volume"
recipe "rightimage::block_device_restore", "creates a new EBS volume by restoring from an EBS snapshot"
recipe "rightimage::block_device_destroy", "unmounts, and deletes an attached EBS volume"

# Loopback filesystem recipes
recipe "rightimage::loopback_create", "creates and mounts loopback file system"
recipe "rightimage::loopback_copy", "creates non-partitioned loopback fs image from a partitioned one"
recipe "rightimage::loopback_unmount", "unmounts loopback file system"
recipe "rightimage::loopback_mount", "mounts loopback file system"



#
# required
#
attribute "rightimage/root_size_gb",
  :display_name => "Root Size GB",
  :description => "Sets the size of the virtual image. Units are in GB.",
  :choice => [ "10", "4", "2" ],
  :default => "10",
  :recipes => [ "rightimage::default", "rightimage::build_base", "rightimage::build_image", "rightimage::loopback_copy", "rightimage::block_device_restore", "rightimage::loopback_create", "rightimage::cloud_add", "rightimage::cloud_upload", "rightimage::cloud_package"]

attribute "rightimage/manual_mode",
  :display_name => "Manual Mode",
  :description => "Sets the template's operation mode. Ex. 'true' = don't build at boot time.",
  :choice => [ "true", "false" ],
  :default => "true",
  :recipes => [ "rightimage::default" ]

attribute "rightimage/build_mode",
  :display_name => "Build Mode",
  :description => "Build base image, full image, or migrate existing image.",
  :required => "required",
  :choice => [ "base", "migrate", "full" ]

attribute "rightimage/platform",
  :display_name => "Guest OS Platform",
  :description => "The operating system for the virtual image.",
  :choice => [ "centos", "ubuntu", "suse", "rhel" ],
  :required => "required"
  
attribute "rightimage/platform_version",
  :display_name => "Guest OS Version",
  :description => "The OS version to build into the virtual image.",
  :choice => [ "5.4", "5.6", "5.8", "6.2", "10.04", "10.10", "12.04" ],
  :required => "required"
  
attribute "rightimage/arch",
  :display_name => "Guest OS Architecture",
  :description => "The architecture for the virtual image.",
  :choice => [ "i386", "x86_64" ],
  :required => "required"
  
attribute "rightimage/cloud",
  :display_name => "Target Cloud",
  :description => "The supported cloud for the virtual image. If unset, build a generic base image.",
  :choice => [ "ec2", "cloudstack", "eucalyptus", "openstack", "rackspace", "rackspace_managed" ],
  :required => "recommended"
  
attribute "rightimage/region",
  :display_name => "EC2 Region",
  :description => "The EC2 region in which the image will reside",
  :choice => [ "us-east", "us-west", "us-west-2", "eu-west", "ap-southeast", "ap-northeast", "sa-east" ],
  :required => true
  
attribute "rightimage/rightlink_version",
  :display_name => "RightLink Version",
  :description => "The RightLink version we are building into our image",
  :recipes => [ "rightimage::default", "rightimage::build_image", "rightimage::rightscale_rightlink", "rightimage::rebundle", "rightimage::rightscale_install"],
  :required => true
  
attribute "rightimage/image_upload_bucket",
  :display_name => "Image Upload Bucket",
  :description => "The bucket to upload the image to.",
  :required => "required",
  :recipes => [ "rightimage::base_upload", "rightimage::build_base", "rightimage::default", "rightimage::build_image" , "rightimage::upload_image_s3", "rightimage::ec2_download_bundle", "rightimage::cloud_upload", "rightimage::upload_image_s3" ]

attribute "rightimage/image_source_bucket",
  :display_name => "Image Source Bucket",
  :description => "When migrating an image, where to download the image from.",
  :required => "optional",
  :default => "rightscale-us-west-2",
  :recipes => [ "rightimage::default", "rightimage::ec2_download_bundle" ] 

attribute "rightimage/image_name",
   :display_name => "Image Name",
   :description => "The name you want to give this new image.",
   :required => "required"

attribute "rightimage/mci_name",
   :display_name => "MCI Name",
   :description => "MCI to add this image to. If empty, use Image Name",
   :default => "",
   :recipes => [ "rightimage::do_create_mci" ],
   :required => "optional"


attribute "rightimage/rebundle_base_image_id",
  :display_name => "Rebundle Base Image ID",
  :description => "Cloud specific ID for the image to start with when building a rebundle image",
  :required => "optional",
  :default => "",
  :recipes => [ "rightimage::default", "rightimage::rebundle"]

attribute "rightimage/rebundle_git_repository",
  :display_name => "Rebundle Git Repository",
  :description => "Git repository to checkout from when building a rebundle image",
  :required => "optional",
  :default => "",
  :recipes => [ "rightimage::default", "rightimage::rebundle"]

attribute "rightimage/rebundle_git_revision",
  :display_name => "Rebundle Git Revision",
  :description => "Git repository revision to checkout from when building a rebundle image",
  :required => "optional",
  :default => "",
  :recipes => [ "rightimage::default", "rightimage::rebundle"]

attribute "rightimage/debug",
  :display_name => "Development Image?",
  :description => "If set, a random root password will be set for debugging purposes. NOTE: you must include 'Dev' in the image name or the build with fail.",
  :choice => [ "true", "false" ],
  :default => "false",
  :required => "optional"

attribute "rightimage/timestamp",
  :display_name => "Build timestamp and mirror freeze date",
  :description => "Initial build date of this image.  Also doubles as the archive date from which to pull packages. Expected format is YYYYMMDDHHMM",
  :required => "recommended"

attribute "rightimage/build_number",
  :display_name => "Build number",
  :description => "Build number of this image.  Defaults to 0",
  :default => "0",
  :required => "recommended"

attribute "rightimage/hypervisor",
  :display_name => "Hypervisor",
  :description => "Which hypervisor is this image for?",
  :choice => [ "xen", "kvm", "esxi" ],
  :required => "required"

attribute "rightimage/datacenter",
  :display_name => "Datacenter ID",
  :description => "Datacenter/Zone ID.  Defaults to 1.  Use UK for rackspace UK",
  :default => "1",
  :required => "recommended"

# Optional, parameters for auto creation of mci
attribute "rest_connection/user",
  :display_name => "API User",
  :description => "RightScale API username. Ex. you@rightscale.com",
  :recipes => [ "rightimage::do_create_mci" ],
  :required => true

attribute "rest_connection/pass",
  :display_name => "API Password",
  :description => "Rightscale API password.",
  :recipes => [ "rightimage::do_create_mci" ],
  :required => true
 
attribute "rest_connection/api_url",
  :display_name => "API URL",
  :description => "The rightscale account specific api url to use.  Ex. https://my.rightscale.com/api/acct/1234 (where 1234 is your account id)",
  :recipes => [ "rightimage::do_create_mci" ],
  :required => true

attribute "rightimage/mci_name",
   :display_name => "MCI Name",
   :description => "MCI to add this image to. If empty, use Image Name",
   :default => "",
   :recipes => [ "rightimage::do_create_mci" ],
   :required => "optional"

# AWS
aws_x509_recipes = ["rightimage::cloud_upload", "rightimage::rebundle", "rightimage::default", "rightimage::ec2_download_bundle"]
aws_api_recipes = aws_x509_recipes + ["rightimage::build_base", "rightimage::build_image", "rightimage::upload_image_s3", "rightimage::base_upload", "rightimage::image_tests" ]

attribute "rightimage/ec2/image_type",
  :display_name => "EC2 Image Type",
  :description => "Type of EC2 Image cloud_upload recipe will create",
  :default => "InstanceStore",
  :recipes => ["rightimage::build_image", "rightimage::default", "rightimage::cloud_upload"],
  :choice => [ "InstanceStore", "EBS" ],
  :required => "recommended"

attribute "rightimage/aws_account_number",
  :display_name => "aws_account_number",
  :description => "aws_account_number",
  :required => "required",
  :recipes => aws_api_recipes
  
attribute "rightimage/aws_access_key_id",
  :display_name => "aws_access_key_id",
  :description => "aws_access_key_id",
  :required => "required",
  :recipes => aws_api_recipes
  
attribute "rightimage/aws_secret_access_key",
  :display_name => "aws_secret_access_key",
  :description => "aws_secret_access_key",
  :required => "required",
  :recipes => aws_api_recipes
  
attribute "rightimage/aws_509_key",
  :display_name => "aws_509_key",
  :description => "aws_509_key",
  :required => "required",
  :recipes => aws_x509_recipes
  
attribute "rightimage/aws_509_cert",
  :display_name => "aws_509_cert",
  :description => "aws_509_cert",
  :required => "required",
  :recipes => aws_x509_recipes

# Eucalyptus
attribute "rightimage/euca/user_id",
  :display_name => "Eucalyptus User ID",
  :description => "The EC2_USER_ID value defined in your eucarc credentials file. User must have admin privileges.",
  :required => "required",
  :recipes => [ "rightimage::cloud_upload" ]
  
attribute "rightimage/euca/euca_url",
  :display_name => "Eucalyptus URL",
  :description => "Base URL to your Eucalyptus Cloud Controller. Don't include port. (Ex. http://<server_ip>)",
  :required => "required",
  :recipes => [ "rightimage::cloud_upload" ]

attribute "rightimage/euca/access_key_id",
  :display_name => "Eucalyptus Access Key",
  :description => "The EC2_ACCESS_KEY value defined in your eucarc credentials file. User must have admin privileges.",
  :required => "required",
  :recipes => [ "rightimage::cloud_upload" ]

attribute "rightimage/euca/secret_access_key",
  :display_name => "Eucalyptus Secret Access Key",
  :description => "The EC2_SECRET_KEY value defined in your eucarc credentials file. User must have admin privileges.",
  :required => "required",
  :recipes => [ "rightimage::cloud_upload" ]

attribute "rightimage/euca/x509_key",
  :display_name => "Eucalyptus x509 Private Key",
  :description => "The contents of the file pointed to by the EC2_PRIVATE_KEY value defined in your eucarc credentials file.",
  :required => "required",
  :recipes => [ "rightimage::cloud_upload" ]

attribute "rightimage/euca/x509_cert",
  :display_name => "Eucalyptus x509 Certificate",
  :description => "The contents of the file pointed to by the EC2_CERT value defined in your eucarc credentials file.",
  :required => "required",
  :recipes => [ "rightimage::cloud_upload" ]

attribute "rightimage/euca/euca_cert",
  :display_name => "Eucalyptus Cloud Certificate",
  :description => "The contents of the file pointed to by the EUCALYPTUS_CERT value defined in your eucarc credentials file.",
  :required => "required",
  :recipes => [ "rightimage::cloud_upload" ]

# Openstack
attribute "rightimage/openstack/hostname",
  :display_name => "Openstack Hostname",
  :description => "Hostname of Openstack Cloud Controller.",
  :required => "optional",
  :default => "",
  :recipes => [ "rightimage::cloud_upload" ]

attribute "rightimage/openstack/user",
  :display_name => "Openstack User",
  :description => "User to access API of Openstack Cloud Controller.",
  :required => "optional",
  :default => "",
  :recipes => [ "rightimage::cloud_upload" ]

attribute "rightimage/openstack/password",
  :display_name => "Openstack Password",
  :description => "Password for user to access API of Openstack Cloud Controller.",
  :required => "optional",
  :default => "",
  :recipes => [ "rightimage::cloud_upload" ]

# CloudStack
attribute "rightimage/cloudstack/cdc_url",
  :display_name => "CloudStack API URL",
  :description => "URL to your CloudStack Cloud Controller. (Ex. http://<server_ip>:8080/client/api)",
  :required => "required",
  :recipes => [ "rightimage::cloud_upload" ]

attribute "rightimage/cloudstack/cdc_api_key",
  :display_name => "CloudStack API Key",
  :description => "CloudStack API key.",
  :required => "required",
  :recipes => [ "rightimage::cloud_upload" ]

attribute "rightimage/cloudstack/cdc_secret_key",
  :display_name => "CloudStack Secret Key",
  :description => "CloudStack secret key.",
  :required => "required",
  :recipes => [ "rightimage::cloud_upload" ]

attribute "rightimage/cloudstack/version",
  :display_name => "CloudStack Version",
  :description => "CloudStack version.",
  :required => "required",
  :choice => [ "2", "3" ],
  :recipes => [ "rightimage::cloud_upload" ]

# RackSpace
attribute "rightimage/rackspace/account",
  :display_name => "Rackspace Account ID",
  :description => "Rackspace Account ID",
  :required => "required",
  :recipes => [ "rightimage::rebundle", "rightimage::default" ]

attribute "rightimage/rackspace/api_token",
  :display_name => "Rackspace API Token",
  :description => "Rackspace API Token",
  :required => "required",
  :recipes => [ "rightimage::rebundle", "rightimage::default" ]

