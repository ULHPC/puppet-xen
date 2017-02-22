# The baseline for module testing used by Puppet Labs is that each manifest
# should have a corresponding test manifest that declares that class or defined
# type.
#
# Tests are then run by using puppet apply --noop (to check for compilation
# errors and view a log of events) or by fully applying the test in a virtual
# environment (to compare the resulting system state to the desired state).
#
# Learn more about module testing here:
# http://docs.puppetlabs.com/guides/tests_smoke.html
#
#
#
# You can execute this manifest as follows in your vagrant box:
#
#      sudo puppet apply -t /vagrant/tests/init.pp
#
node default {

    class { 'xen':
        bridge_on      => [ 'eth1' ],
        domU_lvm       => 'vg_domU',
        dom0_mem       => '4096',
        domU_gateway   => '10.20.30.1',
        domU_netmask   => '255.255.255.0',
        domU_broadcast => '10.20.30.255',
        domU_arch      => 'amd64'
    }

#    xen::domU { 'test-vm':
#        ensure  => 'running',
#        order   => 25,
#        desc    => 'Test VM',
#        vcpus   => 1,
#        size    => '1Gb',
#        ramsize => '256Mb',
#        swap    => '128Mb',
#        ip      => '10.20.30.42',
#    }

    xen::network::bridge { 'eth2':
        ensure  => 'present',
        comment => 'Access network (10.74.0.0/16) - VLAN 124'
    }

}
