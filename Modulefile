name    'xen'
version '0.1.0'
source  'git-admin.uni.lu:puppet-repo.git'
author  'Sebastien Varrette (Sebastien.Varrette@uni.lu)'
license 'GPL v3'
summary      'Configure and manage the Xen'
description  'Configure and manage the Xen'
project_page 'UNKNOWN'

## List of the classes defined in this module
classes     'xen::common, xen::dom0, xen::dom0::common, xen::dom0::debian, xen::dom0::redhat, xen::params'
## List of the definitions defined in this module
definitions 'sysctl'

## Add dependencies, if any:
# dependency 'username/name', '>= 1.2.0'
dependency 'sysctl' 
