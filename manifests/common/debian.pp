# File::      <tt>common/debian.pp</tt>
# Author::    S. Varrette, H. Cartiaux, V. Plugaru, S. Diehl aka. UL HPC Management Team (hpc-sysadmins@uni.lu)
# Copyright:: Copyright (c) 2016 S. Varrette, H. Cartiaux, V. Plugaru, S. Diehl aka. UL HPC Management Team
# License::   Gpl-3.0
#
# ------------------------------------------------------------------------------
# = Class: xen::debian
#
# Specialization class for Debian systems
class xen::common::debian inherits xen::common {

    # Bug fix on error: "net.bridge.bridge-nf-call-iptables" is an unknown key
    include kernel
    kernel::module { 'bridge':
        ensure => 'present'
    }

    # Disable bridge filtering
    # net.bridge.bridge-nf-call-arptables = 0
    # net.bridge.bridge-nf-call-ip6tables = 0
    # net.bridge.bridge-nf-call-iptables = 0
    # net.bridge.bridge-nf-filter-vlan-tagged = 0


    include sysctl
    sysctl::value { [
                    'net.bridge.bridge-nf-call-arptables',
                    'net.bridge.bridge-nf-call-ip6tables',
                    'net.bridge.bridge-nf-call-iptables',
                    'net.bridge.bridge-nf-filter-vlan-tagged'
                    ]:
                        ensure  => $xen::ensure,
                        value   => '0',
                        require => Kernel::Module['bridge']
    }

    # Debian Squeeze: patch the network script!
    if ($::lsbdistid == 'Debian') and ( $::lsbdistcodename == 'squeeze' ) {
        $patchfile = '/tmp/network-bridge.patch'
        file { $patchfile:
            ensure => 'file',
            source => 'puppet:///modules/xen/squeeze-network-bridge.patch',
            owner  => 'root',
            group  => 'root',
            mode   => '0644'
        }

        exec { 'patch Xen network-brige':
            command => "patch -p0 -i ${patchfile}",
            path    => '/usr/bin:/usr/sbin:/bin',
            user    => 'root',
            onlyif  => "grep '[ -n \"${xen::gateway}\" ] && ip route add default via ${xen::gateway}' ${xen::params::scriptsdir}/network-bridge",
            require => File[$patchfile]
        }
    }

    # Debian Wheezy: patch the network script!
    if ($::lsbdistid == 'Debian') and ( $::lsbdistcodename == 'wheezy' ) {
        $patchfile = '/tmp/network-bridge.patch'
        file { $patchfile:
            ensure => 'file',
            source => 'puppet:///modules/xen/wheezy-network-bridge.patch',
            owner  => 'root',
            group  => 'root',
            mode   => '0644'
        }

        exec { 'patch Xen network-brige':
            command => "patch -p0 -i ${patchfile}",
            path    => '/usr/bin:/usr/sbin:/bin',
            user    => 'root',
            onlyif  => "grep 'brctl show | wc -l' ${xen::params::scriptsdir}/network-bridge",
            require => File[$patchfile]
        }
    }

    # Debian Wheezy (use wheezy-backports for the xen-tools)
    if ($::lsbdistid == 'Debian') and ( $::lsbdistcodename == 'wheezy' ) {
        apt::source{'backports':
            location => 'http://http.debian.net/debian',
            release  => "${::lsbdistcodename}-backports",
            repos    => 'main contrib non-free',
            pin      => '200'
        } ->
        apt::pin {'wheezy-backports-xentools':
          ensure   => present,
          packages => 'debootstrap xen-tools',
          priority => 999,
          release  => 'wheezy-backports',
        } -> Package['xen']
    }
}
