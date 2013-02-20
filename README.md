A
=

A is an accounting module for Puppet that manages user accounts and their group membership. The name comes from AAA, the acronym for authorization, authentication and accounting.



Licensing
---------

This module is distributed using a 3-clause BSD license, which you can read in the LICENSE.txt file.



Description
-----------

This module essentially wraps the built-in Puppet module and adds some extra capabilities:

1. Manages primary groups with the user.
2. Allows finer-grained control over the user's home directory.

It is recommended that all users and groups are declared (or at least referenced) in a single file. This helps prevent accidentally re-using a UID number with another user account, or re-using a GID number that has already been used by a primary group or another group. While technically possible when using virtual resources (also recommended), declaring multiple users or groups with the same ID number allows for the situation where one attempts to realize two users with the same ID number on the same node.

It is recommended to use virtual resources when declaring users and groups, and to realize them when necessary on systems (or in logical groups of people, support groups, etc.). This also makes it easy and convenient to override certain parameters (like home directory permissions) on certain systems or within certain groups, depending on security or workflow requirements.



Requirements
------------

This module requires no additional Puppet funtionality.



Usage
-----

Declaring a (virtual) user is relatively straightforward. The following example specifies all the possible parameters. Note that group membership is specified in the user resource, and that the primary group is not listed in the user's group memberships:

    @a::user { 'foo':
    	comment => 'Foo Jenkins',
    	ensure => present,
    	groups => [ 'root', 'sneaky-peeps' ],
    	home => '/home2/fjenkertonrox',
    	home_mode => 0700,
    	home_owner => true,
		id => 1000,
    	password => '$1$87or43hy$9y8o56jo986y5jo986ydy65h6f$',
		shell => '/bin/bash',
    }

Elsewhere, this virtual resource would be realized. Below we realize it and make a couple changes for the environment:

    node freebsd {
    	...
		A::User <| title == 'foo' |> {
			groups +> 'wheel',
			shell => '/bin/sh',
		}
		...
    }

	

Contact
-------

https://www.endries.org/josh/contact