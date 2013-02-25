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
    $ensure = $xen_ensure ? {
        ''      => 'present',
        default => "${xen_ensure}"
    }

    # List the interfaces on which a network bridge should be configured
    $bridge_on = $xen_bridge_on ? {
        ''      => [ 'eth1' ],
        default => $xen_bridge_on
    }

    # List the interfaces, used at the same time as a bridge and for the dom0
    $if_shared = $xen_if_shared ? {
        ''      => '',
        default => $xen_if_shared
    }

    # Use the pygrub wrapper such that each VM manages its own kernel and does not
    # use the one of the Xen dom0
    $domU_use_pygrub = $xen_domU_use_pygrub ? {
        ''      => true,
        'yes'   => true,
        'no'    => false,
        default => $xen_domU_use_pygrub
    }

    # Use SCSI names for virtual devices (i.e. sda not xvda). for creating
    # squeeze hosts, you will probably have to drop this option (as discussed
    # [here](http://superuser.com/questions/255083/xen-fails-to-boot-timeout-mounting-dev-sda2)
    # or you won't be able to boot
    $domU_use_scsi = $xen_domU_use_scsi ? {
        ''      => false,
        'yes'   => true,
        'no'    => false,
        default => $xen_domU_use_scsi
    }

    # true if you wish the images to use DHCP
    $domU_use_dhcp = $xen_domU_use_dhcp ? {
        ''      => true,
        'yes'   => true,
        'no'    => false,
        default => $xen_domU_use_dhcp
    }

    # Order of the domU when placed in the /etc/xen/auto directory
    $domU_order = $xen_domU_order ? {
        ''      => 50,
        default => $xen_domU_order
    }

    # Number of virtual CPUs (i.e. cores) assigned to the domU
    $domU_vcpus = $xen_domU_vcpus ? {
        ''      => 1,
        default => $xen_domU_vcpus
    }

    # Default distribution to install. (Guess automatically by calling
    # `xt-guess-suite-and-mirror --suite`by default)
    $domU_distrib = $xen_domU_distrib ? {
        ''      => '',
        default => $xen_domU_distrib
    }


    # LVM volume group to use for hosting domU disk image
    $domU_lvm = $xen_domU_lvm ? {
        ''      => "vg_${hostname}_domU",
        default => "$xen_domU_lvm"
    }

    # domU Disk image size.
    $domU_size = $xen_domU_size ? {
        ''      => '10Gb',
        default => "$xen_domU_size"
    }
    # domU Memory size
    $domU_memory = $xen_domU_memory ? {
        ''      => '256Mb',
        default => "$xen_domU_memory"
    }
    # domU Swap size
    $domU_swap = $xen_domU_swap ? {
        ''      => '512Mb',
        default => "$xen_domU_swap"
    }
    # domU network settings
    $domU_gateway = $xen_domU_gateway ? {
        ''      => '10.74.0.1',
        default => "$xen_domU_gateway"
    }
    $domU_netmask = $xen_domU_netmask ? {
        ''      => '255.255.0.0',
        default => "$xen_domU_netmask"
    }
    $domU_broadcast = $xen_domU_broadcast ? {
        ''      => '10.74.255.255',
        default => "$xen_domU_broadcast"
    }
    # domU architecture to use when using debootstrap
    $domU_arch = $xen_domU_arch ? {
        ''      => 'amd64',
        default => "$xen_domU_arch"
    }

    # List of the specified role script(s) post-install.
    $domU_roles = $xen_domU_roles ? {
        ''      => [ 'udev' ],
        default => $xen_domU_roles
    }


    #### MODULE INTERNAL VARIABLES  #########
    # (Modify to adapt to unsupported OSes)
    #######################################
    $packagename = $lsbdistcodename ? {
        'squeeze' => 'xen-hypervisor-4.0-amd64',
        'wheezy'  => 'xen-hypervisor-4.1-amd64',
        default   => 'xen-hypervisor-4.1-amd64'
    }

    $kernel_package = $lsbdistcodename ? {
        'squeeze' => 'linux-image-2.6-xen-amd64',
        'wheezy'  => 'linux-image-3.2.0-4-amd64',
        default   => 'linux-image-3.2.0-4-amd64'
    }

    $utils_packages = $lsbdistcodename ? {
        'squeeze' => [
                     'xen-tools',
                     'xen-utils-4.0'
                     ],
        'wheezy'  => [
                     'xen-tools',
                     'xen-utils-4.1'
                     ],
        default   => [
                     'xen-tools',
                     'xen-utils-4.1'
                     ]
    }

    $servicename = $lsbdistcodename ? {
        'squeeze' => 'xend',
        'wheezy'  => 'xen',
        default   => 'xend'
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
        default => "/etc/xen",
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
        default => "/etc/xen/scripts",
    }

    # Xen directory holding the domUs to start on boot
    $autodir = $::operatingsystem ? {
        default => "${configdir}/auto",
    }


    # Directory containing xen-tools
    $toolsdir = $::operatingsystem ? {
        default => "/etc/xen-tools",
    }
    $tools_logdir  = $::operatingsystem ? {
        default => "/var/log/xen-tools",
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

