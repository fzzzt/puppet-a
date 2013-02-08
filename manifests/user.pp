#
# The a::user type declares a user account.
#
# This type wraps the built-in Puppet user resource type and adds some common
# parameters and capabilities. One MUST include group membership in these
# resources--not in the group resources.
#
# @author Josh Endries
# @license BSD 3-Clause License
#   Read LICENSE.txt in the root directory of the distribution for details.
# @param comment
#   The account's GECOS value. The default value is an empty string.
# @param ensure
#   The state of existence for this account. Valid values are absent,
#   present or role. The default value is present.
# @param groups
#   A string of group names that the user belongs to. There is no default.
# @param home_owner
#   True or false. This governs whether or not Puppet will attempt to enforce
#   ownership on the user's home directory. Disabling this is useful when home
#   directories may be mounted via NFS. The default is true.
# @param name
#   The name (title) must be of the format "<id> <name>" where id is the UID
#   number and name is the account name (not the person's name). This
#   convention is used to ensure uniqueness and idempotency of both the UID
#   number and account name. In other words, this prevents you from also
#   creating an account with the same UID but a different name, or an account
#   with the same name but a different UID.
#
define a::user (
	$comment = '',
	$ensure = present,
	$groups = undef,
	$home = undef,
	$home_mode = undef,
	$home_owner = true,
	$password = '',
	$shell = undef,
) {
	#
	# Extract the UID number and account name from the specified parameter.
	#
	$user_id = regsubst($title, ' .*$', '')
	$user_name = regsubst($title, '^.* ', '')

	
	
	#
	# Ensure that we have one, and only one, group with this GID number and
	# name.
	#
	a::user::id { $user_id: }
	a::user::name { $user_name: }

	
	
	#
	# Create the actual Unix user account.
	#
	user {
		"$user_name":
			comment => $comment,
			ensure => $ensure,
			gid => $user_id,
			groups => $groups,
			home => $home,
			password => $password ? {
				'' => undef,
				default => $password,
			},
			require => [
				A::Group[$title],
			],
			shell => $shell,
			uid => $user_id,
	}



	#
	# Declare the "primary" group for this user.
	#
	a::group {
		"$title":
			ensure => $ensure,
	}



	#
	# Create the user's home directory--but only if the user is supposed to
	# be present. Otherwise, we simply skip this step, because we may or may
	# not want to delete the account's files (unknown to Puppet).
	#
	# TODO: Add a purge value to ensure that removes these files?
	#
	if ($ensure == 'present') {
		file { "/home/$user_name":
			ensure => directory,
			require => User["$user_name"],
			group => $home_owner ? {
				true => $user_name,
				false => undef,
			},
			owner => $home_owner ? {
				true => $user_name,
				false => undef,
			},
			mode => $home_mode,
		}
	}
}

