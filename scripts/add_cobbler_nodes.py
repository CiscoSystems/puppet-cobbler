#!/usr/bin/python
""" A quick script to load up the test physical systems
into cobbler.  This should allow for faster build times, even
with some manual intervention
"""

"""
sudo cobbler system add --name="cloud-os-09.cisco.com" 
						--mac-address="00:25:B5:00:00:03" 
						--ip-address="192.168.100.9" 
						--dns-name="cloud-os-09.cisco.com" 
						--hostname="cloud-os-09.cisco.com" 

						--profile="precise-x86_64-juju" 
						--kopts=" partman-auto/disk=/dev/sdc" 
						--netboot-enabled=Y 
						
						--power-address="192.168.6.15" 
						--power-type="ucs" 
						--power-user="admin" 
						--power-pass="Node!12345" 
						--power-id="SDU-OS-5"
"""
import yaml
import xmlrpclib

server = xmlrpclib.Server("http://localhost/cobbler_api")
cobbler_user = "cobbler"
cobbler_pass = ""
cobbler_def_profile = "precise-x86_64-auto"
cobbler_kopts = " partman-auto/disk=/dev/sdc"
cobbler_netboot = "Y"

token = server.login(cobbler_user,cobbler_pass)

ip_def_gw = 1
ip_addr_base_network = "192.168.100."
ip_dns = "192.168.26.186"
ip_dns_search = "sdu.lab"

power_user = "admin"
power_pass = "Node!12345"
ucs_power_org = "NODE"
#power_type = "ucs"
#power_addr = "192.168.6.15"


system_macs = yaml.load(open("macs.yaml"))


for system in system_macs:
	dns_name = system.lower() + "." + ip_dns_search
	sys_id= server.new_system(token)
	server.modify_system(sys_id,"name",dns_name,token)
	server.modify_system(sys_id,"hostname",dns_name,token)
	server.modify_system(sys_id,"modify_interface", {
		"macaddress-eth0"	: system_macs[system]["mac"],
		"ipaddress-eth0"	: system_macs[system]["ip"],
		"dnsname-eth0"		: dns_name, 
	},token)
	server.modify_system(sys_id,"profile",cobbler_def_profile,token)
	server.modify_system(sys_id,"kernel_options",cobbler_kopts,token)
	server.modify_system(sys_id,"netboot_enabled",cobbler_netboot,token)
	if system_macs[system]["power_type"] == 'ipmi':
		server.modify_system(sys_id,"power_type","ipmitool",token)
		server.modify_system(sys_id,"power_address",system_macs[system]["power_ip"],token)
	if system_macs[system]["power_type"] == 'ucs':
		server.modify_system(sys_id,"power_type","ucs",token)
		server.modify_system(sys_id,"power_address",system_macs[system]["power_ip"],token)
	server.modify_system(sys_id,"power_user",power_user,token)
	server.modify_system(sys_id,"power_pass",power_pass,token)
	server.modify_system(sys_id,"power_id",system,token)
	server.save_system(sys_id,token)

server.sync(token)

