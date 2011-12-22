# File::      <tt>xen.pp</tt>
# Author::    Sebastien Varrette (Sebastien.Varrette@uni.lu)
# Copyright:: Copyright (c) 2011 Sebastien Varrette
# License::   GPLv3
#
# ------------------------------------------------------------------------------
# = Class: xen::dom0
#
# Configure and manage a Xen host (dom0 in the xen terminology)
#
# == Parameters:
#
# $ensure:: *Default*: 'present'. Ensure the presence (or absence) of xen
#
# == Requires:
#
# n/a
#
# == Sample Usage:
#
#     import xen
#
# You can then specialize the various aspects of the configuration,
# for instance:
#
#         class { 'xen':
#             ensure    => 'present',
#             bridge_on => [ 'eth3', 'eth4' ],  # This should be an array
#         }
#
# == Warnings
#
# /!\ Always respect the style guide available
# here[http://docs.puppetlabs.com/guides/style_guide]
#
#
# [Remember: No empty lines between comments and class definition]
#
class xen::dom0(
    $ensure         = $xen::params::ensure,
    $bridge_on      = $xen::params::bridge_on,
    $domU_lvm       = $xen::params::domU_lvm,
    $domU_size      = $xen::params::domU_size,
    $domU_memory    = $xen::params::domU_memory,
    $domU_swap      = $xen::params::domU_swap,
    $domU_gateway   = $xen::params::domU_gateway,
    $domU_netmask   = $xen::params::domU_netmask,
    $domU_broadcast = $xen::params::domU_broadcast,
    $domU_arch      = $xen::params::domU_arch
)
inherits xen::params
{
    info ("Configuring xen::dom0 (with ensure = ${ensure})")

    if ! ($ensure in [ 'present', 'absent' ]) {
        fail("xen::dom0 'ensure' parameter must be set to either 'absent' or 'present'")
    }

    case $::operatingsystem {
        debian, ubuntu:         { include xen::dom0::debian }
        redhat, fedora, centos: { include xen::dom0::redhat }
        default: {
            fail("Module $module_name is not supported on $operatingsystem")
        }
    }
}

# ------------------------------------------------------------------------------
# = Class: xen::dom0::common
#
# Base class to be inherited by the other xen::dom0 classes
#
# Note: respect the Naming standard provided here[http://projects.puppetlabs.com/projects/puppet/wiki/Module_Standards]
class xen::dom0::common {

    # Load the variables used in this module. Check the xen-params.pp file
    require xen::params

    package { "${xen::params::kernel_package}":
        ensure => "${xen::dom0::ensure}"
    }

    package { 'xen':
        name    => "${xen::params::packagename}",
        ensure  => "${xen::dom0::ensure}",
        require => Package["${xen::params::kernel_package}"]
    }

    package { $xen::params::utils_packages :
        ensure  => "${xen::dom0::ensure}",
        require => Package['xen']
    }

    file { "${xen::params::configdir}":
        ensure => 'directory',
        owner   => "${xen::params::configdir_owner}",
        group   => "${xen::params::configdir_group}",
        mode    => "${xen::params::configdir_mode}",
        require => Package['xen']
    }


    # Configure Grub to first load Xen:
    exec { "mv ${xen::params::grubconfdir}/10_linux ${xen::params::grubconfdir}/50_linux":
        unless  => "test -f ${xen::params::grubconfdir}/50_linux",
        notify  => Exec["${xen::params::updategrub}"],
        creates => "${xen::params::grubconfdir}/50_linux",
    }

    exec { 'update-grub':
        command   => "${xen::params::updategrub}",
        path      => "/usr/bin:/usr/sbin:/bin",
        returns   => 0,
        user      => 'root',
        logoutput => true,
        timeout   => 10,
    }

    # disable the OS prober, so that you don’t get boot entries for each virtual
    # machine you install on a volume group.
    augeas { "/etc/default/grub/GRUB_DISABLE_OS_PROBER":
        context => "/files//etc/default/grub",
        changes => "set GRUB_DISABLE_OS_PROBER 'true'",
        onlyif  => "get GRUB_DISABLE_OS_PROBER  != 'true'",
        notify => Exec['update-grub']
    }

    # reboot is mandatory at this level.

    # By default, when Xen dom0 shuts down or reboots, it tries to save the
    # state of the domUs. It may pose problems.
    augeas { "/etc/default/xendomains/XENDOMAINS_SAVE":
        context => '/files/etc/default/xendomains',
        changes => "set XENDOMAINS_SAVE '\"\"'",
        onlyif  => "get XENDOMAINS_SAVE != '\"\"'",
    }
    augeas { "/etc/default/xendomains/XENDOMAINS_RESTORE":
        context => '/files/etc/default/xendomains',
        changes => "set XENDOMAINS_RESTORE 'false'",
        onlyif  => "get XENDOMAINS_RESTORE != 'false'",
    }

    file { "${xen::params::scriptsdir}":
        ensure => 'directory',
        owner   => "${xen::params::configdir_owner}",
        group   => "${xen::params::configdir_group}",
        mode    => "${xen::params::configdir_mode}",
        require => File["${xen::params::configdir}"]
    }

    # Configure the network bridge file
    file { "${xen::params::scriptsdir}/${hostname}-network-bridge":
        ensure  => 'file',
        owner   => "${xen::params::configdir_owner}",
        group   => "${xen::params::configdir_group}",
        mode    => '0755',
        content => template("xen/network-bridge.erb"),
        require => File["${xen::params::scriptsdir}"]
    }

    # Configure the interface in manual mode
    network::interface { $xen::dom0::bridge_on :
        comment => "Activate the interface yet without any specific IP/configuration \n# Required for Xen bridge configuration",
        auto    => false,
        manual  => true,
        dhcp    => false,
    }

    # TODO: Edit /etc/xen/xend-config.sxp to enable the network bridge.
    # Replace:
    #     # (network-script network-bridge)
    # by
    #     (network-script ${hostname}-network-bridge)
    #

    # Under squeeze: You have to patch the network script!
    if ($::lsbdistid == 'Debian') and ( $::lsbdistcodename == 'squeeze' ) {
        $patchfile = '/tmp/network-bridge.patch'
        file { "${patchfile}":
            ensure => 'file',
            source => 'puppet:///modules/xen/squeeze-network-bridge.patch',
            owner  => 'root',
            group  => 'root',
            mode   => '0644'
        }

        exec { 'patch Xen network-brige':
            command  => "patch -p0 -i ${patchfile}",
            path     => "/usr/bin:/usr/sbin:/bin",
            user     => 'root',
            onlyif   => "grep '[ -n \"$gateway\" ] && ip route add default via ${gateway}' ${xen::params::scriptsdir}/network-bridge",
            require  => File["${patchfile}"]
        }
    }

    # Now prepare the /etc/xen-tools/skel
    # TODO

    # Configure xen-tools
    file { "${xen::params::toolsdir}":
        ensure => 'directory',
        owner   => "${xen::params::configdir_owner}",
        group   => "${xen::params::configdir_group}",
        mode    => "${xen::params::configdir_mode}",
    }
    
    file { "${xen::params::toolsdir}/xen-tools.conf":
        ensure  => 'file',
        content => template("xen/xen-tools.conf.erb"),
        owner   => "${xen::params::configfile_owner}",
        group   => "${xen::params::configfile_group}",
        mode    => "${xen::params::configfile_mode}",
        require => File["${xen::params::toolsdir}"]
    }




    # service { 'xen':
    #     name       => "${xen::params::servicename}",
    #     enable     => true,
    #     ensure     => running,
    #     hasrestart => "${xen::params::hasrestart}",
    #     pattern    => "${xen::params::processname}",
    #     hasstatus  => "${xen::params::hasstatus}",
    #     require    => Package['xen'],
    #     subscribe  => File['xen.conf'],
    # }
}


# ------------------------------------------------------------------------------
# = Class: xen::dom0::debian
#
# Specialization class for Debian systems
class xen::dom0::debian inherits xen::dom0::common {

    # Disable bridge filtering
    # net.bridge.bridge-nf-call-arptables = 0
    # net.bridge.bridge-nf-call-ip6tables = 0
    # net.bridge.bridge-nf-call-iptables = 0
    # net.bridge.bridge-nf-filter-vlan-tagged = 0

    include sysctl
    sysctl::value { "net.bridge.bridge-nf-call-arptables":
       value => '0',
       ensure => "${xen::dom0::ensure}"
    }
    sysctl::value { "net.bridge.bridge-nf-call-ip6tables":
       value => '0',
       ensure => "${xen::dom0::ensure}"
    }
    sysctl::value { "net.bridge.bridge-nf-call-iptables":
       value => '0',
       ensure => "${xen::dom0::ensure}"
    }
    sysctl::value { "net.bridge.bridge-nf-filter-vlan-tagged":
       value => '0',
       ensure => "${xen::dom0::ensure}"
    }

}

# ------------------------------------------------------------------------------
# = Class: xen::dom0::redhat
#
# Specialization class for Redhat systems
class xen::dom0::redhat inherits xen::dom0::common { }



