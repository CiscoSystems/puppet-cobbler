#!/usr/bin/python
""" A quick script to load up the test physical systems
into cobbler.  This should allow for faster build times, even
with some manual intervention
"""

"""
A manual example:
sudo cobbler system add --name="cloud-node-10.example.com" 
						--mac-address="00:BE:AD:EE:00:03" 
						--ip-address="192.168.1.10" 
						--dns-name="cloud-node-10.example.com" 
						--hostname="cloud-node-10.example.com" 

						--profile="precise-x86_64-auto" 
						--kopts=" partman-auto/disk=/dev/sdc" 
						--netboot-enabled=Y 
						
						--power-address="192.168.0.10" 
						--power-type="ucs" 
						--power-user="admin" 
						--power-pass="power!12345" 
						--power-id="CLOUD-NODE-10"
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
ip_addr_base_client = 10
ip_addr_base_network = "192.168.1."
ip_dns = "8.8.8.8"
ip_dns_search = "example.com"

power_user = "admin"
power_pass = "power!12345"
ucs_power_org = "CLOUD-NODE"
power_type = "ucs"
power_addr = "192.168.0.10"


system_macs = yaml.load(open("macs.yaml"))


for system in system_macs:
	dns_name = system.lower() + ".example.com"
	sys_id= server.new_system(token)
	server.modify_system(sys_id,"name",dns_name,token)
	server.modify_system(sys_id,"hostname",dns_name,token)
	server.modify_system(sys_id,"modify_interface", {
		"macaddress-eth0"	: system_macs[system]["mac"],
		"ipaddress-eth0"	: ip_addr_base_network + str(ip_addr_base_client),
		"dnsname-eth0"		: dns_name, 
	},token)
	server.modify_system(sys_id,"profile",cobbler_def_profile,token)
	server.modify_system(sys_id,"kernel_options",cobbler_kopts,token)
	server.modify_system(sys_id,"netboot_enabled",cobbler_netboot,token)
	server.modify_system(sys_id,"power_type",power_type,token)
	server.modify_system(sys_id,"power_address",power_addr,token)
	server.modify_system(sys_id,"power_user",power_user,token)
	server.modify_system(sys_id,"power_pass",power_pass,token)
	server.modify_system(sys_id,"power_id",system,token)
	server.save_system(sys_id,token)
	server.sync(token)
