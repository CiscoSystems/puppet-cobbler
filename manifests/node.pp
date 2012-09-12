# Definition: cobbler::node
#
# This class installs a node into the cobbler system.  Cobbler needs to be included
# in a toplevel node definition for this to be useful.
#
# Parameters:
# - $mac Mac address of the eth0 interface
# - $profile Cobbler profile to assign
# - $ip IP address to assign to eth0
# - $domain Domain name to add to the resource name
# - $preseed Cobbler/Ubuntu preseed/kickstart file for the node
# - $power_address = "" Power management address for the node
# - $power_type = "" 		Power management type (impitools, ucs, etc.)
# - $power_user = ""    Power management username
# - $power_password = ""  Power management password
# - $power_id = ""     Power management port-id/name
# - $boot_disk = '/dev/sda'  Default Root disk name
# - $serial = False (true for serial console)
# - $add_hosts_entry = true, Create a cobbler local hosts entry (also useful for DNS)
# - $extra_host_aliases = [] Any additional aliases to add to the host entry
#
# Example:
# cobbler::node { "sdu-os-1":
#  mac => "00:25:b5:00:00:08",
#  profile => "precise-x86_64-auto",
#  ip => "192.168.100.101",
#  domain => "sdu.lab",
#  preseed => "/etc/cobbler/cisco-preseed",
#  power_address => "192.168.26.15:org-SDU",
#  power_type => "ucs",
#  power_user => "admin",
#  power_password => "Sdu!12345",
#  power_id => "SDU-OS-1",
#  boot_disk => "/dev/sdc",
#  add_hosts_entry => true,
#  extra_host_alises => ["nova", "keystone", "glance", "horizon"]
# }
#
define cobbler::node(
	$mac,
	$profile,
	$ip,
	$domain,
	$preseed,
	$power_address = "",
	$power_type = "",
	$power_user = "",
	$power_password = "",
	$power_id = "",
	$boot_disk = '/dev/sda',
	$add_hosts_entry = true,
	$log_host = '',
	$serial = false,
	$extra_host_aliases = [])
{
	if($cobbler::node_gateway) {
	    $gateway_opt = "netcfg/get_gateway=${cobbler::node_gateway}"
	} else {
	    # There is a bug in Ubuntu's netcfg (as of 2012-09) that
	    # prevents no-gateway setups working.  This is a workaround
	    # - we remove the gateway in post-install.
	    # (no_default_route is conveniently spare)
	    $gateway_opt = "netcfg/get_gateway=${cobbler::ip} netcfg/no_default_route=true"
	}
        if($log_host) {
            $log_opt = "log_host=${log_host} BOOT_DEBUG=2"
        } else {
            $log_opt = ""
        }
        if($serial) {
            $serial_opt = "console=ttyS0,9600"
        } else {
            $serial_opt = ""
        }
	$net_settings="priority=critical netcfg/disable_autoconfig=true netcfg/dhcp_failed=true netcfg/dhcp_options=\"'\"'\"'Configure network manually'\"'\"'\" netcfg/get_nameservers=${cobbler::node_dns} netcfg/get_ipaddress=${ip} netcfg/get_netmask=${cobbler::node_netmask} ${gateway_opt} netcfg/confirm_static=true"
                    #cobbler system \\\${action} --name='${name}' --mac-address='${mac}' --profile='${profile}' --ip-address=${ip} --dns-name='${name}.${domain}' --hostname='${name}.${domain}' --kickstart='${preseed}' --kopts='netcfg/disable_autoconfig=true netcfg/dhcp_failed=true netcfg/dhcp_options=\"'\"'\"'Configure network manually'\"'\"'\" netcfg/get_nameservers=${cobbler::node_dns} netcfg/get_ipaddress=${ip} netcfg/get_netmask=${cobbler::node_netmask} ${gateway_opt} netcfg/confirm_static=true partman-auto/disk=${boot_disk} ${log_opt}' --power-user=${power_user} --power-address=${power_address} --power-pass=${power_password} --power-id=${power_id} --power-type=${power_type} \\\${extra_opts}",
	exec { "cobbler-add-node-${name}":
		command => "if cobbler system list | grep ${name};
                    then
                        action=edit;
                        extra_opts='';
                    else
                        action=add;
                        extra_opts=--netboot-enabled=true;
                    fi;
                    cobbler system \\\${action} --name='${name}' --mac-address='${mac}' --profile='${profile}' --ip-address=${ip} --dns-name='${name}.${domain}' --hostname='${name}.${domain}' --kickstart='${preseed}' --kopts='$net_settings partman-auto/disk=${boot_disk} ${log_opt} ${serial_opt}' --power-user=${power_user} --power-address=${power_address} --power-pass=${power_password} --power-id=${power_id} --power-type=${power_type} \\\${extra_opts}",
		provider => shell,
		path => "/usr/bin:/bin",
		require => Package[cobbler],
		notify => Exec["cobbler-sync"],
		before => Exec["restart-cobbler"]
	}

    if ( $add_hosts_entry ) {
        host { "${name}.${domain}":
            ip => "${ip}",
            host_aliases => flatten(["${name}", $extra_host_aliases])
        }
    }
}
