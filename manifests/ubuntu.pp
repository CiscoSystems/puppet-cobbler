define cobbler::ubuntu($arch = "x86_64") { 
    exec { "cobbler-import-$name":
        command => "if cobbler profile list | grep ubuntu-${name}-${arch}; then cobbler-ubuntu-import -u ${name}-${arch}; else cobbler-ubuntu-import -u ${name}-${arch}; fi",
        provider => shell,
        path => "/usr/bin:/bin",
        require => Package[cobbler],
    }
}
