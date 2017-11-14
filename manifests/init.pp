# File::      <tt>init.pp</tt>
# Author::    S. Varrette, H. Cartiaux, V. Plugaru, S. Diehl aka. UL HPC Management Team (hpc-sysadmins@uni.lu)
# Copyright:: Copyright (c) 2016 S. Varrette, H. Cartiaux, V. Plugaru, S. Diehl aka. UL HPC Management Team
# License::   Gpl-3.0
#
# ------------------------------------------------------------------------------
# = Class: xen
#
# Configure and manage a Xen host (dom0 in the xen terminology)
#
# == Parameters:
#
# $ensure:: *Default*: 'present'. Ensure the presence (or absence) of xen
# $bridge_on:: *Default*: eth1'.  List of the interfaces on which a network
#     bridge should be configured
# $if_shared:: *Default*: empty. Interface used for the Dom0, and as a network
#     bridge
# $dom0_memory:: *Default*: empty. Set the memory (in MB) for the Dom0, and
#     disable dom0 ballooning
# $domu_lvm:: *Default*: 'vg_${hostname}_domu'. LVM volume group to use for
#     hosting domu disk image
# $domu_size:: *Default*: '10Gb'.
# $domu_memory:: *Default*: '256Mb'.
# $domu_swap:: *Default*: '512Mb'
# $domu_gateway:: *Default*: '10.74.0.1'
# $domu_netmask:: *Default*: '255.255.0.0'
# $domu_broadcast:: *Default*: '10.74.255.255'
# $domu_arch:: *Default*: 'amd64'
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
class xen(
    $ensure         = $xen::params::ensure,
    $bridge_on      = $xen::params::bridge_on,
    $if_shared      = $xen::params::if_shared,
    $dom0_mem       = $xen::params::dom0_mem,
    $domu_lvm       = $xen::params::domu_lvm,
    $domu_size      = $xen::params::domu_size,
    $domu_memory    = $xen::params::domu_memory,
    $domu_swap      = $xen::params::domu_swap,
    $domu_gateway   = $xen::params::domu_gateway,
    $domu_netmask   = $xen::params::domu_netmask,
    $domu_broadcast = $xen::params::domu_broadcast,
    $domu_arch      = $xen::params::domu_arch
)
inherits xen::params
{
    info ("Configuring xen dom0 (with ensure = ${ensure})")

    if ! ($ensure in [ 'present', 'absent' ]) {
        fail("xen 'ensure' parameter must be set to either 'absent' or 'present'")
    }

    case $::operatingsystem {
        'debian', 'ubuntu':         { include ::xen::common::debian }
        default: {
            fail("Module ${module_name} is not supported on ${::operatingsystem}")
        }
    }
}
