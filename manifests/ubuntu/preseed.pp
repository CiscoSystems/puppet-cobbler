define cobbler::ubuntu::preseed($packages = '',
                                $late_command = '',
                                $proxy = '',
                                $password_crypted = '') {

    if ( ! defined(File['/etc/cobbler/preseeds'])) {
        file { "/etc/cobbler/preseeds":
            ensure => directory
        }
    }

    file { "/etc/cobbler/preseeds/${name}":
        content => template("cobbler/preseed.erb")
    }
}
