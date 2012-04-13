class cobbler(
	$node_subnet,
	$node_netmask,
	$node_gateway,
	$node_dns,
	$proxy = '',
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

	file { "/etc/cobbler/cisco-preseed":
		content => template('cobbler/preseed.erb'),
		require => File["/etc/cobbler"],
	}

	file { "/etc/cobbler/dhcp.template":
		content => template('cobbler/dhcp.template.erb'),
		require => File["/etc/cobbler"],
		notify => Exec["restart-cobbler"],
	}

	exec { "restart-cobbler":
		command => "/usr/sbin/service cobbler restart",
		refreshonly => true,
		require => Package[cobbler],
	}
}
