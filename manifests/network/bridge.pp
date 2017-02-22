# File::      <tt>xen-network-bridge.pp</tt>
# Author::    Sebastien Varrette (<Sebastien.Varrette@uni.lu>)
# Copyright:: Copyright (c) 2011 Sebastien Varrette (www[http://varrette.gforge.uni.lu])
# License::   GPLv3
#
# ------------------------------------------------------------------------------
# = Define: xen::network::bridge
#
# Configure a network bridge for Xen on the given interface
#
# == Pre-requisites
#
# * The class 'xen::dom0' should have been instanciated
# * the interface on which the bridge should be configured should be set (as $name)
#
# == Parameters:
#
# [*ensure*]
#   default to 'present', can be 'absent' (BEWARE: this is not yet implemented)
#
# == Sample Usage:
#
#      xen::network::bridge { 'eth1':
#          ensure    => 'present',
#          comment   => 'Access network (10.74.0.0/16) - VLAN 124'
#      }
#
# == Warnings
#
# /!\ Always respect the style guide available
# here[http://docs.puppetlabs.com/guides/style_guide]
#
# [Remember: No empty lines between comments and class definition]
#
define xen::network::bridge (
    $ensure    = $xen::ensure,
    $comment   = ''
)
{

    include xen::params

    $interface = $name
    $bridge_interface = "br${interface}"

    info ("Configuring xen::network::bridge ${bridge_interface} on interface ${interface} (with ensure = ${ensure})")

    if ! ($ensure in [ 'present', 'absent' ]) {
        fail("xen::network::bridge 'ensure' parameter must be set to either 'absent' or 'present'")
    }

    network::interface { $interface:
        comment => $comment,
        manual  => true,
        dhcp    => false
    }

    network::interface { $bridge_interface:
        nettype     => 'Bridge',
        bridge_port => $interface,
        comment     => $comment,
        manual      => true,
        dhcp        => false
    }
}
