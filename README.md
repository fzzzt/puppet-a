A
=

A is an accounting module for Puppet that manages users and groups.

The name comes from AAA, the acronym for authorization, authentication and accounting.



Licensing
---------

This module is distributed using a 3-clause BSD license, which you can read in the LICENSE.txt file.



Description
-----------

This module consists of two main classes: a::user and a::group, which implement the concepts of users and groups, respectively (and amazingly!). The user class will create a user account _and_ a group with matching ID numbers, as is the tradition in Unix/Linux. The group class will similarly create a group with the specified ID number and name.

The names (titles) of user and group resources declared using these classes _must_ be of the format "_id_ _name_". This is used to ensure that both user names and ID numbers are unique. If you attempt to realize resources named "0 root", "1 root" and "0 toor", Puppet will throw a compilation exception. This is what the other classes are used for (a::user::id, a::user::name and the group equivalents).

It is recommended that all users and groups are declared (or at least referenced) in a single file/class. This helps prevent accidentally re-using a UID or GID number that has already been used by the primary groups. For example, declaring a user wiith a UID of 1000 "silently" creates a group with a GID of 1000 for that user's primary group. One wouldn't want to attempt to create a group with GID of 1000 elsewhere, because they would collide if an attempt was made to use them together (e.g. realizing virtual resources).

It is recommended to use virtual resources when declaring users and groups, and to realize them when necessary on systems (or in logical groups of people, support groups, etc.). This also makes it easy and convenient to override certain parameters (like home directory permissions) on certain systems or within certain groups, depending on security or workflow requirements.

Lastly, one MUST NOT declare group membership in the groups themselves. These relationships are declared in the user resources--NOT the group resources. This is due to the underlying capabilities of the drivers that Puppet uses to manage the groups.



Usage
-----

Declaring a (virtual) user is relatively straightforward. The following example specifies all the possible parameters. Note that group membership is specified in the user resource, and that the primary group is not listed in the user's group memberships:

    @a::user { '1000 foo':
    	comment => 'Foo Jenkins',
    	ensure => present,
    	groups => [ 'root', 'sneaky-peeps' ],
    	home => '/home2/fjenkertonrox',
    	home_mode => 0700,
    	home_owner => true,
    	password => '$1$87or43hy$9y8o56jo986y5jo986ydy65h6f$',
		shell => '/bin/bash',
    }

Elsewhere, this virtual resource would be realized. Below we realize it and make a couple changes for the environment:

    node freebsd {
    	...
		A::User <| title == '1000 foo' |> {
			groups +> 'wheel',
			shell => '/bin/sh',
		}
		...
    }

Groups are declared similarly, but groups are much simpler.

    a::group { '1234 new-hackers': }
    a::group { '4321 old-hackers': ensure => absent }

	

Contact
-------

https://www.endries.org/josh/contact