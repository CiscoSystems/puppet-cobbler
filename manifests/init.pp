# = Class: cobbler
#
# This class installs and configures Cobbler, the PXE boot install engine.  Currently 
# it only supports Ubuntu deployments, but can be extended to support Debian, and RedHat
# style systems.
# 
# == Local Parameters:
# - $node_subnet	The subnet for the PXE server, only one subnet is supported
# - $node_netmask 	The netmask for the subnet
# - $node_gateway		The default gateway for the subnet
# - $node_dns				The DNS server IP address (currently cobbler doesn't manage DNS)
# - $domain_name		The domain name relative to the new nodes being deployed
# - $ip							The IP address that the cobbler server will use as the "next hop"
# - $dhcp_ip_low		The low range of default DHCP address
# - $dhcp_ip_high		The high range of default DHCP addresses
# - $dns_service		Manage DNS? defaults to no. optiosn: manage_dnsmasq, manage_bind
# - $dhcp_service		Manage DHCP? defaults to no. options: manage_dnsmasq, manage_isc
# - $ntp_server                 NTP server if the default (ntp.ubuntu.com) isn't reachable
# - $proxy = ''			If a proxy is required to get to the internet for updates, define it
# - $password_crypted = "x"  - The default 'localadmin' user password, MD5 encrypted. 
# 
# == Requires:
# 
# Nothing.
# 
# == Sample Usage:
# 
# Note: the password below is "ubuntu"
# 
# node /cobbler\.example\.com/ {
#  class { cobbler:
#   node_subnet => "192.168.1.0",
#   node_netmask => "255.255.255.0",
#   node_gateway => "192.168.1.1",
#   node_dns => "192.168.1.1",
#   ip => '192.168.1.254',
#   domain_name => "example.com",
#   proxy => "http://192.168.1.1:3142/",
#   password_crypted => '$6$UfgWxrIv$k4KfzAEMqMg.fppmSOTd0usI4j6gfjs0962.JXsoJRWa5wMz8yQk4SfInn4.WZ3L/MCt5u.62tHDGB36EhiKF1',
#  }
#
class cobbler(
	$node_subnet,
	$node_netmask,
	$node_gateway,
	$node_dns,
	$domain_name,
	$ip,
	$dhcp_ip_low = undef,
	$dhcp_ip_high = undef,
	$proxy = '',
	$ucs_org = '',
	$dns_service = undef,
	$dhcp_service = undef,
        $ntp_server = undef,
	$password_crypted = "x")
{

	package { cobbler:
		ensure => present }

      if $dns_service == $dhcp_service {
          package { $dns_service:	
		ensure => present }
      } else {
        if $dns_service != undef {
	   package { $dns_service:
              ensure => present }
        }
        if $dhcp_service != undef {
            package { $dhcp_service:
              ensure => present }
        }
      }

	package { "tftpd-hpa":
		ensure => present }

	file { "/etc/cobbler":
		ensure => directory
	}

	file { "/etc/cobbler/settings":
		content => template('cobbler/settings.erb'),
		require => File["/etc/cobbler"],
		notify => Exec["restart-cobbler"],
	}

	file { "/etc/cobbler/modules.conf":
		content => template('cobbler/modules.conf.erb'),
		require => File["/etc/cobbler"],
		notify => Exec["restart-cobbler"],
	}

	file { "/etc/cobbler/dhcp.template":
		content => template('cobbler/dhcp.template.erb'),
		require => File["/etc/cobbler"],
		notify => Exec["restart-cobbler"],
	}
	
	file { "/etc/cobbler/dnsmasq.template":
		content => template('cobbler/dnsmasq.template.erb'),
		require => File["/etc/cobbler"],
		notify => Exec["restart-cobbler"],
	}
	
	file { "/etc/cobbler/power":
		ensure => directory,
		require => File["/etc/cobbler"],
	}

	file { "/etc/cobbler/power/power_ucs.template":
		content => template('cobbler/power_ucs_domain.erb'),
		require => File["/etc/cobbler/power"],
	}

	exec { "restart-cobbler":
		command => "/usr/sbin/service cobbler restart",
		refreshonly => true,
		require => Package[cobbler],
	}

	exec { "cobbler-sync":
		command => "/usr/bin/cobbler sync",
        provider => shell,
		refreshonly => true,
		before => Exec[restart-cobbler],
		require => Package[cobbler],
	}

}
