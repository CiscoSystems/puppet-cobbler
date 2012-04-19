Cobbler installer via puppet
============================

Install cobbler along with the isc.dhcp server (but not DNS).

To use, copy into your /etc/puppet/modules directory, and add something like the following to your /etc/pupppet/manifests/site.pp:

	node /cobbler\.example\.com/ {
		# Install and configure Cobbler
		class { cobbler:
			node_subnet => "192.168.1.0",
			node_netmask => "255.255.255.0",
			node_gateway => "192.168.1.1",
			node_dns => "192.168.1.1",
			domain_name => "example.com",
			proxy => "http://192.168.1.1:3142/",
			password_crypted => 'MD5CryptedPasswordHash',
		}

		# Import Ubuntu Precise image
		cobbler::ubuntu { precise: }
	}
