-*- mode: markdown; mode: visual-line;  -*-

# Xen Puppet Module 

[![Puppet Forge](http://img.shields.io/puppetforge/v/ULHPC/xen.svg)](https://forge.puppetlabs.com/ULHPC/xen)
[![License](http://img.shields.io/:license-GPL3.0-blue.svg)](LICENSE)
![Supported Platforms](http://img.shields.io/badge/platform-debian-lightgrey.svg)
[![Documentation Status](https://readthedocs.org/projects/ulhpc-puppet-xen/badge/?version=latest)](https://readthedocs.org/projects/ulhpc-puppet-xen/?badge=latest)

Configure and manage Xen

      Copyright (c) 2017 UL HPC Team <hpc-sysadmins@uni.lu>
      

| [Project Page](https://github.com/ULHPC/puppet-xen) | [Sources](https://github.com/ULHPC/puppet-xen) | [Documentation](https://ulhpc-puppet-xen.readthedocs.org/en/latest/) | [Issues](https://github.com/ULHPC/puppet-xen/issues) |

## Synopsis

Configure and manage Xen.

This module implements the following elements: 

* __Puppet classes__:
    - `xen` 
    - `xen::common` 
    - `xen::common::debian` 
    - `xen::params` 

* __Puppet definitions__: 
    - `xen::domu` 
    - `xen::network::bridge` 

All these components are configured through a set of variables you will find in
[`manifests/params.pp`](manifests/params.pp). 

_Note_: the various operations that can be conducted from this repository are piloted from a [`Rakefile`](https://github.com/ruby/rake) and assumes you have a running [Ruby](https://www.ruby-lang.org/en/) installation.
See `docs/contributing.md` for more details on the steps you shall follow to have this `Rakefile` working properly. 

## Dependencies

See [`metadata.json`](metadata.json). In particular, this module depends on 

* [puppetlabs/stdlib](https://forge.puppetlabs.com/puppetlabs/stdlib)
* [puppetlabs/apt](https://forge.puppetlabs.com/puppetlabs/apt)
* [ULHPC/kernel](https://forge.puppetlabs.com/ULHPC/kernel)
* [ULHPC/sysctl](https://forge.puppetlabs.com/ULHPC/sysctl)
* [ULHPC/network](https://forge.puppetlabs.com/ULHPC/network)

## Overview and Usage

### Class `xen`

This is the main class defined in this module.
It accepts the following parameters: 

* `$ensure`: default to 'present', can be 'absent'

Use it as follows:

     include ' xen'

See also [`tests/init.pp`](tests/init.pp)


### Definition `xen::domu`

The definition `xen::domu` provides ...
This definition accepts the following parameters:

* `$ensure`: default to 'present', can be 'absent'
* `$content`: specify the contents of the directive as a string
* `$source`: copy a file as the content of the directive.

Example:

        xen::domu { 'toto':
		      ensure => 'present',
        }

See also [`tests/domu.pp`](tests/domu.pp)

### Definition `xen::network::bridge`

The definition `xen::network::bridge` provides ...
This definition accepts the following parameters:

* `$ensure`: default to 'present', can be 'absent'
* `$content`: specify the contents of the directive as a string
* `$source`: copy a file as the content of the directive.

Example:

        xen::network::bridge { 'toto':
		      ensure => 'present',
        }

See also [`tests/network/bridge.pp`](tests/network/bridge.pp)


## Librarian-Puppet / R10K Setup

You can of course configure the xen module in your `Puppetfile` to make it available with [Librarian puppet](http://librarian-puppet.com/) or
[r10k](https://github.com/adrienthebo/r10k) by adding the following entry:

     # Modules from the Puppet Forge
     mod "ULHPC/xen"

or, if you prefer to work on the git version: 

     mod "ULHPC/xen", 
         :git => 'https://github.com/ULHPC/puppet-xen',
         :ref => 'production' 

## Issues / Feature request

You can submit bug / issues / feature request using the [ULHPC/xen Puppet Module Tracker](https://github.com/ULHPC/puppet-xen/issues). 

## Developments / Contributing to the code 

If you want to contribute to the code, you shall be aware of the way this module is organized. 
These elements are detailed on [`docs/contributing.md`](contributing/index.md).

You are more than welcome to contribute to its development by [sending a pull request](https://help.github.com/articles/using-pull-requests). 

## Puppet modules tests within a Vagrant box

The best way to test this module in a non-intrusive way is to rely on [Vagrant](http://www.vagrantup.com/).
The `Vagrantfile` at the root of the repository pilot the provisioning various vagrant boxes available on [Vagrant cloud](https://atlas.hashicorp.com/boxes/search?utf8=%E2%9C%93&sort=&provider=virtualbox&q=svarrette) you can use to test this module.

See [`docs/vagrant.md`](vagrant.md) for more details. 

## Online Documentation

[Read the Docs](https://readthedocs.org/) aka RTFD hosts documentation for the open source community and the [ULHPC/xen](https://github.com/ULHPC/puppet-xen) puppet module has its documentation (see the `docs/` directly) hosted on [readthedocs](http://ulhpc-puppet-xen.rtfd.org).

See [`docs/rtfd.md`](rtfd.md) for more details.

## Licence

This project and the sources proposed within this repository are released under the terms of the [GPL-3.0](LICENCE) licence.


[![Licence](https://www.gnu.org/graphics/gplv3-88x31.png)](LICENSE)
