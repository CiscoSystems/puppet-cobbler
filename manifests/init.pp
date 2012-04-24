class cobbler(
	$node_subnet,
	$node_netmask,
	$node_gateway,
	$node_dns,
	$domain_name,
	$ip,
	$proxy = '',
	$ucs_org = '',
	$password_crypted = "x")
{
	package { cobbler:
		ensure => present }

	package { "isc-dhcp-server":	
		ensure => present }

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

	file { "/etc/cobbler/dhcp.template":
		content => template('cobbler/dhcp.template.erb'),
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
		command => "/usr/bin/cobbler sync > /tmp/w.$$ 2>&1",
        provider => shell,
		refreshonly => true,
		before => Exec[restart-cobbler],
		require => Package[cobbler],
	}

}
