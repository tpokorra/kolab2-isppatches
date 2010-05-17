package Kolab;

##  COPYRIGHT
##  ---------
##
##  See AUTHORS file
##
##
##  LICENSE
##  -------
##
##  This  program is free  software; you can redistribute  it and/or
##  modify it  under the terms of the GNU  General Public License as
##  published by the  Free Software Foundation; either version 2, or
##  (at your option) any later version.
##
##  This program is  distributed in the hope that it will be useful,
##  but WITHOUT  ANY WARRANTY; without even the  implied warranty of
##  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
##  General Public License for more details.
##
##  You can view the  GNU General Public License, online, at the GNU
##  Project's homepage; see <http://www.gnu.org/licenses/gpl.html>.
##
##  $Revision: 1.1 $

use 5.008;
use strict;
use warnings;
use Sys::Syslog;
use URI;
use Net::LDAP;
use Kolab::Util;
#use Kolab::LDAP;
use vars qw(%config $reloadOk);

require Exporter;

our @ISA = qw(Exporter);

our %EXPORT_TAGS = (
    'all' => [ qw(
        %config
	$reloadOk
        &reloadConfig
        &reload
        &log
    ) ]
);

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw(
    &KOLAB_SILENT
    &KOLAB_ERROR
    &KOLAB_WARN
    &KOLAB_INFO
    &KOLAB_DEBUG
);

# The Kolab version number for the perl-kolab package
our $KOLAB_BASE_VERSION = "2.2.3";

# Are current releases cvs based or is this a real release?
my $KOLAB_CVS = 1;

our $KOLAB_RELEASE = sprintf "%0004d%02d%02d", ((gmtime)[5] + 1900), ((gmtime)[4] + 1), (gmtime)[3];

if ($KOLAB_CVS) {
    our $KOLAB_VERSION = $KOLAB_BASE_VERSION . "+cvs";
    our $VERSION = $KOLAB_VERSION . $KOLAB_RELEASE;
} else {
    our $KOLAB_VERSION = $KOLAB_BASE_VERSION;
    our $VERSION = $KOLAB_VERSION;
}

sub KOLAB_SILENT()      { 0 }
sub KOLAB_ERROR()       { 1 }
sub KOLAB_WARN()        { 2 }
sub KOLAB_INFO()        { 3 }
sub KOLAB_DEBUG()       { 4 }

sub reloadConfig
{
    my $kolab_globals = shift;
    my $globals_only = shift || 0;

    my $tempval;
    my $ldap;

    my $error = 0;

    # `log_level' specifies what severity of messages we want to see in the logs.
    #   Possible values are:
    #     0 - Silent
    #     1 - Errors
    #     2 - Warnings & Errors
    #     3 - Info, Warnings & Errors       (DEFAULT)
    #     4 - Debug (i.e. everything)

    # First read `kolab.globals'
    %config = readConfig(%config, $kolab_globals);

    # Return if we should only read the base information.
    if ($globals_only) {
	return;
    }

    # Determine the root of the kolab installation, and read `kolab.globals'
    # Notice that the location of the files is handled by dist_conf,
    # so we don't use $tempval for anything other than storing it in
    # $config{'prefix'}. Once prefix is not in use anywhere, we can remove
    # this code. /steffen
    $tempval = (getpwnam($config{'kolab_musr'}))[7];
    if (! defined $tempval) {
        $config{'log_level'} = KOLAB_WARN;
        &log('C', 'Unable to determine the kolab user main directory', KOLAB_ERROR);	
	$error = 1;
    }

    # Now read `kolab.conf', overwriting values read from `kolab.globals'
    %config = readConfig(\%config, $config{'kolab_locals'});

    $config{'debug'} = 0 if (!exists $config{'debug'});
    $config{'log_level'} = KOLAB_WARN if (!exists $config{'log_level'});

    &log('C', 'Reloading configuration');

    # Get the UID/GID of the 'kolab' users
    $config{'kolab_uid'} = (getpwnam($config{'kolab_musr'}))[2];
    if (!defined $config{'kolab_uid'}) {
        &log('C', "Unable to determine the uid of user '$config{'kolab_musr'}'", KOLAB_ERROR);
	$error = 1;
    }

    $config{'kolab_gid'} = (getgrnam($config{'kolab_mgrp'}))[2];
    if (!defined $config{'kolab_gid'}) {
        &log('C', "Unable to determine the gid of user '$config{'kolab_mgrp'}'", KOLAB_ERROR);
	$error = 1;
    }

    $config{'kolab_n_uid'} = (getpwnam($config{'kolab_usr'}))[2];
    if (!defined $config{'kolab_n_uid'}) {
        &log('C', "Unable to determine the uid of user '$config{'kolab_usr'}", KOLAB_ERROR);
	$error = 1;
    }

    $config{'kolab_n_gid'} = (getgrnam($config{'kolab_grp'}))[2];
    if (!defined $config{'kolab_n_gid'}) {
        &log('C', "Unable to determine the gid of user $config{'kolab_grp'}", KOLAB_ERROR);
	$error = 1;
    }

    $config{'kolab_r_uid'} = (getpwnam($config{'kolab_rusr'}))[2];
    if (!defined $config{'kolab_r_uid'}) {
        &log('C', "Unable to determine the uid of user '$config{'kolab_rusr'}'", KOLAB_ERROR);
	$error = 1;
    }

    $config{'kolab_r_gid'} = (getgrnam($config{'kolab_rgrp'}))[2];
    if (!defined $config{'kolab_r_gid'}) {
        &log('C', "Unable to determine the gid of user '$config{'kolab_rgrp'}'", KOLAB_ERROR);
	$error = 1;
    }

    # Make sure the critical variables we need were defined in kolab.conf
    if (!exists $config{'bind_dn'} || !exists $config{'bind_pw'} || !exists $config{'ldap_uri'} || !exists $config{'base_dn'}) {
        &log('C', "One or more required configuration variables (`bind_dn', `bind_pw', `ldap_uri' and/or `base_dn') are missing in `kolab.conf'", KOLAB_ERROR);
	$error = 1;
    }

    # Make a hash of the bind password available too
    if( !exists $config{'bind_pw_hash'} ) {
      my $hashcmd = $config{'hashmethod'} . " '".$config{'bind_pw'}."'";
      $config{'bind_pw_hash'} = `$hashcmd`;
      chomp($config{'bind_pw_hash'});
    }

    # Retrieve the LDAP values of the main kolab object to complete our config hash
    if (!($tempval = URI->new($config{'ldap_uri'}))) {
        &log('C', "Unable to parse ldap_uri `" . $config{'ldap_uri'} . "'", KOLAB_ERROR);
	$error = 1;
    } else {
        $config{'ldap_ip'} = $tempval->host;
        $config{'ldap_port'} = $tempval->port;
    }

    # `kolab_dn' points to the main kolab object in LDAP
    #   Defaults to `k=kolab,$base_dn' if not specified (for backwards compatibility)
    $config{'kolab_dn'} = "k=kolab," . $config{'base_dn'} if (!exists $config{'kolab_dn'});
    if ($config{'kolab_dn'} eq '') {
        &log('C', "`kolab_dn' is empty; skipping LDAP read");
    } else {
        my $mesg;
        my $ldapobject;

        if (!($ldap = Net::LDAP->new($config{'ldap_uri'}, verify => 'none' ))) {
            &log('C', "Unable to connect to LDAP server `" . $config{'ldap_ip'} . ":" . $config{'ldap_port'} . "'", KOLAB_ERROR);
	    $error = 1;
        }

        $mesg = $ldap->bind($config{'bind_dn'}, password => $config{'bind_pw'}) if $ldap;
        if ($ldap && $mesg->code) {
            &log('C', "Unable to bind to DN `" . $config{'bind_dn'} . "'", KOLAB_ERROR);
	    $error = 1;
        }

        #$ldap = Kolab::LDAP::create(
        #    $config{'ldap_ip'},
        #    $config{'ldap_port'},
        #    $config{'bind_dn'},
        #    $config{'bind_pw'},
        #    1
        #);
        if ($ldap) {
            $mesg = $ldap->search(
                base    => $config{'kolab_dn'},
                scope   => 'base',
                filter  => '(objectclass=*)'
            );
            if (!$mesg->code) {
                $ldapobject = $mesg->pop_entry;
                foreach $tempval ($ldapobject->attributes) {
		    my $vals = $ldapobject->get_value($tempval, asref => 1 );
		    if( !ref($vals) ) {
		      # Not a ref at all???
		      &log('C', "Attribute $tempval does not exist", KOLAB_WARN );
		    } elsif( @{$vals} == 1 ) {
		      $config{lc($tempval)} = $vals->[0];
		    } else {
		      $config{lc($tempval)} = $vals;
		    }
                }
            } else {
                &log('C', "Unable to find kolab object `" . $config{'kolab_dn'} . "'", KOLAB_ERROR);
#                exit(1);
		$error = 1;
            }
        } else {
            &log('C', "Unable to read configuration data from LDAP", KOLAB_WARN);
        }
    }

    # At this point we have read in all user-specified configuration variables.
    # We now need to go through the list of all possible configuration variables
    # and set the default values of those that were not overridden.

    $config{'fqdn'} = trim(`hostname`);

    # connect to services at local address if binding to any interface,
    # otherwise use the address specified for the public interface.
    if ($config{'bind_any'} =~ /true/i) {
        $config{'connect_addr'} = $config{'local_addr'};
    } else {
        $config{'connect_addr'} = $config{'bind_addr'};
    }

    # Cyrus admin account
    $tempval = $config{'cyrus-admin'} || 'manager';
    (my $cmanager, my $dummy) = split(/ /, $tempval, 2);
    $config{'cyrus_admin'} = $cmanager if (!exists $config{'cyrus_admin'});
    $config{'cyrus_admin_pw'} = $config{'bind_pw'} if (!exists $config{'cyrus_admin_pw'});

    # `directory_mode' specifies what backend to use (for the main kolab
    # object - for the other objects see their respective XXX_directory_mode).
    # Defaults to `slurpd'
    #
    #   NOTE: A plugin scheme is used for this; the backend module loaded
    #   is `Kolab::LDAP::$config{'directory_mode'}, so anyone is able to slot
    #   in a new Kolab::LDAP:: module, change `directory_mode' and have the new
    #   module used as a backend (as long as it conforms to the correct
    #   interface, that is).
    #
    #   Currently supported backends:
    #     slurpd: for OpenLDAP 2.3.x and prior versions
    #     syncrepl: for OpenLDAP 2.3.x and beyond
    #     fds: Fedora Directory Server
    #     ad: Microsoft Active Directory
    $config{'directory_mode'} = 'slurpd' if (!exists $config{'directory_mode'});
    $config{'directory_replication_mode_is_syncrepl'} = 'TRUE' if ($config{'directory_mode'} eq 'syncrepl');
    if (($config{'directory_mode'} eq 'syncrepl') && !defined $config{'syncrepl_cookie_file'}) {
        &log('C', "Configuration variable `syncrepl_cookie_file' is missing ".
            "in `kolab.globals' or `kolab.globals' while using `syncrepl' directory_mode", KOLAB_ERROR);
	    $error = 1;
    }

    # `conn_refresh_period' specifies how many minutes to wait before forceably
    # tearing down the change listener connection, re-syncing, and re-connecting.
    # Used by the AD backend.
    # Defaults to one hour.
#    $config{'conn_refresh_period'} = 60 if (!exists $config{'conn_refresh_period'});

    # `slurpd_port' specifies what port the kolab slurpd replication daemon listens on
    # Defaults to 9999 for backwards compatibility
#    $config{'slurpd_port'} = 9999 if (!exists $config{'slurpd_port'});

    # `user_ldap_uri', `user_bind_dn', `user_bind_pw' and `user_dn_list' are
    # used to specify the DNs where user objects are located. They default to
    # `ldap_uri', `bind_dn', `bind_pw' and `base_dn', respectively.
    #
    #   NOTE: `user_dn_list' is a semi-colon separated list of DNs, as opposed
    #   to a single DN (such as `kolab_dn').
    #
    #   TODO: Expand this to allow all separate entities (kolab object, users,
    #   shared folders, etc) to exist in user-specified locations
    #
    #   TODO: Check Postfix LDAP aliasing when user_dn_list contains more than
    #   one DN.
    $config{'user_ldap_uri'} = $config{'ldap_uri'} if (!exists $config{'user_ldap_uri'});

    if (!($tempval = URI->new($config{'user_ldap_uri'}))) {
        &log('C', "Unable to parse user_ldap_uri `" . $config{'user_ldap_uri'} . "'", KOLAB_ERROR);
#        exit(1);
	$error = 1;
    } else {
        $config{'user_ldap_ip'} = $tempval->host;
        $config{'user_ldap_port'} = $tempval->port;
    }

    $config{'user_bind_dn'} = $config{'bind_dn'} if (!exists $config{'user_bind_dn'});
    $config{'user_bind_pw'} = $config{'bind_pw'} if (!exists $config{'user_bind_pw'});
    $config{'user_dn_list'} = $config{'base_dn'} if (!exists $config{'user_dn_list'});
    $config{'user_directory_mode'} = $config{'directory_mode'} if (!exists $config{'user_directory_mode'});

    # `user_object_class' denotes what object class to search for when locating users.
    # Defaults to `inetOrgPerson'
    $config{'user_object_class'} = 'inetOrgPerson' if (!exists $config{'user_object_class'});

    # This part sets various backend-specific LDAP fields (if they have not been
    # overridden) based on `directory_mode'.
    #
    # `user_delete_flag' is used to test whether a user object has been deleted
    # `user_field_modified' is used to test whether a user object has been modified
    # `user_field_guid' indicates a field that can be considered globally unique to the object
    # `user_field_quota' indicates a field that stores the cyrus quota for the user
    if ($config{'user_directory_mode'} eq 'ad') {
        # AD
        $config{'user_field_deleted'} = 'isDeleted' if (!exists $config{'user_field_deleted'});
        $config{'user_field_modified'} = 'whenChanged' if (!exists $config{'user_field_modified'});
        $config{'user_field_guid'} = 'objectGUID' if (!exists $config{'user_field_guid'});
        $config{'user_field_quota'} = 'userquota' if (!exists $config{'user_field_quota'});
    } else {
        # slurd/default
        $config{'user_field_deleted'} = 'kolabdeleteflag' if (!exists $config{'user_field_deleted'});
        $config{'user_field_modified'} = 'modifytimestamp' if (!exists $config{'user_field_modified'});
        $config{'user_field_guid'} = 'entryUUID' if (!exists $config{'user_field_guid'});
        $config{'user_field_quota'} = 'cyrus-userquota' if (!exists $config{'user_field_quota'});

    }

    # The `sf_XXX' variables are the shared folder equivalents of the `user_XXX' variables
    $config{'sf_ldap_uri'} = $config{'ldap_uri'} if (!exists $config{'sf_ldap_uri'});

    if (!($tempval = URI->new($config{'sf_ldap_uri'}))) {
        &log('C', "Unable to parse sf_ldap_uri `" . $config{'sf_ldap_uri'} . "'", KOLAB_ERROR);
#        exit(1);
	$error = 1;
    } else {
        $config{'sf_ldap_ip'} = $tempval->host;
        $config{'sf_ldap_port'} = $tempval->port;
    }

    $config{'sf_bind_dn'} = $config{'bind_dn'} if (!exists $config{'sf_bind_dn'});
    $config{'sf_bind_pw'} = $config{'bind_pw'} if (!exists $config{'sf_bind_pw'});
    $config{'sf_dn_list'} = $config{'base_dn'} if (!exists $config{'sf_dn_list'});
    $config{'sf_directory_mode'} = $config{'directory_mode'} if (!exists $config{'sf_directory_mode'});

    $config{'sf_object_class'} = 'kolabsharedfolder' if (!exists $config{'sf_object_class'});

    if ($config{'sf_directory_mode'} eq 'ad') {
        # AD
        $config{'sf_field_deleted'} = 'isDeleted' if (!exists $config{'sf_field_deleted'});
        $config{'sf_field_modified'} = 'whenChanged' if (!exists $config{'sf_field_modified'});
        $config{'sf_field_guid'} = 'entryUUID' if (!exists $config{'sf_field_guid'});
        $config{'sf_field_quota'} = 'userquota' if (!exists $config{'sf_field_quota'});
    } else {
        # slurd/default
        $config{'sf_field_deleted'} = 'kolabdeleteflag' if (!exists $config{'sf_field_deleted'});
        $config{'sf_field_modified'} = 'modifytimestamp' if (!exists $config{'sf_field_modified'});
        $config{'sf_field_guid'} = 'entryUUID' if (!exists $config{'sf_field_guid'});
        $config{'sf_field_quota'} = 'cyrus-userquota' if (!exists $config{'sf_field_quota'});
    }

    # The `group_XXX' variables are the distribution list/groups 
    # equivalents of the `user_XXX' variables
    $config{'group_ldap_uri'} = $config{'ldap_uri'} if (!exists $config{'group_ldap_uri'});

    if (!($tempval = URI->new($config{'group_ldap_uri'}))) {
        &log('C', "Unable to parse group_ldap_uri `" . $config{'group_ldap_uri'} . "'", KOLAB_ERROR);
#        exit(1);
	$error = 1;
    } else {
        $config{'group_ldap_ip'} = $tempval->host;
        $config{'group_ldap_port'} = $tempval->port;
    }

    $config{'group_bind_dn'} = $config{'bind_dn'} if (!exists $config{'group_bind_dn'});
    $config{'group_bind_pw'} = $config{'bind_pw'} if (!exists $config{'group_bind_pw'});
    $config{'group_dn_list'} = $config{'base_dn'} if (!exists $config{'group_dn_list'});
    $config{'group_directory_mode'} = $config{'directory_mode'} if (!exists $config{'group_directory_mode'});

    $config{'group_object_class'} = 'kolabgroupofnames' if (!exists $config{'group_object_class'});

    if ($config{'group_directory_mode'} eq 'ad') {
        # AD
        $config{'group_field_deleted'} = 'isDeleted' if (!exists $config{'group_field_deleted'});
        $config{'group_field_modified'} = 'whenChanged' if (!exists $config{'group_field_modified'});
        $config{'group_field_guid'} = 'entryUUID' if (!exists $config{'group_field_guid'});
    } else {
        # slurd/default
        $config{'group_field_deleted'} = 'kolabdeleteflag' if (!exists $config{'group_field_deleted'});
        $config{'group_field_modified'} = 'modifytimestamp' if (!exists $config{'group_field_modified'});
        $config{'group_field_guid'} = 'entryUUID' if (!exists $config{'group_field_guid'});
    }

    # `gyard_deletion_period' specifies how many minutes to leave lost users in
    # the graveyard before deleting them.
    # Defaults to seven days.
#    $config{'gyard_deletion_period'} = 7 * 24 * 60 if (!exists $config{'gyard_deletion_period'});

    # That's it! We now have our config hash.
    #Kolab::LDAP::destroy($ldap);
    if (defined($ldap) && $ldap->isa('Net::LDAP')) {
        $ldap->unbind;
        $ldap->disconnect;
    }

    &log('C', 'Finished reloading configuration');
    $reloadOk = !$error;
}

sub log
{
    my $prefix = shift;
    my $text = shift;
    my $priority = shift || KOLAB_INFO;

    if ($priority == KOLAB_ERROR) {
        $text = $prefix . ' Error: ' . $text;
    } elsif ($priority == KOLAB_WARN) {
        $text = $prefix . ' Warning: ' . $text;
    } elsif ($priority == KOLAB_DEBUG) {
        $text = $prefix . ' Debug: ' . $text;
    } else {
        $text = $prefix . ': ' . $text;
    }
    syslog('info', "$text") if $config{'log_level'} >= $priority;
    print STDERR "$text\n" if $config{'debug'};
}

1;
__END__
=head1 NAME

Kolab - Perl extension for general Kolab settings.

=head1 ABSTRACT

  Kolab contains code used for loading the configuration values from
  kolab.conf and LDAP, as well as functions for logging.

=head1 COPYRIGHT AND AUTHORS

Stuart Bing� and others (see AUTHORS file)

=head1 LICENSE

This  program is free  software; you can redistribute  it and/or
modify it  under the terms of the GNU  General Public License as
published by the  Free Software Foundation; either version 2, or
(at your option) any later version.

This program is  distributed in the hope that it will be useful,
but WITHOUT  ANY WARRANTY; without even the  implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
General Public License for more details.

You can view the  GNU General Public License, online, at the GNU
Project's homepage; see <http://www.gnu.org/licenses/gpl.html>.

=cut
