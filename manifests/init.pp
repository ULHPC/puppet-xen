# File::      init.pp
# Author::    Sebastien Varrette (Sebastien.Varrette@uni.lu)
# Copyright:: Copyright (c) 2011 Sebastien Varrette
# License::   GPLv3
#
# ------------------------------------------------------------------------------

import "classes/*.pp"
#import "definitions/*.pp"

# ------------------------------------------------------------------------------
# = Class: xen::common
#
# Base class to be inherited by xen::{dom0,domU}::common classes
#
# Note: respect the Naming standard provided here[http://projects.puppetlabs.com/projects/puppet/wiki/Module_Standards]
class xen::common {

    # Load the variables used in this module. Check the classes/xen-params.pp file
    require xen::params
   


}




