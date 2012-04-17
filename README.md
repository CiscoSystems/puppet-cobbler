Cobbler installer via puppet
============================

Install cobbler along with the isc.dhcp server (but not DNS).
Currently this just instals the tools, not any boot images, which you will need to install via something like:

	cobbler-ubuntu-import precise-x86_64

To use, copy into your /etc/puppet/modules directory, and add something like the following to your /etc/pupppet/manifests/site.pp:

	node /cobbler\.example\.com/ {
		class { cobbler:
			node_subnet => "192.168.1.0",
			node_netmask => "255.255.255.0",
			node_gateway => "192.168.1.1",
			node_dns => "192.168.1.1",
			domain_name => "example.com",
			proxy => "http://192.168.1.1:3142/",
			password_crypted => 'MD5CryptedPasswordHash',
		}
	}

