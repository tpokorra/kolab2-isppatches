package Kolab::LDAP::Backend::syncrepl;

##
##  Copyright (c) 2008  Mathieu Parent <math.parent@gmail.com>
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
use 5.008;
use strict;
use warnings;
use Kolab;
use Kolab::LDAP;
use Net::LDAP qw(
	LDAP_USER_CANCELED
	LDAP_SYNC_REFRESH_ONLY
	LDAP_SYNC_REFRESH_AND_PERSIST
);
use Net::LDAP::Control;
use Net::LDAP::Control::SyncRequest;
use Net::LDAP::Entry;
use vars qw($ldap $disconnected);
my $disconnected = 1;

require Exporter;

our @ISA = qw(Exporter);

our %EXPORT_TAGS = (
    'all' => [ qw(
    &startup
    &run
    ) ]
);

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw(
    
);

our $VERSION = '0.3';

sub mode { 
  LDAP_SYNC_REFRESH_ONLY;
  #LDAP_SYNC_REFRESH_AND_PERSIST;
}

# calling without args means: get,
# giving an argument means: set
sub cookie {
  my($cookie) = @_;
  my $syncrepl_cookie_file = $Kolab::config{'syncrepl_cookie_file'} || '/tmp/kolab_syncrepl_cookie_file';
  if(defined($cookie)) {
    if(!open(COOKIE_FILE, '>', $syncrepl_cookie_file)) {
        Kolab::log("SYNCREPL', 'Cannot open file `".$syncrepl_cookie_file.
        "' for writing: $!", KOLAB_DEBUG);
        &abort;
    }
    Kolab::log("SYNCREPL', 'Writing cookie to file: ".$cookie, KOLAB_DEBUG);
    print COOKIE_FILE $cookie;
    close(COOKIE_FILE);
    return $cookie;
  } else {
    #create if it doesn't exists
    if(! -f $syncrepl_cookie_file) {
        open COOKIE_FILE, '>', $syncrepl_cookie_file;
        close COOKIE_FILE;
    }
    if(!open(COOKIE_FILE, '+<', $syncrepl_cookie_file)) {
        Kolab::log("SYNCREPL', 'Cannot open file `".$syncrepl_cookie_file.
        "' for reading: $!", KOLAB_DEBUG);
        &abort;
    }
    read COOKIE_FILE, $cookie, 1024, 0;
    close COOKIE_FILE;
    #an empty file means no cookie:
    $cookie = undef if !$cookie;
    return $cookie;
  }
}

sub startup { 1; }

sub shutdown
{
  Kolab::log('SYNCREPL', 'Shutting down');
  exit(0);
}

sub abort
{
    Kolab::log('SYNCREPL', 'Aborting');
    exit(1);
}

sub run {
  # This should be called from a separate thread, as we set our
  # own interrupt handlers here

  $SIG{'INT'} = \&shutdown;
  $SIG{'TERM'} = \&shutdown;

  END {
    alarm 0;
    Kolab::LDAP::destroy($ldap);
  }
  my $mesg;

  while (1) {
    Kolab::log('SYNCREPL', 'Creating LDAP connection to LDAP server', KOLAB_DEBUG);

    $ldap = Kolab::LDAP::create($Kolab::config{'user_ldap_ip'},
                                $Kolab::config{'user_ldap_port'},
                                $Kolab::config{'user_bind_dn'},
                                $Kolab::config{'user_bind_pw'},
                                1
                               );
    if (!$ldap) {
        Kolab::log('SYNCREPL', 'Sleeping 5 seconds...');
        sleep 5;
        next;
    }
    $disconnected = 0;  

    Kolab::log('SYNCREPL', 'LDAP connection established', KOLAB_DEBUG);

    Kolab::LDAP::ensureAsync($ldap);
    Kolab::log('SYNCREPL', 'Async checked', KOLAB_DEBUG);

    while($ldap and not $disconnected) {
      my $ctrl = Net::LDAP::Control::SyncRequest->new(
        mode       => Kolab::LDAP::Backend::syncrepl::mode(),
        cookie     => Kolab::LDAP::Backend::syncrepl::cookie(),
        reloadHint => 0);
      Kolab::log('SYNCREPL', 'Control created: mode='.$ctrl->mode().
      	'; cookie='.$ctrl->cookie().
      	'; reloadHint='.$ctrl->reloadHint(), KOLAB_DEBUG);

      #search
      my $mesg = $ldap->search(base     => $Kolab::config{'base_dn'},
                               scope    => 'sub',
                               control  => [ $ctrl ],
                               callback => \&searchCallback, # call for each entry
                               filter   => "(objectClass=*)",
                               attrs    => [ '*',
                                             $Kolab::config{'user_field_guid'},
                                             $Kolab::config{'user_field_modified'},
                                             $Kolab::config{'user_field_quota'},
                                             $Kolab::config{'user_field_deleted'},
                                           ],
                              );
      Kolab::log('SYNCREPL', 'Search created', KOLAB_DEBUG);
      $mesg->sync;
      Kolab::log('SYNCREPL', "Finished Net::LDAP::Search::sync sleeping 10s", KOLAB_DEBUG);
      sleep 10;
    }
  }
  1;
}

#search callback
sub searchCallback {
  my $mesg = shift;
  my $param2 = shift; # might be entry or intermediate
  my @controls = $mesg->control;
  my @sync_controls = ();
  if($param2 && $param2->isa("Net::LDAP::Entry")) {
    Kolab::log('SYNCREPL', 'Received Search Entry', KOLAB_DEBUG);
    #retrieve Sync State Control
    foreach my $ctrl (@controls) {
      push(@sync_controls, $ctrl)
        if $ctrl->isa('Net::LDAP::Control::SyncState');
    }
    if(@sync_controls>1) {
      Kolab::log('SYNCREPL', 'Got search entry with multiple Sync State controls',
        KOLAB_DEBUG);
      return;
    }
    if(!@sync_controls) {
      Kolab::log('SYNCREPL', 'Got search entry without Sync State control',
        KOLAB_DEBUG);
      return;
    }
    if(!$sync_controls[0]->entryUUID) {
      Kolab::log('SYNCREPL', 'Got empty entryUUID', KOLAB_DEBUG);
      return;
    }
    Kolab::log('SYNCREPL', 'Search Entry has Sync State Control: '.
      'state='.$sync_controls[0]->state().
      '; entryUUID='.unpack("H*",$sync_controls[0]->entryUUID()).
      '; cookie='.(defined($sync_controls[0]->cookie()) ? $sync_controls[0]->cookie() : 'UNDEF')
	, KOLAB_DEBUG);
    if(defined($sync_controls[0]->cookie)) {
      Kolab::LDAP::Backend::syncrepl::cookie($sync_controls[0]->cookie);
      Kolab::log('SYNCREPL',"New cookie: ".Kolab::LDAP::Backend::syncrepl::cookie(),
        KOLAB_DEBUG);
    }
    Kolab::log('SYNCREPL', "Entry (".$param2->changetype."): ".$param2->dn(), KOLAB_DEBUG);
  } elsif($param2 && $param2->isa("Net::LDAP::Reference")) {
    Kolab::log('SYNCREPL', 'Received Search Reference', KOLAB_DEBUG);
    return;
  #if it not first control?
  } elsif($controls[0] and $controls[0]->isa('Net::LDAP::Control::SyncDone')) {
    Kolab::log('SYNCREPL', 'Received Sync Done Control: '.
      'cookie='.(defined($controls[0]->cookie()) ? $controls[0]->cookie() : 'UNDEF').
      '; refreshDeletes='.$controls[0]->refreshDeletes(), KOLAB_DEBUG);
    #we have a new cookie
    if(defined($controls[0]->cookie())
        and not $controls[0]->cookie() eq '' 
        and not $controls[0]->cookie() eq Kolab::LDAP::Backend::syncrepl::cookie()) {
      Kolab::LDAP::Backend::syncrepl::cookie($controls[0]->cookie());
      Kolab::log('SYNCREPL', "New cookie: ".
        Kolab::LDAP::Backend::syncrepl::cookie(), KOLAB_DEBUG);
      Kolab::log('SYNCREPL', "Calling Kolab::LDAP::sync", KOLAB_DEBUG);
      Kolab::LDAP::sync;
      system($Kolab::config{'kolabconf_script'}) == 0
        || Kolab::log('SD', "Failed to run kolabconf: $?", KOLAB_ERROR);
      Kolab::log('SYNCREPL', "Finished Kolab::LDAP::sync sleeping 1s", KOLAB_DEBUG);
      sleep 1; # we get too many bogus change notifications!
	  } 
  } elsif($param2 && $param2->isa("Net::LDAP::Intermediate")) {
    Kolab::log('SYNCREPL', 'Received Intermediate Message', KOLAB_DEBUG);
    my $attrs = $param2->{asn};
    if($attrs->{newcookie}) {
      Kolab::LDAP::Backend::syncrepl::cookie($attrs->{newcookie});
      Kolab::log('SYNCREPL', "New cookie: ".
        Kolab::LDAP::Backend::syncrepl::cookie(), KOLAB_DEBUG);
    } elsif(my $refreshInfos = ($attrs->{refreshDelete} || $attrs->{refreshPresent})) {
      Kolab::LDAP::Backend::syncrepl::cookie($refreshInfos->{cookie})
        if defined($refreshInfos->{cookie});
      Kolab::log('SYNCREPL', 
        (defined($refreshInfos->{cookie}) ? 'New ' : 'Empty ').
        "cookie from ".
        ($attrs->{refreshDelete} ? 'refreshDelete' : 'refreshPresent').
        " (refreshDone=".$refreshInfos->{refreshDone}."): ".
        Kolab::LDAP::Backend::syncrepl::cookie(), KOLAB_DEBUG);
    } elsif(my $syncIdSetInfos = $attrs->{syncIdSet}) {
      Kolab::LDAP::Backend::syncrepl::cookie($syncIdSetInfos->{cookie})
        if defined($syncIdSetInfos->{cookie});
      Kolab::log('SYNCREPL', 
        (defined($syncIdSetInfos->{cookie}) ? 'Empty ' : 'New ').
        "cookie from syncIdSet".
        " (refreshDeletes=".$syncIdSetInfos->{refreshDeletes}."): ".
        Kolab::LDAP::Backend::syncrepl::cookie(), KOLAB_DEBUG);
      foreach my $syncUUID ($syncIdSetInfos->{syncUUIDs}) {
        Kolab::log('SYNCREPL', 'entryUUID='.
          unpack("H*",$syncUUID), KOLAB_DEBUG);
      }
    }
  } elsif($mesg->code) {
    if ($mesg->code == 1) {
      Kolab::log('SYNCREPL', 'Communication Error: disconnecting', KOLAB_DEBUG);
      $disconnected = 1;
      return 0;
    } elsif ($mesg->code == LDAP_USER_CANCELED) {
        Kolab::log('SYNCREPL', 'searchCallback() -> Exit code received, returning', KOLAB_DEBUG);
        return;
    } elsif ($mesg->code == 4096) {
        Kolab::log('SYNCREPL', 'Refresh required', KOLAB_DEBUG);
        Kolab::LDAP::Backend::syncrepl::cookie('');
    } else {
        Kolab::log('SYNCREPL', "searchCallback: mesg->code = `" . $mesg->code . "', mesg->msg = `" . $mesg->error . "'", KOLAB_DEBUG);
        &abort;
    }   
  } else {
    Kolab::log('SYNCREPL', 'Received something else', KOLAB_DEBUG);
  }
  return 0;
}

1;
__END__

=head1 NAME

Kolab::LDAP::Backend::syncrepl - Perl extension for RFC 4533 compliant LDAP server backend

=head1 ABSTRACT

  Kolab::LDAP::Backend::syncrepl handles OpenLDAP backend to the kolab daemon.

=head1 AUTHOR

Mathieu Parent <math.parent@gmail.com>

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2008  Mathieu Parent <math.parent@gmail.com>


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

=head1 NOTES
We use refreshOnly mode as refreshAndPersist mode uses LDAP Intermediate
Response Messages [RFC4511] that are not supported by current Net::LDAP.

However (quoting from RFC, page 21):

   The server SHOULD transfer a new cookie frequently to avoid having to
   transfer information already provided to the client.  Even where DIT
   changes do not cause content synchronization changes to be
   transferred, it may be advantageous to provide a new cookie using a
   Sync Info Message.  However, the server SHOULD avoid overloading the
   client or network with Sync Info Messages.



=cut
