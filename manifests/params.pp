# File::      <tt>xen-params.pp</tt>
# Author::    Sebastien Varrette (Sebastien.Varrette@uni.lu)
# Copyright:: Copyright (c) 2011 Sebastien Varrette
# License::   GPL v3
#
# ------------------------------------------------------------------------------
# = Class: xen::params
#
# In this class are defined as variables values that are used in other
# xen classes.
# This class should be included, where necessary, and eventually be enhanced
# with support for more OS
#
# == Warnings
#
# /!\ Always respect the style guide available
# here[http://docs.puppetlabs.com/guides/style_guide]
#
# The usage of a dedicated param classe is advised to better deal with
# parametrized classes, see
# http://docs.puppetlabs.com/guides/parameterized_classes.html
#
# [Remember: No empty lines between comments and class definition]
#
class xen::params {

    ######## DEFAULTS FOR VARIABLES USERS CAN SET ##########################
    # (Here are set the defaults, provide your custom variables externally)
    # (The default used is in the line with '')
    ###########################################

    # ensure the presence (or absence) of xen
    $ensure = $::xen_ensure ? {
        ''      => 'present',
        default => $::xen_ensure
    }

    # List the interfaces on which a network bridge should be configured
    $bridge_on = $::xen_bridge_on ? {
        ''      => [ 'eth1' ],
        default => $::xen_bridge_on
    }

    # List the interfaces, used at the same time as a bridge and for the dom0
    $if_shared = $::xen_if_shared ? {
        ''      => '',
        default => $::xen_if_shared
    }

    # Memory for the dom0 (MB)
    $dom0_mem = $::xen_dom0_mem ? {
        ''      => '',
        default => $::xen_dom0_mem
    }

    # Use the pygrub wrapper such that each VM manages its own kernel and does not
    # use the one of the Xen dom0
    $domu_use_pygrub = $::xen_domu_use_pygrub ? {
        ''      => true,
        'yes'   => true,
        'no'    => false,
        default => $::xen_domu_use_pygrub
    }

    # Use SCSI names for virtual devices (i.e. sda not xvda). for creating
    # squeeze hosts, you will probably have to drop this option (as discussed
    # [here](http://superuser.com/questions/255083/xen-fails-to-boot-timeout-mounting-dev-sda2)
    # or you won't be able to boot
    $domu_use_scsi = $::xen_domu_use_scsi ? {
        ''      => false,
        'yes'   => true,
        'no'    => false,
        default => $::xen_domu_use_scsi
    }

    # true if you wish the images to use DHCP
    $domu_use_dhcp = $::xen_domu_use_dhcp ? {
        ''      => true,
        'yes'   => true,
        'no'    => false,
        default => $::xen_domu_use_dhcp
    }

    # Order of the domu when placed in the /etc/xen/auto directory
    $domu_order = $::xen_domu_order ? {
        ''      => 50,
        default => $::xen_domu_order
    }

    # Number of virtual CPUs (i.e. cores) assigned to the domu
    $domu_vcpus = $::xen_domu_vcpus ? {
        ''      => 1,
        default => $::xen_domu_vcpus
    }

    # Default distribution to install. (Guess automatically by calling
    # `xt-guess-suite-and-mirror --suite`by default)
    $domu_distrib = $::xen_domu_distrib ? {
        ''      => '',
        default => $::xen_domu_distrib
    }


    # LVM volume group to use for hosting domu disk image
    $domu_lvm = $::xen_domu_lvm ? {
        ''      => "vg_${::hostname}_domu",
        default => $::xen_domu_lvm
    }

    # domu Disk image size.
    $domu_size = $::xen_domu_size ? {
        ''      => '10Gb',
        default => $::xen_domu_size
    }
    # domu Memory size
    $domu_memory = $::xen_domu_memory ? {
        ''      => '256Mb',
        default => $::xen_domu_memory
    }
    # domu Swap size
    $domu_swap = $::xen_domu_swap ? {
        ''      => '512Mb',
        default => $::xen_domu_swap
    }
    # domu network settings
    $domu_gateway = $::xen_domu_gateway ? {
        ''      => '10.74.0.1',
        default => $::xen_domu_gateway
    }
    $domu_netmask = $::xen_domu_netmask ? {
        ''      => '255.255.0.0',
        default => $::xen_domu_netmask
    }
    $domu_broadcast = $::xen_domu_broadcast ? {
        ''      => '10.74.255.255',
        default => $::xen_domu_broadcast
    }
    # domu architecture to use when using debootstrap
    $domu_arch = $::xen_domu_arch ? {
        ''      => 'amd64',
        default => $::xen_domu_arch
    }

    # List of the specified role script(s) post-install.
    $domu_roles = $::xen_domu_roles ? {
        ''      => [ 'udev' ],
        default => $::xen_domu_roles
    }


    #### MODULE INTERNAL VARIABLES  #########
    # (Modify to adapt to unsupported OSes)
    #######################################
    $packagename = $::lsbdistcodename ? {
        'squeeze' => 'xen-hypervisor-4.0-amd64',
        'wheezy'  => 'xen-hypervisor-4.1-amd64',
        default   => 'xen-hypervisor-4.1-amd64'
    }

    $kernel_package = $::lsbdistcodename ? {
        'squeeze' => 'linux-image-2.6-xen-amd64',
        'wheezy'  => 'linux-image-3.2.0-4-amd64',
        default   => 'linux-image-3.2.0-4-amd64'
    }

    $utils_packages = $::lsbdistcodename ? {
        'squeeze' => [
                      'xen-tools',
                      'xen-utils-4.0',
                      ],
        'wheezy'  => [
                      'xen-tools',
                      'xen-utils-4.1',
                      'debootstrap',
                      ],
        'jessie'  => [
                      'xen-tools',
                      'xen-utils-4.4',
                      'debootstrap',
                      ],
        default   => [
                      'xen-tools',
                      'xen-utils-4.1',
                      ]
    }

    $servicename = $::lsbdistcodename ? {
        'squeeze' => 'xend',
        'wheezy'  => 'xen',
        'jessie'  => 'xen',
        default   => 'xend'
    }


    $toolstack = $::lsbdistcodename ? {
        'squeeze' => 'xm',
        'wheezy'  => 'xm',
        'jessie'  => 'xl',
        default   => 'xm'
    }

    # used for pattern in a service ressource
    $processname = $::operatingsystem ? {
        default  => 'xend'
    }

    $hasstatus = $::operatingsystem ? {
        /(?i-mx:ubuntu|debian)/        => false,
        /(?i-mx:centos|fedora|redhat)/ => true,
        default => true,
    }

    $hasrestart = $::operatingsystem ? {
        default => true,
    }

    # Configuration directory for Xen
    $configdir = $::operatingsystem ? {
        default => '/etc/xen',
    }
    $configdir_mode = $::operatingsystem ? {
        default => '0755',
    }

    $configdir_owner = $::operatingsystem ? {
        default => 'root',
    }

    $configdir_group = $::operatingsystem ? {
        default => 'root',
    }

    # Xend configuration file
    $configfile = $::operatingsystem ? {
        default => "${configdir}/xend-config.sxp"
    }
    $configfile_mode = $::operatingsystem ? {
        default => '0644',
    }

    $configfile_owner = $::operatingsystem ? {
        default => 'root',
    }

    $configfile_group = $::operatingsystem ? {
        default => 'root',
    }


    # Xen script dir (in particular for network bridge configuration)
    $scriptsdir = $::operatingsystem ? {
        default => '/etc/xen/scripts',
    }

    # Xen directory holding the domus to start on boot
    $autodir = $::operatingsystem ? {
        default => "${configdir}/auto",
    }


    # Directory containing xen-tools
    $toolsdir = $::operatingsystem ? {
        default => '/etc/xen-tools',
    }
    $tools_logdir  = $::operatingsystem ? {
        default => '/var/log/xen-tools',
    }
    $grubconfdir = $::operatingsystem ? {
        default => '/etc/grub.d'
    }

    $updategrub = $::operatingsystem ? {
        default => 'update-grub'
    }
    $skeldir = $::operatingsystem ? {
        default => "${toolsdir}/skel",
    }
    $roledir = $::operatingsystem ? {
        default => "${toolsdir}/role.d",
    }


}

