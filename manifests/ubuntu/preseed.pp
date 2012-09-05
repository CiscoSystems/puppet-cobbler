# --Cobbler preseed file define for Ubuntu
#
#
# - $no_default_route Do not install a default route when bringing up the network
#
define cobbler::ubuntu::preseed(
  $packages = '',
  $early_command = false, # runs before install
  $late_command = false, # runs after install, before PXE is disabled
  $proxy = '',
  $ntp_server = undef,
  $password_crypted = '',
  $expert_disk = false,
  $no_default_route = false,
  $diskpart = [],
  $boot_disk = undef) {

    if ( ! defined(File['/etc/cobbler/preseeds'])) {
        file { "/etc/cobbler/preseeds":
            ensure => directory
        }
    }

    file { "/etc/cobbler/preseeds/${name}":
        content => template("cobbler/preseed.erb")
    }
}
