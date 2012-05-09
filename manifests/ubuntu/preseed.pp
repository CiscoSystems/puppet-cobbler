define cobbler::ubuntu::preseed($packages = '',
                                $early_command = 'true', # runs before install
                                $late_command = 'true', # runs after install, before PXE is disabled
                                $proxy = '',
				$stop_pxe = true, # true turns off further PXE boots; machine will boot from HD on next reboot
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
