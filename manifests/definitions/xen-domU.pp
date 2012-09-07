# File::      <tt>xen-domU.pp</tt>
# Author::    Sebastien Varrette (<Sebastien.Varrette@uni.lu>)
# Copyright:: Copyright (c) 2012 Sebastien Varrette (www[http://varrette.gforge.uni.lu])
# License::   GPLv3
#
# ------------------------------------------------------------------------------
# = Defines: xen::domU
#
# Configure and install a Xen guest (domU in teh Xen terminology) on the Xen dom0
#
# == Pre-requisites
#
# * The class "xen::dom0" should have been instanciated.
#
# == Parameters:
#
# [*ensure*]
#   default to 'present', can be 'absent' or 'disabled'. The disabled status
#   will shutdown the domU and ensure the symbolic link in /etc/xen/auto/ is
#   removed.
#   Default: 'present'
#
#
# [*password*]
#   password of the root on the domU to be created. If left to an empty string,
#   a random password will be generated (and stored in the accessfile)
#
# [*accessfile*]
#   The file used to save the access configuration (including root password) for
#   the created VM.
#   Default to /etc/xen/.credentials_<domUname>.cnf

# == Sample usage:
#
#     import xen::domU
#
# You can then specialize the various aspects of the configuration,
# for instance:
#
#      xen::domU{ 'myhost':
#          ensure => 'present'
#      }
#
# == Warnings
#
# /!\ Always respect the style guide available
# here[http://docs.puppetlabs.com/guides/style_guide]
#
# [Remember: No empty lines between comments and class definition]
#
define xen::domU (
    $ensure     = $xen::params::ensure,
    $order      = $xen::params::domU_order,
    $use_pygrub = $xen::params::domU_use_pygrub,
    $use_scsi   = $xen::params::domU_use_scsi,
    $use_dhcp   = $xen::params::domU_use_dhcp,
    $vcpus      = $xen::params::domU_vcpus,
    $distrib    = $xen::params::domU_dist,
    $size       = $xen::params::domU_size,
    $ramsize    = $xen::params::domU_memory,
    $swap       = $xen::params::domU_swap,
    $gateway    = $xen::params::domU_gateway,
    $netmask    = $xen::params::domU_netmask,
    $broadcast  = $xen::params::domU_broadcast,
    $arch       = $xen::params::domU_arch,
    $roles      = $xen::params::domU_roles,
    $desc       = '',
    $do_force   = false,
    $ip         = '',
    $bridge     = '',
    $mac        = '',
    $infofile   = '',
    $password   = '',
    $timeout    = 360
)
{
    include xen::params

    # $name is provided at define invocation
    $domU_hostname = "${name}"

    $domU_configfile          = "${xen::params::configdir}/${domU_hostname}.cfg"
    $domU_snapshot_configfile = "${xen::params::configdir}/${domU_hostname}-snapshot.cfg"

    $domU_infofile = $infofile ? {
        ''      => "${xen::params::configdir}/info_${domU_hostname}.txt",
        default => "${infofile}"
    }
    $root_passwd = $password ? {
        ''      => chomp(generate("/usr/bin/pwgen", '--secure', 12, 1)),
        default => "${password}"
    }

    $dist = $distrib ? {
        ''      => "${lsbdistcodename}",
        default => "${distrib}"
    }

    if ("${domU_hostname}" == '') {
        fail("Cannot create Xen domain with empty name")
    }

    # Check the presence of the xen::dom0 class
    if !defined(Class['xen::dom0']) {
        fail("The Puppet class xen::dom0 is not instanciated")
    }

    info ("Configuring xen::domU for ${domU_hostname} (with ensure = ${ensure})")

    $authorized_ensure = [ 'present', 'absent', 'running', 'stopped' ]


    if ! ($ensure in $authorized_ensure) {
        fail("xen::domU 'ensure' parameter must be set to either 'present', 'absent', 'running', 'stopped'")
    }

    if ($xen::dom0::ensure != $ensure) {
        if ($xen::dom0::ensure != 'present') {
            fail("Cannot configure a xen DomU '${domU_hostname}' as xen::dom0::ensure is NOT set to present (but ${xen::dom0::ensure})")
        }
    }

    # Now prepare the option lines for xen-create-image
    $opt_swap = $swap ? {
        ''      => '--noswap',
        0       => '--noswap',
        default => "--swap=${swap}"
    }
    $opt_scsi = $use_scsi ? {
        true    => '--scsi',
        default => ''
    }
    $opt_pygrub = $use_pygrub ? {
        true    => '--pygrub',
        default => ''
    }
    $opt_force = $do_force ? {
        true    => '--force',
        default => ''
    }
    $real_roles = array_add($roles, 'motd')

    $motd_netinfo = $ip ? {
        '' => $use_dhcp ? {
            true    => 'IP: via DHCP',
            default => ''
        },
        default => "IP: ${ip}"
    }

    $motd_role_args = "--role-args=\"--motd_hostname '${domU_hostname}' --motd_domain '${domain}' --motd_msg1 '${desc}' --motd_netinfo '${motd_netinfo}' --motd_vcpus ${vcpus} --motd_ramsize '${ramsize}' --motd_swapsize '${swap}' --motd_rootsize '${size}'\""

    $opt_role = $real_roles ? {
        ''      => '',
        default => inline_template("--role=<%= real_roles.join(',') %> ${motd_role_args}")
    }

    $opt_dist = $distrib ? {
        ''      => '',
        default => "--dist=${distrib}"
    }
    # Network stuff
    $opt_dhcp = $use_dhcp ? {
        true    => '--dhcp',
        default => ''
    }
    $opt_ip = $ip ? {
        ''      => '',
        default => "--ip ${ip}"
    }
    $opt_bridge = $bridge_on ? {
        ''      => '',
        default => '--bridge=${bridge}'
    }
    $opt_mac = $mac ? {
        ''      => '',
        default => "--mac=${mac}"
    }
    $opt_netmask = $netmask ? {
        ''      => '',
        default => "--netmask=${netmask}"
    }
    $opt_broadcast = $broadcast ? {
        ''      => '',
        default => "--broadcast=${broadcast}"
    }
    $opt_gateway = $gateway ? {
        ''      => '',
        default => "--gateway=${gateway}"
    }
    # The complete network configuration option
    $opt_network_config = $ip ? {
        ''      => "${opt_dhcp}",
        default => "${opt_bridge} ${opt_ip} ${opt_netmask} ${opt_broadcast} ${opt_gateway}"
    }

    # The final command
    $xen_create_image_cmd = "xen-create-image ${opt_force} ${opt_scsi} ${opt_pygrub} --vcpus ${vcpus} --host ${domU_hostname} ${opt_dist} --size=${size} ${opt_swap} --memory=${ramsize} ${opt_role} ${opt_network_config} --genpass=0 --password='${root_passwd}'"


    # stage one: ensure the domU exists
    case $ensure {
        'present', 'running', 'stopped': {

            exec { "xen_create_${domU_hostname}":
                path    => "/usr/bin:/usr/sbin:/bin:/sbin",
                command => "${xen_create_image_cmd}",
                #creates => "/dev/mapper/${xen::dom0::domU_lvm}-${domU_hostname}--disk",
                creates => "${domU_configfile}",
                timeout => $timeout,
                require => [
                            Package['xen-tools'],
                            File["${xen::params::toolsdir}/xen-tools.conf"]
                            ]
            }
            # this should have created /etc/xen/${domU_hostname}.cfg
            file { "${domU_configfile}":
                ensure  => 'file',
                owner   => "${xen::params::configfile_owner}",
                group   => "${xen::params::configfile_group}",
                mode    => '0644',
                require => [
                            Package['xen'],
                            Package["${xen::params::kernel_package}"],
                            File["${xen::params::configdir}"],
                            Exec["xen_create_${domU_hostname}"]
                            ]
            }

            # Prepare the snapshot config file
            # exec { "cp ${domU_configfile} ${domU_snapshot_configfile}":
            #     path    => "/usr/bin:/usr/sbin:/bin:/sbin",
            #     creates => "${domU_snapshot_configfile}",
            #     user    => "${xen::params::configfile_owner}",
            #     group   => "${xen::params::configfile_group}",
            #     require => File["${domU_configfile}"]
            # }

            exec { "Adapting ${domU_snapshot_configfile}":
                command => "sed 's/${xen::dom0::domU_lvm}\/${domU_hostname}-disk/${xen::dom0::domU_lvm}\/${domU_hostname}-snapshot-disk/' ${domU_configfile} >  ${domU_snapshot_configfile}",
                path    => "/usr/bin:/usr/sbin:/bin:/sbin",
                user    => "${xen::params::configfile_owner}",
                group   => "${xen::params::configfile_group}",
                require => File["${domU_configfile}"]
            }

            # replace the LVM disk in ${domU_snapshot_configfile}
            # file { "${domU_snapshot_configfile}":
            #     ensure  => 'file',
            #     owner   => "${xen::params::configfile_owner}",
            #     group   => "${xen::params::configfile_group}",
            #     mode    => '0644',
            #     require => File["${domU_configfile}"]
            # }

            file { "${domU_infofile}":
                ensure  => 'file',
                replace => false,
                content => template("xen/info_domU.txt.erb"),
                require => Exec["xen_create_${domU_hostname}"]
            }

        }

        absent: {

            info("deleting Xen domU ${domU_hostname}")
            exec { "xen_delete_${domU_hostname}":
                path    => "/usr/bin:/usr/sbin:/bin:/sbin",
                command => "xen-delete-image --lvm ${xen::dom0::domU_lvm} ${domU_hostname}",
                onlyif  => "test -e /dev/mapper/${xen::dom0::domU_lvm}-${domU_hostname}--disk",
                unless  => "xm list | grep -e '^${domU_hostname} '",
                timeout => $timeout,
                require => [
                            Package['xen-tools'],
                            File["${xen::params::toolsdir}/xen-tools.conf"],
                            Exec["xen_shutdown_${domU_hostname}"]
                            ]
            }

            file { [ "${domU_configfile}", "${domU_snapshot_configfile}", "${domU_infofile}" ]:
                ensure  => "${ensure}",
                require => Exec["xen_delete_${domU_hostname}"]
            }

        }
    }

    # Store the access information (root password etc.)
    File["${domU_infofile}"]{
        owner   => 'root',
        group   => 'root',
        mode    => '0400',
    }

    # Stage two: deal with running/stopped VMs:
    case $ensure {

        running: {

            # Now run the VM
            exec { "xen_run_${domU_hostname}":
                path    => "/usr/bin:/usr/sbin:/bin:/sbin",
                command => "xm create ${domU_hostname}.cfg",
                unless  => "xm list | grep -e '^${domU_hostname} '",
                require => [
                            Exec["xen_create_${domU_hostname}"],
                            File["${xen::params::configfile}"],
                            Service['xen']
                            ]
            }

            # Only create this after a successful xm create. This way if the
            # creation makes the machine crash, it won't be starting
            # automatically and crashing the machine in a loop.
            file { "${xen::params::autodir}/${order}-${domU_hostname}":
                ensure  => 'link',
                target  => "${domU_configfile}",
                require => [
                            File["${xen::params::autodir}"],
                            File["${domU_configfile}"],
                            Exec["xen_run_${domU_hostname}"]
                            ]
            }
        }

        'present', 'stopped', 'absent': {

            # Shutdown the VM (first gracefully)
            exec { "xen_shutdown_${domU_hostname}":
                path    => "/usr/bin:/usr/sbin:/bin:/sbin",
                command => "xm shutdown -w ${domU_hostname}",
                onlyif  => "xm list | grep -e '^${domU_hostname} '",
                timeout => 60,
                notify  => Exec["xen_destroy_${domU_hostname}"],
                require => Service['xen']
            }
            # Shutdown the VM (more abruptly)
            exec { "xen_destroy_${domU_hostname}":
                path        => "/usr/bin:/usr/sbin:/bin:/sbin",
                command     => "xm destroy ${domU_hostname}",
                onlyif      => "xm list | grep -e '^${domU_hostname} '",
                refreshonly => true,
                require     => Service['xen']
            }

            # remove the symbolic link
            file { "${xen::params::autodir}/${order}-${domU_hostname}":
                ensure => 'absent',
                require => File["${xen::params::autodir}"]
            }

        }
    }

}






