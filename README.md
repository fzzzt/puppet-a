A
=

A is an accounting module for Puppet that manages users and groups.

The name comes from AAA, the acronym for authorization, authentication and accounting.



Licensing
---------

This module is distributed using a 3-clause BSD license, which you can read in the LICENSE.txt file.



Description
-----------

TODO:

Difference from built-in user resource:

1. Splits home creation/ownership and deletion (purge), unlike managehome.
2. New ensure value 'purge', absent+home deletion.
3. Supports creating one SSH key in-line.
4. Supports changing file ownership on ensure => absent (so another user with same UID doesn't magically own them).



This module consists of two main classes: a::user and a::group, which implement the concepts of users and groups, respectively (and amazingly!). The user class will create a user account _and_ a group with matching ID numbers, as is the tradition in Unix/Linux. The group class will similarly create a group with the specified ID number and name.

This module uses a convention to enforce what is called a "single global view" of all accounting resource ID numbers. This means that, with the notable exception of a user's primary group, a group and user can _not_ use the same ID number. For example, one can _not_ declare both a user named "foo" with a UID number of 100 and a group named "bar" with a GID number of 100--because having two account resources with the same ID number (100) violates this "single global view". The convention is simple: both the ID number and name are present in the resource title, delimited by a single space (see Usage for examples).

It is recommended that all users and groups are declared (or at least referenced) in a single file/class. This helps prevent accidentally re-using a UID or GID number that has already been used by the primary groups. For example, declaring a user wiith a UID of 1000 "silently" creates a group with a GID of 1000 for that user's primary group. One wouldn't want to attempt to create a group with GID of 1000 elsewhere, because they would collide if an attempt was made to use them together (e.g. realizing virtual resources).

It is recommended to use virtual resources when declaring users and groups, and to realize them when necessary on systems (or in logical groups of people, support groups, etc.). This also makes it easy and convenient to override certain parameters (like home directory permissions) on certain systems or within certain groups, depending on security or workflow requirements.

Lastly, one MUST NOT declare group membership in the groups themselves. These relationships are declared in the user resources--NOT the group resources. This is due to the underlying capabilities of the drivers that Puppet uses to manage the groups.



Requirements
------------

This module requires no additional Puppet funtionality.



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

	
	
Single Global View
------------------



TO-DO: Test and make sure that you CANT specify two user{} with the same ID. Maybe this is really better done with user_name==title, and UID specified separately, e.g. so I can have one list for SC and one for e.o? Somehow enforce a "user list" class instead? Maybe using the ::id and ::name are still good (e.g. if you can specify two user{} with the same ID)?




There exists a problem where, if the title is only the name or ID number, one can declare multiple virtual resources with the same name _or_ ID number (whichever part is _not_ in the resource title). For example:

@a::user { 'foo': id => 1000 }
@a::user { 'bar': id => 1000 }

This will compile fine, and only error out if _both_ users are realized on the same node. This is true even if one uses resources within the a::user definition to enforce uniqueness (e.g. `a::user::id { $id: }`). Flipping this around results in the same problem:

@a::user { 1000: name => 'foo' }
@a::user { 1001: name => 'foo' }

Technically, this is correct--this is what virtual resources are designed for. However, in the case of user accounts and groups, I have never came across a situation where I needed to vary the name of a user or group while keeping the same ID number, for example needing user 'tomcat' to have ID 1000 on one machine but 1005 on another machine--that way lies madness. As such, I view this as a problem rather than a feature (in this case).

The only way around this that I could think of (within my limited attention span), or perhaps the easiest way, was to include both the name and ID number components in the resource title. The resource title must be unique, so putting both components (which must also be unique) in the title seems perfect.

	

Contact
-------

https://www.endries.org/josh/contact