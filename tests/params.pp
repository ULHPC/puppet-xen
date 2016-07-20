# File::      <tt>params.pp</tt>
# Author::    S. Varrette, H. Cartiaux, V. Plugaru, S. Diehl aka. UL HPC Management Team (hpc-sysadmins@uni.lu)
# Copyright:: Copyright (c) 2016 S. Varrette, H. Cartiaux, V. Plugaru, S. Diehl aka. UL HPC Management Team
# License::   Gpl-3.0
#
# ------------------------------------------------------------------------------
# You need the 'future' parser to be able to execute this manifest (that's
# required for the each loop below).
#
# Thus execute this manifest in your vagrant box as follows:
#
#      sudo puppet apply -t --parser future /vagrant/tests/params.pp
#
#

include 'xen::params'

$names = ["ensure", "bridge_on", "if_shared", "dom0_mem", "domU_use_pygrub", "domU_use_scsi", "domU_use_dhcp", "domU_order", "domU_vcpus", "domU_distrib", "domU_lvm", "domU_size", "domU_memory", "domU_swap", "domU_gateway", "domU_netmask", "domU_broadcast", "domU_arch", "domU_roles", "packagename", "kernel_package", "utils_packages", "servicename", "processname", "hasstatus", "hasrestart", "configdir", "configdir_mode", "configdir_owner", "configdir_group", "configfile", "configfile_mode", "configfile_owner", "configfile_group", "scriptsdir", "autodir", "toolsdir", "tools_logdir", "grubconfdir", "updategrub", "skeldir", "roledir"]

notice("xen::params::ensure = ${xen::params::ensure}")
notice("xen::params::bridge_on = ${xen::params::bridge_on}")
notice("xen::params::if_shared = ${xen::params::if_shared}")
notice("xen::params::dom0_mem = ${xen::params::dom0_mem}")
notice("xen::params::domU_use_pygrub = ${xen::params::domU_use_pygrub}")
notice("xen::params::domU_use_scsi = ${xen::params::domU_use_scsi}")
notice("xen::params::domU_use_dhcp = ${xen::params::domU_use_dhcp}")
notice("xen::params::domU_order = ${xen::params::domU_order}")
notice("xen::params::domU_vcpus = ${xen::params::domU_vcpus}")
notice("xen::params::domU_distrib = ${xen::params::domU_distrib}")
notice("xen::params::domU_lvm = ${xen::params::domU_lvm}")
notice("xen::params::domU_size = ${xen::params::domU_size}")
notice("xen::params::domU_memory = ${xen::params::domU_memory}")
notice("xen::params::domU_swap = ${xen::params::domU_swap}")
notice("xen::params::domU_gateway = ${xen::params::domU_gateway}")
notice("xen::params::domU_netmask = ${xen::params::domU_netmask}")
notice("xen::params::domU_broadcast = ${xen::params::domU_broadcast}")
notice("xen::params::domU_arch = ${xen::params::domU_arch}")
notice("xen::params::domU_roles = ${xen::params::domU_roles}")
notice("xen::params::packagename = ${xen::params::packagename}")
notice("xen::params::kernel_package = ${xen::params::kernel_package}")
notice("xen::params::utils_packages = ${xen::params::utils_packages}")
notice("xen::params::servicename = ${xen::params::servicename}")
notice("xen::params::processname = ${xen::params::processname}")
notice("xen::params::hasstatus = ${xen::params::hasstatus}")
notice("xen::params::hasrestart = ${xen::params::hasrestart}")
notice("xen::params::configdir = ${xen::params::configdir}")
notice("xen::params::configdir_mode = ${xen::params::configdir_mode}")
notice("xen::params::configdir_owner = ${xen::params::configdir_owner}")
notice("xen::params::configdir_group = ${xen::params::configdir_group}")
notice("xen::params::configfile = ${xen::params::configfile}")
notice("xen::params::configfile_mode = ${xen::params::configfile_mode}")
notice("xen::params::configfile_owner = ${xen::params::configfile_owner}")
notice("xen::params::configfile_group = ${xen::params::configfile_group}")
notice("xen::params::scriptsdir = ${xen::params::scriptsdir}")
notice("xen::params::autodir = ${xen::params::autodir}")
notice("xen::params::toolsdir = ${xen::params::toolsdir}")
notice("xen::params::tools_logdir = ${xen::params::tools_logdir}")
notice("xen::params::grubconfdir = ${xen::params::grubconfdir}")
notice("xen::params::updategrub = ${xen::params::updategrub}")
notice("xen::params::skeldir = ${xen::params::skeldir}")
notice("xen::params::roledir = ${xen::params::roledir}")

#each($names) |$v| {
#    $var = "xen::params::${v}"
#    notice("${var} = ", inline_template('<%= scope.lookupvar(@var) %>'))
#}
