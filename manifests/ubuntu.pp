# = Definition: cobbler::ubuntu
#
# Add the ubuntu cobbler boot iso(s) for the defined distributions
#
# == Parameters:
#
# $arch		The Architecture of the iso to be acquired.
#
# == Variables:
#
# $name		The distribution name (e.g. precise, oneiric, etc.)
#
# == Example:
#
# cobbler::ubuntu { "precise": }
#
define cobbler::ubuntu($arch = "x86_64", $proxy = false) {
    if($proxy)  {
         $proxy_pfx="env http_proxy=${proxy} https_proxy=${proxy} "
    } else {
         $proxy_pfx=""
    }
    exec { "cobbler-import-$name-$arch":
        command => "${proxy_pfx} cobbler-ubuntu-import ${name}-${arch}",
	unless => "cobbler profile list | grep ${name}-${arch}",
        provider => shell,
        path => "/usr/bin:/bin",
        require => Package[cobbler],
    } 
    anchor{ "cobbler-profile-${name}-${arch}": 
	require => Exec["cobbler-import-$name-$arch"],
    }
    anchor { "cobbler-profile-${name}-${arch}-auto": 
	require => Exec["cobbler-import-$name-$arch"],
    }
}
