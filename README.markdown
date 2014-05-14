Mount Providers
===============

This module is designed to provide additional functionality and support the
native mount type inside of Puppet.  The module provides two additional
resource types not provided by Puppet core:

  * mountpoint
  * mounttab

Please see the output of `puppet describe mountpoint` and `puppet describe
mounttab` for more information about the types and providers supplied by this
module.

Installation
============

This module is installable from the Puppet Forge using the `puppet module` command.

    $ puppet module install puppetlabs-mount_providers

Source
======

 * [mount\_providers](https://github.com/waveclaw/puppetlabs-mount_providers)

Known Issues
============

This module will generate errors on AIX.

Puppet < 3.0.1 is unsupported. Puppet 2.7 should work but earlier will not 
due to the changes to a prefetch type.
