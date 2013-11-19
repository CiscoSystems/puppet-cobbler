#!/usr/bin/env python
import os
import sys
import yaml
import argparse
import xmlrpclib


token = None
server=None

def cobbler_connect(cobbler_user,cobbler_pass):
    global token,server
    try:
        server = xmlrpclib.Server("http://localhost/cobbler_api")
        token = server.login(cobbler_user,cobbler_pass) 
        return True
    except:
        return False
        
# perform cobbler sync
def cobbler_sync():
    global token,server
    server.sync(token)

# send cobbler system update via xmlrpc        
def send_system_update(node_name, node_dict):
    global token,server
    
    try:  
        sid = server.get_system_handle(node_name,token)
    except:
        sid = server.new_system(token)
        server.modify_system(sid,'name',node_name,token)

    for k,v in node_dict.items():
        if not type(v) is dict:
            server.modify_system(sid,k,v,token)
    server.save_system(sid,token)
    
# send interface update via xml-rpc    
def send_interface_update(node_name, interface_dict):
    global token,server
    sid = server.get_system_handle(node_name,token)
    print interface_dict
    server.modify_system(sid,'modify_interface',interface_dict,token)
    server.save_system(sid,token)
    
# update profile and distro    
def update_profile(profile_dict):
    global token,server
    distname = profile_dict['name']
    distarch = profile_dict['arch']
    command = '/usr/bin/cobbler-ubuntu-import'
    pid = None
    try:
        pid = server.get_profile_handle('%s-%s' % (distname,distarch),token)
        command = command + ' -u %s-%s' % (distname,distarch)
    except:
        command = command + ' %s-%s' % (distname,distarch)
   
    code = os.system(command)

    pid = server.get_profile_handle('%s-%s' % (distname,distarch),token)
    for k,v in profile_dict.items():
        if not type(v) is dict:
            server.modify_profile(pid,k,v,token)
    server.save_profile(pid,token)
    
    return code

# update node properties
def update_node(node_name, node_dict, global_dict):

    #merge in the globals
    node_dict.update(global_dict)

    #node parameter substitution    
    for sk,sv in node_dict.items():
        for rk,rv in node_dict.items():
            if not type(sv) is dict:
                if not type(rv) is dict:
                    node_dict[sk] = node_dict[sk].replace('{$' + rk + '}',rv)
    
    #interface parameter substitution          
    for sk,sv in node_dict.items():
        ifaces = node_dict.get('interfaces',{})
        for ik,iv in ifaces.items():
            for pk,pv in ifaces[ik].items():
                if not type(node_dict[sk]) is dict:
                    node_dict[sk] = node_dict[sk].replace('{$' + ik + '_' + pk + '}',pv)

    
    return send_system_update(node_name,node_dict)             


# update interfaces for a cobbler node    
def update_node_interfaces(node_name, interfaces_dict):

    for ik,iv in interfaces_dict.items():    
        props = {}
        for pk,pv in iv.items():
            props[pk.replace('-','') + '-' + ik ] = pv
        send_interface_update(node_name,props)               
 
def main():

    parser = argparse.ArgumentParser()
    parser.add_argument("-y", "--yaml", dest="yaml", 
                        metavar="YAML_FILE", type=str,
                        help="cobbler yaml file", default='/etc/puppet/data/cobbler.yaml')
    parser.add_argument("-u", "--user", dest="user", 
                        metavar="COBBLER_USER", type=str,
                        help="cobbler user", default='cobbler')
    parser.add_argument("-p", "--password", dest="password", 
                        metavar="COBBLER_PASS", type=str,
                        help="cobbler password", default='')  
                                                              
    params = parser.parse_args()

  
    
    if not os.path.exists(params.yaml):
        parser.error("Yaml file %s does not exist." % (params.yaml))
        sys.exit(1)
         
    if not cobbler_connect(params.user,params.password):
        print("unable to connect to cobbler on localhost using %s %s" % (params.user,paarams.password))
        sys.exit(1)       
            
    with open(params.yaml, 'r') as file:
        nodes = yaml.load(file.read())

    for name in nodes:
      if name == 'profile':
          profile = nodes[name]
          update_profile(nodes['profile'])

      if name == 'node-global':
          node_globals = nodes[name]

    for name in nodes:
      if name != 'profile' and name != 'node-global':
        update_node(name,nodes[name],node_globals)
        update_node_interfaces(name, nodes[name]['interfaces'])
  
    #send cobbler sync and exit
    cobbler_sync()
    sys.exit(0)
    
if __name__ == "__main__":
    main()
