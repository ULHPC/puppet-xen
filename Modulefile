name    'xen'
version '0.2.5'
source  'git-admin.uni.lu:puppet-repo.git'
author  'Hyacinthe Cartiaux (hyacinthe.cartiaux@uni.lu)'
license 'GPL v3'
summary      'Configure and manage the Xen'
description  'Configure and manage the Xen'
project_page 'UNKNOWN'

## List of the classes defined in this module
classes     'xen::dom0, xen::dom0::common, xen::dom0::debian, xen::params'
## List of the definitions defined in this module
definitions 'kernel, sysctl'

## Add dependencies, if any:
# dependency 'username/name', '>= 1.2.0'
dependency 'kernel' 
dependency 'sysctl' 
