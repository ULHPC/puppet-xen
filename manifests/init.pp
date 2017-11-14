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
# $domU_lvm:: *Default*: 'vg_${hostname}_domU'. LVM volume group to use for
#     hosting domU disk image
# $domU_size:: *Default*: '10Gb'.
# $domU_memory:: *Default*: '256Mb'.
# $domU_swap:: *Default*: '512Mb'
# $domU_gateway:: *Default*: '10.74.0.1'
# $domU_netmask:: *Default*: '255.255.0.0'
# $domU_broadcast:: *Default*: '10.74.255.255'
# $domU_arch:: *Default*: 'amd64'
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
