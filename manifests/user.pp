#
# The a::user type declares a user account.
#
# This type wraps the built-in Puppet user resource type and adds some common
# parameters and capabilities.
#
# @author Josh Endries
# @license BSD 3-Clause License
#   Read LICENSE.txt in the root directory of the distribution for details.
# @param comment
#   The account's GECOS value. The default value is an empty string.
# @param ensure
#   The state of existence for this account. Valid values are absent,
#   present or purged. The purged value removes the user account and deletes
#   the user's home directory. The default value is present.
# @param groups
#   An array of group names that the user belongs to. There is no default.
# @param home
#   The user's home directory. The default is "/user/${name}".
# @param home_mode
#   The mode of the home directory. Defaults to undef.
# @param home_owner
#   True or false. This governs whether or not Puppet will attempt to enforce
#   ownership on the user's home directory. Disabling this is useful when home
#   directories may be mounted via NFS. The default is true.
# @param id
#   The user's ID number (UID). This parameter is required.
# @param name
#   The resource name (title) is the name of the user account (and primary
#   group, if applicable).
# @param password
#   The user's encrypted password. The default undef.
# @param shell
#   The user's login shell. The default is undef.
#
define a::user (
	$comment = '',
	$ensure = present,
	$groups = undef,
	$home = '',
	$home_mode = undef,
	$home_owner = true,
	$id,
	$password = undef,
	$shell = undef,
) {
	#
	# Sanititze the inputs.
	#
	$user_id = $id
	$user_name = $name
	$home_real = $home ? {
		'' => "/home/${user_name}",
		default => $home,
	}

	
	
	#
	# Create the actual Unix user account.
	#
	user {
		$user_name:
			comment => $comment,
			ensure => $ensure,
			gid => $user_id,
			groups => $groups,
			home => $home_real,
			password => $password,
			require => $group ? {
				true => Group[$user_name],
				false => undef
			},
			shell => $shell,
			uid => $user_id,
	}



	#
	# Declare the "primary" group for this user.
	#
	group { $user_name:
		ensure => $ensure ? {
			purged => absent,
			default => $ensure
		},
		gid => $id,
	}



	#
	# Create the user's home directory if the user is supposed to be present
	# or delete it if the user is supposed to be purged.
	#
	case $ensure {
		present: {
			file { $home_real:
				ensure => directory,
				group => $home_owner ? {
					true => $user_name,
					false => undef,
				},
				mode => $home_mode,
				owner => $home_owner ? {
					true => $user_name,
					false => undef,
				},
				require => User[$user_name],
			}
		}
		purged: {
			file { $home_real:
				ensure => absent,
				force => true,
			}
		}
	}
}

