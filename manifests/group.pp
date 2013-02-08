#
# This type declares a Unix group.
#
# This type is currently relatively simple and is only really used to ensure
# that GIDs and group names are only used once. One MUST NOT include group
# membership in these resources--declare that in the user resource instead.
# See the a::user definition for more information and recommendations for
# usage.
#
# @author Josh Endries
# @license BSD 3-Clause License
#   Read LICENSE.txt in the root directory of the distribution for details.
# @param ensure
#   Determines the state of existence of the group. Valid values are absent
#   and present.
# @param name
#   The name (title) should be in the format "<id> <name>". Both parts must
#   be unique within the catalog (i.e., in the Puppet configuration for the
#   node that is executing a Puppet run).
# @see a::user
#
define a::group (
	$ensure = present
) {
	#
	# Extract the GID number and name from the specified parameter.
	#
	$group_id = regsubst($title, ' .*$', '')
	$group_name = regsubst($title, '^.* ', '')
	
	
	
	#
	# Ensure that we have one, and only one, group with this GID number and
	# name.
	#
	a::group::id { $group_id: }
	a::group::name { $group_name: }

	
	
	#
	# Create the actual Unix group.
	#
	group { "$group_name":
		ensure => $ensure,
		gid => $group_id
	}
}
