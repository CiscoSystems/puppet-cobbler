define cobbler::node(
  $mac,
  $profile,
  $ip,
  $domain,
    $preseed)
{
  exec { "cobbler-add-node-${name}":
    command => "if cobbler system list | grep ${name};
                    then
                        action=edit;
                        extra_opts='';
                    else
                        action=add;
                        extra_opts=--netboot-enabled=true;
                    fi;
                    cobbler system \\\${action} --name='${name}' --mac-address='${mac}' --profile='${profile}' --ip-address=${ip} --dns-name='${name}.${domain}' --hostname='${name}.${domain}' --kickstart='${preseed}' --kopts='netcfg/disable_autoconfig=true netcfg/dhcp_failed=true netcfg/dhcp_options=\"'\"'\"'Configure network manually'\"'\"'\" netcfg/get_nameservers=${cobbler::node_dns} netcfg/get_ipaddress=${ip} netcfg/get_netmask=${cobbler::node_netmask} netcfg/get_gateway=${cobbler::node_gateway} netcfg/confirm_static=true' \\\${extra_opts}",
    provider => shell,
    path => "/usr/bin:/bin",
    require => Package[cobbler],
    notify => Exec["cobbler-sync"],
    before => Exec["restart-cobbler"]
  }
}
