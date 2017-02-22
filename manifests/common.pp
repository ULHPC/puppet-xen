# File::      <tt>common.pp</tt>
# Author::    S. Varrette, H. Cartiaux, V. Plugaru, S. Diehl aka. UL HPC Management Team (hpc-sysadmins@uni.lu)
# Copyright:: Copyright (c) 2016 S. Varrette, H. Cartiaux, V. Plugaru, S. Diehl aka. UL HPC Management Team
# License::   Gpl-3.0
#
# ------------------------------------------------------------------------------
# = Class: xen::common
#
# Base class to be inherited by the other xen classes, containing the common code.
#
# Note: respect the Naming standard provided here[http://projects.puppetlabs.com/projects/puppet/wiki/Module_Standards]
class xen::common {

    # Load the variables used in this module. Check the xen-params.pp file
    require xen::params

    package { $xen::params::kernel_package:
        ensure => $xen::ensure
    }

    package { 'xen':
        ensure  => $xen::ensure,
        name    => $xen::params::packagename,
        require => Package[$xen::params::kernel_package]
    } ->
    package { $xen::params::utils_packages:
        ensure  => $xen::ensure ? { 'present' => 'latest', default => 'absent'}
    } ->
    file { $xen::params::configdir:
        ensure  => 'directory',
        owner   => $xen::params::configdir_owner,
        group   => $xen::params::configdir_group,
        mode    => $xen::params::configdir_mode,
        require => Package['xen']
    }


    # Configure Grub to first load Xen:
    exec { "mv ${xen::params::grubconfdir}/10_linux ${xen::params::grubconfdir}/50_linux":
        path    => '/usr/bin:/usr/sbin:/bin',
        unless  => "test -f ${xen::params::grubconfdir}/50_linux",
        notify  => Exec[$xen::params::updategrub],
        creates => "${xen::params::grubconfdir}/50_linux",
    }

    exec { 'update-grub':
        command     => $xen::params::updategrub,
        path        => '/usr/bin:/usr/sbin:/bin',
        returns     => 0,
        user        => 'root',
        logoutput   => true,
        timeout     => 10,
        refreshonly => true
    }

    # disable the OS prober, so that you don't get boot entries for each virtual
    # machine you install on a volume group.
    augeas { '/etc/default/grub/GRUB_DISABLE_OS_PROBER':
        context => '/files//etc/default/grub',
        changes => "set GRUB_DISABLE_OS_PROBER 'true'",
        onlyif  => "get GRUB_DISABLE_OS_PROBER  != 'true'",
        notify  => Exec['update-grub']
    }

    if ($xen::dom0_mem != '') {
        augeas { '/etc/default/grub/GRUB_CMDLINE_XEN':
            context => '/files//etc/default/grub',
            changes => "set GRUB_CMDLINE_XEN '\"dom0_mem=${xen::dom0_mem}M,max:${xen::dom0_mem}M no-bootscrub\"'",
            onlyif  => "get GRUB_CMDLINE_XEN  != '\"dom0_mem=${xen::dom0_mem}M,max:${xen::dom0_mem}M no-bootscrub\"'",
            notify  => Exec['update-grub']
        }
    }

    # reboot is mandatory at this level.

    # By default, when Xen dom0 shuts down or reboots, it tries to save the
    # state of the domUs. It may pose problems.
    augeas { '/etc/default/xendomains/XENDOMAINS_SAVE':
        context => '/files/etc/default/xendomains',
        changes => "set XENDOMAINS_SAVE '\"\"'",
        onlyif  => "get XENDOMAINS_SAVE != '\"\"'",
        require => Package['xen']
    }
    augeas { '/etc/default/xendomains/XENDOMAINS_RESTORE':
        context => '/files/etc/default/xendomains',
        changes => "set XENDOMAINS_RESTORE 'false'",
        onlyif  => "get XENDOMAINS_RESTORE != 'false'",
        require => Package['xen']
    }

    file { $xen::params::scriptsdir:
        ensure  => 'directory',
        owner   => $xen::params::configdir_owner,
        group   => $xen::params::configdir_group,
        mode    => $xen::params::configdir_mode,
        require => File[$xen::params::configdir]
    }

    file { $xen::params::autodir:
        ensure  => 'directory',
        owner   => $xen::params::configdir_owner,
        group   => $xen::params::configdir_group,
        mode    => $xen::params::configdir_mode,
        require => File[$xen::params::configdir]
    }
    augeas { '/etc/default/xendomains/XENDOMAINS_AUTO':
        context => '/files/etc/default/xendomains',
        changes => "set XENDOMAINS_AUTO '\"${xen::params::autodir}\"'",
        onlyif  => "get XENDOMAINS_AUTO != '\"${xen::params::autodir}\"'",
        require => Package['xen']
    }

    # TODO: Edit /etc/xen/xend-config.sxp to enable the network bridge.
    # Replace:
    #     # (network-script network-bridge)
    # by
    #     (network-script ${hostname}-network-bridge)
    file { $xen::params::configfile:
        ensure  => 'file',
        owner   => $xen::params::configfile_owner,
        group   => $xen::params::configfile_group,
        mode    => $xen::params::configfile_mode,
        content => template('xen/xend-config.sxp.erb'),
        require => File[$xen::params::configdir],
        notify  => Service['xen']
    }


    # Configure xen-tools
    file { $xen::params::toolsdir:
        ensure => 'directory',
        owner  => $xen::params::configdir_owner,
        group  => $xen::params::configdir_group,
        mode   => $xen::params::configdir_mode,
    }

    file { "${xen::params::toolsdir}/xen-tools.conf":
        ensure  => 'file',
        content => template('xen/xen-tools.conf.erb'),
        owner   => $xen::params::configfile_owner,
        group   => $xen::params::configfile_group,
        mode    => $xen::params::configfile_mode,
        require => File[$xen::params::toolsdir]
    }

    # Prepare the role directory
    file { $xen::params::roledir:
        ensure  => 'directory',
        owner   => $xen::params::configdir_owner,
        group   => $xen::params::configdir_group,
        mode    => $xen::params::configdir_mode,
        require => File[$xen::params::toolsdir]
    }

    file { "${xen::params::roledir}/motd":
        ensure  => 'file',
        owner   => $xen::params::configdir_owner,
        group   => $xen::params::configdir_group,
        mode    => '0755',
        content => template('xen/role.d/motd.erb'),
        require => File[$xen::params::roledir]
    }

    # Prepare the skeleton directory
    file { $xen::params::skeldir:
        ensure  => 'directory',
        owner   => $xen::params::configdir_owner,
        group   => $xen::params::configdir_group,
        mode    => $xen::params::configdir_mode,
        source  => 'puppet:///modules/xen/xen-tools/skel',
        recurse => true,
        require => File[$xen::params::toolsdir]
    }


#    # Prepare eventually the SSH keys for the root user
#    if !defined( Ssh::Keygen['root']) {
#
#        ssh::keygen{ 'root':
#            path    => "/root/.ssh",
#            type    => 'dsa',
#            comment => "Root user on ${fqdn}"
#        }
#    }
#
#    # Populate the skeleton directory
#    file { "${xen::params::skeldir}/root/.ssh/authorized_keys":
#        ensure => 'link',
#        target => "/etc/skel/.ssh/authorized_keys",
#        require => File["${xen::params::skeldir}"]
#    }



    # The final service
    service { 'xen':
        ensure     => running,
        name       => $xen::params::servicename,
        enable     => true,
        hasrestart => $xen::params::hasrestart,
        pattern    => $xen::params::processname,
        hasstatus  => $xen::params::hasstatus,
        require    => [
                      Package['xen'],
                      File[$xen::params::configdir],
                      Augeas['/etc/default/xendomains/XENDOMAINS_RESTORE'],
                      ],
        subscribe  => File[$xen::params::configfile],
    }
}
