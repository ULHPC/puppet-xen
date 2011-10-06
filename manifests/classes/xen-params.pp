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
    
    
    
    #### MODULE INTERNAL VARIABLES  #########
    # (Modify to adapt to unsupported OSes)
    #######################################
    $packagename = $::operatingsystem ? {
        default => 'xen-hypervisor-4.0-amd64'
    }
    
    $kernel_package = $::operatingsystem ? {
        default => 'linux-image-2.6-xen-amd64'        
    }
    
    $utils_packages = $::operatingsystem ? {
        default => [
                    'xen-tools',
                    'xen-utils-4.0'
                    ]        
    }

    $servicename = $::operatingsystem ? {
        default  => 'xend'
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

    $configfile_mode = $::operatingsystem ? {
        default => '0644',
    }

    $configfile_owner = $::operatingsystem ? {
        default => 'root',
    }

    $configfile_group = $::operatingsystem ? {
        default => 'root',
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
    # Xen script dir (in particular for network bridge configuration)
    $scriptsdir = $::operatingsystem ? {
        default => "/etc/xen/scripts",
    }
    
    # Directory containing xen-tools
    $toolsdir = $::operatingsystem ? {
        default => "/etc/xen-tools",
    }

    $grubconfdir = $::operatingsystem ? {
        default => '/etc/grub.d'
    }
    
    $updategrub = $::operatingsystem ? {
        default => 'update-grub'
        
    }
    

    
    
    # $pkgmanager = $::operatingsystem ? {
    #     /(?i-mx:ubuntu|debian)/	       => [ '/usr/bin/apt-get' ],
    #     /(?i-mx:centos|fedora|redhat)/ => [ '/bin/rpm', '/usr/bin/up2date', '/usr/bin/yum' ],
    #     default => []
    # }


}

