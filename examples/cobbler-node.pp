# = Cobbler and Puppet for nodes
#
# == Example
#
# add this to your site.pp file:
# import "cobbler-node"
# And an NTP nodes class that can be used in other descriptions.  This updates the 
# even the proxy address
# If you are not using UCS blades, don't worry about the org-EXAMPLE, and if you are
# and aren't using an organization domain, just leave the value as ""
# An example MD5 crypted password is ubuntu: .DO/SOAPxKem.dRDx6UbyMd0HM6RQl1fxHYxPRuYFrRB04OcbO7c1
# which is used by the cobbler preseed file to set up the default admin user.
node /cobbler/ {

# set up the cobbler instance on the "cobbler" node
 class { cobbler:
  node_subnet => "192.168.100.0",	# this is the IP domain
  node_netmask => "255.255.255.0",	# that the DHCP service
  node_gateway => "192.168.100.1",	# will use for cobbled
  node_dns => "192.168.100.1",		# nodes
  ip => '192.168.100.254',		# This is the "next-router" for PXE
  domain_name => "sdu.lab",		# This is the domain that matches DHCP
  proxy => "http://192.168.26.163:3142/",	# This  is the APT proxy (Debian specific)
  password_crypted => '$6$UfgWxrIv$k4KfzAEMqMg.fppmSOTd0usI4j6gfjs0962.JXsoJRWa5wMz8yQk4SfInn4.WZ3L/MCt5u.62tHDGB36EhiKF1',	# Default user (localadmin in preboot.erb) password.  "ubuntu" by default.
 }

 cobbler::ubuntu { "precise":	# Load via ubuntu-orchestra-import-isos "name"
 }
 
 cobbler::ubuntu::preseed { "cisco-preseed":
  packages => "openssh-server lvm2 ntp puppet",
  late_command => "
sed -e "/logdir/ a pluginsync=true" -i /target/etc/puppet/puppet.conf ; \
sed -e "s/START=no/START=yes/" -i /target/etc/default/puppet ; \
echo "server ${http_server} iburst" > /target/etc/ntp.conf i ; \
echo "auto eth1" >> /target/etc/network/interfaces ; \
echo "iface eth1 inet loopback" >> /target/etc/network/interfaces ; \
",
  proxy => "http://128.107.252.163:3142/",
  password_crypted => '$6$5NP1.NbW$WOXi0W1eXf9GOc0uThT5pBNZHqDH9JNczVjt9nzFsH7IkJdkUpLeuvBU.Zs9x3P6LBGKQh6b0zuR8XSlmcuGn.',
  expert_disk => true,
  diskpart => ['/dev/sda','/dev/sdb','/dev/sdc','/dev/sdd'],
  boot_disk => '/dev/sdc',
 }


# cobbler node definitions
cobbler::node { "sdu-os-1":
 mac => "00:25:b5:00:00:08",
 profile => "precise-x86_64-auto",
 ip => "192.168.100.101",
 domain => "sdu.lab",
 preseed => "/etc/cobbler/preseeds/cisco-preseed",
 power_address => "192.168.26.15:org-SDU",
 power_type => "ucs",
 power_user => "admin",
 power_password => "Sdu!12345",
 power_id => "SDU-OS-1",
 root_disk => "/dev/sdc",
 add_hosts_entry => true,
 extra_host_aliases => ["nova","keystone","glance","horizon"],
 }

cobbler::node { "sdu-os-2":
 mac => "00:25:b5:00:00:16",
 profile => "precise-x86_64-auto",
 ip => "192.168.100.102",
 domain => "sdu.lab",
 preseed => "/etc/cobbler/preseeds/cisco-preseed",
 power_address => "192.168.26.15:org-SDU",
 power_type => "ucs",
 power_user => "admin",
 power_password => "Sdu!12345",
 power_id => "SDU-OS-2",
 root_disk => "/dev/sdc",
 }

cobbler::node { "sdu-os-3":
 mac => "00:25:b5:00:00:05",
 profile => "precise-x86_64-auto",
 ip => "192.168.100.103",
 domain => "sdu.lab",
 preseed => "/etc/cobbler/preseeds/cisco-preseed",
 power_address => "192.168.26.15:org-SDU",
 power_type => "ucs",
 power_user => "admin",
 power_password => "Sdu!12345",
 power_id => "SDU-OS-3",
 root_disk => "/dev/sdc",
 }

cobbler::node { "sdu-os-4":
 mac => "00:25:b5:00:00:04",
 profile => "precise-x86_64-auto",
 ip => "192.168.100.104",
 domain => "sdu.lab",
 preseed => "/etc/cobbler/preseeds/cisco-preseed",
 power_address => "192.168.26.15:org-SDU",
 power_type => "ucs",
 power_user => "admin",
 power_password => "Sdu!12345",
 power_id => "SDU-OS-4",
 root_disk => "/dev/sdc",
 }

cobbler::node { "sdu-os-5":
 mac => "00:25:b5:00:00:03",
 profile => "precise-x86_64-auto",
 ip => "192.168.100.105",
 domain => "sdu.lab",
 preseed => "/etc/cobbler/preseeds/cisco-preseed",
 power_address => "192.168.26.15:org-SDU",
 power_type => "ucs",
 power_user => "admin",
 power_password => "Sdu!12345",
 power_id => "SDU-OS-5",
 root_disk => "/dev/sdc",
 }

#cobbler::node { "sdu-os-6":
# mac => "00:25:b5:00:00:02",
# profile => "precise-x86_64-auto",
# ip => "192.168.100.106",
# domain => "sdu.lab",
# preseed => "/etc/cobbler/preseeds/cisco-preseed",
# power_address => "192.168.26.15:org-SDU",
# power_type => "ucs",
# power_user => "admin",
# power_password => "Sdu!12345",
# power_id => "SDU-OS-6",
# root_disk => "/dev/sdc",
# }

cobbler::node { "sdu-os-7":
 mac => "00:25:b5:00:00:01",
 profile => "precise-x86_64-auto",
 ip => "192.168.100.107",
 domain => "sdu.lab",
 preseed => "/etc/cobbler/preseeds/cisco-preseed",
 power_address => "192.168.26.15:org-SDU",
 power_type => "ucs",
 power_user => "admin",
 power_password => "Sdu!12345",
 power_id => "SDU-OS-7",
 root_disk => "/dev/sdc",
 }
}
