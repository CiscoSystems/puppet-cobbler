# Definition: cobbler::node
#
# This class installs a node into the cobbler system.  Cobbler needs to be included
# in a toplevel node definition for this to be useful.
#
# == Parameters:
# [mac]
#   Mac address of the eth0 interface
# [profile]
#   Cobbler profile to assign
# [ip]
#   IP address to assign to eth0
# [domain]
#   Domain name to add to the resource name
# [preseed]
#   Cobbler/Ubuntu preseed/kickstart node name
# [power_address]
#   Power management address for the node
# [power_type]
#   Power management type (impitools, ucs, etc.)
# [power_user]
#   Power management username
# [power_password]
#   Power management password
# [power_id]
#   Power management port-id/name
# [boot_disk]
#   Default Root disk name
# [serial]
#   (true for serial console)
# [add_hosts_entry]
#   Create a cobbler local hosts entry (also useful for DNS)
# [extra_host_aliases]
#   Any additional aliases to add to the host entry
#
# == Example
#   cobbler::node { "sdu-os-1":
#     mac => "00:25:b5:00:00:08",
#     profile => "precise-x86_64-auto",
#     ip => "192.168.100.101",
#     domain => "sdu.lab",
#     preseed => "cisco-preseed",
#     power_address => "192.168.26.15:org-SDU",
#     power_type => "ucs",
#     power_user => "admin",
#     power_password => "Sdu!12345",
#     power_id => "SDU-OS-1",
#     boot_disk => "/dev/sdc",
#     add_hosts_entry => true,
#     extra_host_alises => ["nova", "keystone", "glance", "horizon"]
#   }
#
define cobbler::node(
  $mac,
  $profile,
  $ip,
  $domain,
  # AFAICT,this doesn't do anything, but it was left here for backward compat
  $node_type = "",
  $preseed,
  $power_address = "",
  $power_type = "",
  $power_user = "",
  $power_password = "",
  $power_id = "",
  $boot_disk = '/dev/sda',
  $add_hosts_entry = true,
  $log_host = '',
  $extra_host_aliases = []
) {

  if $node_type != '' {
    warning("You have set a node_type for cobbler::node, this paramter does nothing and will be deprecated")
  }

  $preseed_file= '/etc/cobbler/preseeds/$preseed'

  # set up default kernel options
  $kernel_options = {
    'netcfg/disable_autoconfig' => 'true',
    'netcfg/dhcp_failed'        => 'true',
    'netcfg/dhcp_options'       => "'Configure network manually'",
    'netcfg/get_nameservers'    => $cobbler::node_dns,
    'netcfg/get_ipaddress'      => $ip,
    'netcfg/get_netmask'        => $cobbler::node_netmask,
    'netcfg/confirm_static'     => 'true',
    'partman-auto/disk'         => $boot_disk
  }

  if($cobbler::node_gateway) {
    $kernel_options['netcfg/get_gateway'] = $cobbler::node_gateway
  } else {
    # There is a bug in Ubuntu's netcfg (as of 2012-09) that
    # prevents no-gateway setups working.  This is a workaround
    # - we remove the gateway in post-install.
    # (no_default_route is conveniently spare)
    $kernel_options['netcfg/get_gateway']      = $cobbler::ip
    $kernel_options['netcfg/no_default_route'] = 'true'
  }
  
  if($log_host) {
    $kernel_options['log_host']   = $log_host
    $kernel_options['BOOT_DEBUG'] = '2'
  }
  
  if($serial) {
    $kernel_options['console'] = 'ttyS0,9600'
  } 

  cobblersystem { $name:
    ensure         => present,
    # should this alwasy be true?
    hostname       => "${name}.${domain}",
    netboot        => true,
    profile        => $profile,    
    kickstart      => $preseed_file,
    power_type     => $power_type,
    power_user     => $power_user,
    power_id       => $power_id,
    power_address  => $power_address,
    power_password => $power_password,
    kernel_options => $kernel_options,
    interfaces => { 'eth0' => {
                    mac_address => $mac,
                    static      => false,
                    management  => false,
                    ip_address  => $ip,
                    netmask     => $cobbler::node_netmask,
                    dns_name    => "${name}.${domain}"
                  },    
    },
    notify         => Exec['cobbler-sync'],
  }

  if ( $add_hosts_entry ) {
    host { "${name}.${domain}":
      ip => $ip,
      host_aliases => flatten([$name, $extra_host_aliases])
    }
  }
}
