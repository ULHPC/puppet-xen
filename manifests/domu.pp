# File::      <tt>xen-domu.pp</tt>
# Author::    Sebastien Varrette (<Sebastien.Varrette@uni.lu>)
# Copyright:: Copyright (c) 2012 Sebastien Varrette (www[http://varrette.gforge.uni.lu])
# License::   GPLv3
#
# ------------------------------------------------------------------------------
# = Defines: xen::domu
#
# Configure and install a Xen guest (domu in teh Xen terminology) on the Xen dom0
#
# == Pre-requisites
#
# * The class "xen::dom0" should have been instanciated.
#
# == Parameters:
#
# [*ensure*]
#   default to 'present', can be 'absent' or 'stopped'. The stopped status
#   will shutdown the domu and ensure the symbolic link in /etc/xen/auto/ is
#   removed.
#   Default: 'present'
#
#
# [*password*]
#   password of the root on the domu to be created. If left to an empty string,
#   a random password will be generated (and stored in the accessfile)
#
# [*accessfile*]
#   The file used to save the access configuration (including root password) for
#   the created VM.
#   Default to /etc/xen/.credentials_<domuname>.cnf

# == Sample usage:
#
#     import xen::domu
#
# You can then specialize the various aspects of the configuration,
# for instance:
#
#      xen::domu{ 'myhost':
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
define xen::domu (
    $ensure     = $xen::params::ensure,
    $order      = $xen::params::domu_order,
    $use_pygrub = $xen::params::domu_use_pygrub,
    $use_scsi   = $xen::params::domu_use_scsi,
    $use_dhcp   = $xen::params::domu_use_dhcp,
    $vcpus      = $xen::params::domu_vcpus,
    $distrib    = $xen::params::domu_dist,
    $size       = $xen::params::domu_size,
    $ramsize    = $xen::params::domu_memory,
    $swap       = $xen::params::domu_swap,
    $roles      = $xen::params::domu_roles,
    $gateway    = '',
    $netmask    = '',
    $broadcast  = '',
    $arch       = $xen::params::domu_arch,
    $desc       = '',
    $do_force   = false,
    $ip         = '',
    $bridge     = '',
    $mac        = '',
    $infofile   = '',
    $password   = '',
    $timeout    = 3600
)
{
    include ::xen::params

    # $name is provided at define invocation
    $domu_hostname = $name

    $domu_configfile          = "${xen::params::configdir}/${domu_hostname}.cfg"
    $domu_snapshot_configfile = "${xen::params::configdir}/${domu_hostname}-snapshot.cfg"

    $domu_infofile = $infofile ? {
        ''      => "${xen::params::configdir}/info_${domu_hostname}.txt",
        default => $infofile
    }
    $root_passwd = $password ? {
        ''      => chomp(generate('/usr/bin/pwgen', '--secure', 12, 1)),
        default => $password
    }

    $dist = $distrib ? {
        ''      => $::lsbdistcodename,
        default => $distrib
    }

    if ($domu_hostname == '') {
        fail('Cannot create Xen domain with empty name')
    }

    # Check the presence of the xen class
    if !defined(Class['xen']) {
        fail('The Puppet class xen is not instanciated')
    }

    info ("Configuring xen::domu for ${domu_hostname} (with ensure = ${ensure})")

    $authorized_ensure = [ 'present', 'absent', 'running', 'stopped' ]


    if ! ($ensure in $authorized_ensure) {
        fail("xen::domu 'ensure' parameter must be set to either 'present', 'absent', 'running', 'stopped'")
    }

    if ($xen::ensure != $ensure) {
        if ($xen::ensure != 'present') {
            fail("Cannot configure a xen DomU '${domu_hostname}' as xen::ensure is NOT set to present (but ${xen::ensure})")
        }
    }

    # Collect the domu specific values
    $domu_gateway = $gateway ? {
        ''      => $xen::domu_gateway,
        default => $gateway
    }
    $domu_netmask = $netmask ? {
        ''      => $xen::domu_netmask,
        default => $netmask
    }
    $domu_broadcast = $broadcast ? {
        ''      => $xen::domu_broadcast,
        default => $broadcast
    }
    $domu_arch = $arch ? {
        ''      => $xen::domu_arch,
        default => $arch
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
    $real_roles = concat($roles, 'motd')

    $motd_netinfo = $ip ? {
        '' => $use_dhcp ? {
            true    => 'IP: via DHCP',
            default => ''
        },
        default => "IP: ${ip}"
    }

    $motd_role_args = "--role-args=\"--motd_hostname '${domu_hostname}' --motd_domain '${::domain}' --motd_msg1 '${desc}' --motd_netinfo '${motd_netinfo}' --motd_vcpus ${vcpus} --motd_ramsize '${ramsize}' --motd_swapsize '${swap}' --motd_rootsize '${size}'\""

    $opt_role = $real_roles ? {
        ''      => '',
        default => inline_template("--role=<%= @real_roles.join(',') %> ${motd_role_args}")
    }

    $opt_dist = $distrib ? {
        ''      => '',
        default => "--dist=${distrib}"
    }
    $opt_install_method = $distrib ? {
        'centos-6' => '--install-method=rinse',
        default    => ''
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
    $opt_bridge = $xen::bridge_on ? {
        ''      => '',
        default => "--bridge=${bridge}"
    }
    $opt_mac = $mac ? {
        ''      => '',
        default => "--mac=${mac}"
    }
    $opt_netmask = $domu_netmask ? {
        ''      => '',
        default => "--netmask=${domu_netmask}"
    }
    $opt_broadcast = $domu_broadcast ? {
        ''      => '',
        default => "--broadcast=${domu_broadcast}"
    }
    $opt_gateway = $domu_gateway ? {
        ''      => '',
        default => "--gateway=${domu_gateway}"
    }
    # The complete network configuration option
    $opt_network_config = $ip ? {
        ''      => $opt_dhcp,
        default => "${opt_bridge} ${opt_ip} ${opt_netmask} ${opt_broadcast} ${opt_gateway}"
    }

    # The final command
    $xen_create_image_cmd = "xen-create-image ${opt_force} ${opt_scsi} ${opt_pygrub} --arch ${domu_arch} --vcpus ${vcpus} --host ${domu_hostname} ${opt_dist} ${opt_install_method} --size=${size} ${opt_swap} --memory=${ramsize} ${opt_role} ${opt_network_config} --genpass=0 --password='${root_passwd}' ${opt_install_method}"


    # stage one: ensure the domu exists
    if ($ensure in ['present', 'running', 'stopped']) {

       exec { "xen_create_${domu_hostname}":
           path    => '/usr/bin:/usr/sbin:/bin:/sbin',
           command => $xen_create_image_cmd,
           #creates => "/dev/mapper/${xen::domu_lvm}-${domu_hostname}--disk",
           creates => $domu_configfile,
           timeout => $timeout,
           require => [
                       File[$xen::params::configdir],
                       File["${xen::params::toolsdir}/xen-tools.conf"]
                       ],
       }
       # this should have created /etc/xen/${domu_hostname}.cfg
       file { $domu_configfile:
           ensure  => 'file',
           owner   => $xen::params::configfile_owner,
           group   => $xen::params::configfile_group,
           mode    => '0644',
           require => [
                       Package['xen'],
                       Package[$xen::params::kernel_package],
                       File[$xen::params::configdir],
                       Exec["xen_create_${domu_hostname}"]
                       ],
       }

       exec { "Adapting ${domu_snapshot_configfile}":
           command => "sed 's/${xen::domu_lvm}\\/${domu_hostname}-disk/${xen::domu_lvm}\\/${domu_hostname}-snapshot-disk/' ${domu_configfile} >  ${domu_snapshot_configfile}",
           path    => '/usr/bin:/usr/sbin:/bin:/sbin',
           user    => $xen::params::configfile_owner,
           group   => $xen::params::configfile_group,
           require => File[$domu_configfile],
       }

       file { $domu_infofile:
           ensure  => 'file',
           replace => false,
           content => template('xen/info_domu.txt.erb'),
           require => Exec["xen_create_${domu_hostname}"],
       }

    } elsif ($ensure == 'absent') {

       info("deleting Xen domu ${domu_hostname}")
       exec { "xen_delete_${domu_hostname}":
           path    => '/usr/bin:/usr/sbin:/bin:/sbin',
           command => "xen-delete-image --lvm ${xen::domu_lvm} ${domu_hostname}",
           onlyif  => "test -e /dev/mapper/${xen::domu_lvm}-${domu_hostname}--disk",
           unless  => "${xen::params::toolstack} list | grep -e '^${domu_hostname} '",
           timeout => $timeout,
           require => [
                       Package['xen-tools'],
                       File["${xen::params::toolsdir}/xen-tools.conf"],
                       Exec["xen_shutdown_${domu_hostname}"]
                       ],
       }

       file { [ $domu_configfile, $domu_snapshot_configfile, $domu_infofile ]:
           ensure  => $ensure,
           require => Exec["xen_delete_${domu_hostname}"],
       }

    }

    # Store the access information (root password etc.)
    File[$domu_infofile]{
        owner   => 'root',
        group   => 'root',
        mode    => '0400',
    }

    # Stage two: deal with running/stopped VMs:
    if ($ensure == 'running') {

        # Now run the VM
        exec { "xen_run_${domu_hostname}":
            path    => '/usr/bin:/usr/sbin:/bin:/sbin',
            command => "${xen::params::toolstack} create ${domu_hostname}.cfg",
            cwd     => $xen::params::configdir,
            unless  => "${xen::params::toolstack} list | grep -e '^${domu_hostname} '",
            require => [
                        Exec["xen_create_${domu_hostname}"],
                        File[$xen::params::configfile],
                        Service['xen']
                        ],
        }

        # Only create this after a successful ${xen::params::toolstack} create. This way if the
        # creation makes the machine crash, it won't be starting
        # automatically and crashing the machine in a loop.
        file { "${xen::params::autodir}/${order}-${domu_hostname}":
            ensure  => 'link',
            target  => $domu_configfile,
            require => [
                        File[$xen::params::autodir],
                        File[$domu_configfile],
                        Exec["xen_run_${domu_hostname}"]
                        ],
        }

    }
    elsif ($ensure in ['present', 'stopped', 'absent'] {

        # Shutdown the VM (first gracefully)
        exec { "xen_shutdown_${domu_hostname}":
            path    => '/usr/bin:/usr/sbin:/bin:/sbin',
            command => "${xen::params::toolstack} shutdown -w ${domu_hostname}",
            onlyif  => "${xen::params::toolstack} list | grep -e '^${domu_hostname} '",
            timeout => 60,
            notify  => Exec["xen_destroy_${domu_hostname}"],
            require => Service['xen'],
        }
        # Shutdown the VM (more abruptly)
        exec { "xen_destroy_${domu_hostname}":
            path        => '/usr/bin:/usr/sbin:/bin:/sbin',
            command     => "${xen::params::toolstack} destroy ${domu_hostname}",
            onlyif      => "${xen::params::toolstack} list | grep -e '^${domu_hostname} '",
            refreshonly => true,
            require     => Service['xen'],
        }

        # remove the symbolic link
        file { "${xen::params::autodir}/${order}-${domu_hostname}":
            ensure  => 'absent',
            require => File[$xen::params::autodir],
        }

    }

}






