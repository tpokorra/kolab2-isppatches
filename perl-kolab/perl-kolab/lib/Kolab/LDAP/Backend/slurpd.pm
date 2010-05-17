package Kolab::LDAP::Backend::slurpd;

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
use IO::Select;
use IO::Socket::INET;
use Convert::ASN1 qw(:io);
use Net::LDAP;
use Net::LDAP::Constant qw(LDAP_SUCCESS LDAP_PROTOCOL_ERROR);
use Net::LDAP::ASN qw(LDAPRequest LDAPResponse LDAPResult);
use Kolab;
use Kolab::Util;
use Kolab::LDAP;
use vars qw($conn $server);

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

our $VERSION = '0.9';

sub startup { 1; }

sub shutdown
{
    Kolab::log('SD', 'Shutting down');
    exit(0);
}

sub abort
{
    Kolab::log('SD', 'Aborting');
    exit(1);
}

sub PROTOCOLOP_BINDREQUEST      () { 0x00 }
sub PROTOCOLOP_BINDRESPONSE     () { 0x01 }
sub PROTOCOLOP_UNBINDREQUEST    () { 0x02 }
sub PROTOCOLOP_SEARCHREQUEST    () { 0x03 }
sub PROTOCOLOP_SEARCHRESENTRY   () { 0x04 }
sub PROTOCOLOP_SEARCHRESDONE    () { 0x05 }
sub PROTOCOLOP_SEARCHRESREF     () { 0x06 }
sub PROTOCOLOP_MODIFYREQUEST    () { 0x07 }
sub PROTOCOLOP_MODIFYRESPONSE   () { 0x08 }
sub PROTOCOLOP_ADDREQUEST       () { 0x09 }
sub PROTOCOLOP_ADDRESPONSE      () { 0x10 }
sub PROTOCOLOP_DELREQUEST       () { 0x11 }
sub PROTOCOLOP_DELRESPONSE      () { 0x12 }
sub PROTOCOLOP_MODDNREQUEST     () { 0x13 }
sub PROTOCOLOP_MODDNRESPONSE    () { 0x14 }
sub PROTOCOLOP_COMPAREREQUEST   () { 0x15 }
sub PROTOCOLOP_COMPARERESPONSE  () { 0x16 }
sub PROTOCOLOP_ABANDONREQUEST   () { 0x17 }
sub PROTOCOLOP_EXTENDEDREQ      () { 0x18 }
sub PROTOCOLOP_EXTENDEDRESP     () { 0x19 }

sub getRequestType
{
    my $op = shift;
    if ($op->{bindRequest})     { return "bindRequest"; }
    if ($op->{unbindRequest})   { return "unbindRequest"; }
    if ($op->{addRequest})      { return "addRequest"; }
    if ($op->{delRequest})      { return "delRequest"; }
    if ($op->{modifyRequest})   { return "modifyRequest"; }
    if ($op->{modDNRequest})    { return "modDNRequest"; }
    if ($op->{searchRequest})   { return "searchRequest"; }
    if ($op->{compareRequest})  { return "compareRequest"; }
    if ($op->{abandonRequest})  { return "abandonRequest"; }
    if ($op->{extendedRequest}) { return "extendedRequest"; }
    return "";
}

sub responseBind
{
    my $req = shift;
    my $pdu = $LDAPResponse->encode(
        messageID       => $req->{messageID},
        protocolOp      => {
            choiceID        => PROTOCOLOP_BINDRESPONSE,
            bindResponse    => {
                resultCode      => LDAP_SUCCESS,
                matchedDN       => $req->{bindRequest}{name},
                errorMessage    => "",
                serverSaslCreds => ""
            }
        }
    );
    if (!$pdu) {
        Kolab::log('SD', "LDAPResponse error `" .  $LDAPResponse->error . "'");
        &abort;
    }
    return $pdu;
}

sub responseAdd
{
    my $req = shift;
    my $pdu = $LDAPResponse->encode(
        messageID       => $req->{messageID},
        protocolOp      => {
            choiceID        => PROTOCOLOP_ADDRESPONSE,
            addResponse     => {
                resultCode      => LDAP_SUCCESS,
                matchedDN       => $req->{addRequest}{objectName},
                errorMessage    => ""
            }
        }
    );
    if (!$pdu) {
        Kolab::log('SD', "LDAPResponse error `" .  $LDAPResponse->error . "'");
        &abort;
    }
    return $pdu;
}

sub responseDel
{
    my $req = shift;
    my $pdu = $LDAPResponse->encode(
        messageID       => $req->{messageID},
        protocolOp      => {
            choiceID        => PROTOCOLOP_DELRESPONSE,
            addResponse     => {
                resultCode      => LDAP_SUCCESS,
                matchedDN       => $req->{delRequest},
                errorMessage    => ""
            }
        }
    );
    if (!$pdu) {
        Kolab::log('SD', "LDAPResponse error `" .  $LDAPResponse->error . "'");
        &abort;
    }
    return $pdu;
}

sub responseMod
{
    my $req = shift;
    my $pdu = $LDAPResponse->encode(
        messageID       => $req->{messageID},
        protocolOp      => {
            choiceID        => PROTOCOLOP_MODIFYRESPONSE,
            addResponse     => {
                resultCode      => LDAP_SUCCESS,
                matchedDN       => $req->{modifyRequest}{object},
                errorMessage    => ""
            }
        }
    );
    if (!$pdu) {
        Kolab::log('SD', "LDAPResponse error `" .  $LDAPResponse->error . "'");
        &abort;
    }
    return $pdu;
}

sub responseModDN
{
    my $req = shift;
    my $pdu = $LDAPResponse->encode(
        messageID       => $req->{messageID},
        protocolOp      => {
            choiceID        => PROTOCOLOP_MODDNRESPONSE,
            addResponse     => {
                resultCode      => LDAP_SUCCESS,
                matchedDN       => $req->{modDNRequest}{entry},
                errorMessage    => ""
            }
        }
    );
    if (!$pdu) {
        Kolab::log('SD', "LDAPResponse error `" .  $LDAPResponse->error . "'");
        &abort;
    }
    return $pdu;
}

sub run
{
    # This should be called from a separate thread, as we set our
    # own interrupt handlers here

    $SIG{'INT'} = \&shutdown;
    $SIG{'TERM'} = \&shutdown;

    END {
        if ($conn) { $conn->close; }
        if ($server) { $server->close; }
    }

    my $request;
    my $response;
    my $pdu;
    my $changes = 0;

    my $listenport = $Kolab::config{'slurpd_port'};
    my $listenaddr = $Kolab::config{'slurpd_addr'} || "127.0.0.1";
  TRYCONNECT:
    Kolab::log('SD', "Opening listen server on $listenaddr:$listenport");
    $server = IO::Socket::INET->new(
	LocalPort   => $listenport,
	Proto       => "tcp",
	ReuseAddr   => 1,
	Type        => SOCK_STREAM,
	LocalAddr   => $listenaddr,
	Listen      => 10
     );
    if (!$server) {
        Kolab::log('SD', "Unable to open TCP listen server on $listenaddr:$listenport, Error = $@", KOLAB_ERROR);
	sleep 1;
	goto TRYCONNECT;
    }

    Kolab::log('SD', 'Listen server opened, waiting for incoming connections');

    while ($conn = $server->accept()) {
      # PENDING: Only accept connections from localhost and
      # hosts listed in the kolabhost attribute

	my($peerport, $peeraddr) = sockaddr_in($conn->peername);
	$peeraddr = inet_ntoa( $peeraddr );
        Kolab::log('SD', "Incoming connection accepted, peer=$peeraddr");
	if( $Kolab::config{'slurpd_accept_addr'} && $peeraddr ne $Kolab::config{'slurpd_accept_addr'} ) {
	    Kolab::log('SD', "Unauthorized connection from $peeraddr, closing connection", KOLAB_WARN);
	    $conn->close;
	    undef $conn;
	    next;
	}

        my $select = IO::Select->new($conn);

        while ($conn) {
            undef $pdu;
            my $ready;
            my $offset = 0;

            if (!($select->can_read(0)) && $changes) {
	        Kolab::log('SD', 'Change detected w/ no pending LDAP messages; waiting a second...');
		if( !($select->can_read(1)) ) {
		  $changes = 0;
		  Kolab::log('SD', 'Change detected w/ no pending LDAP messages; reloading services if needed');
                  my $kidpid = fork();
		  unless (defined $kidpid) {
		      die("can't fork: $!");
		  }
		  if ($kidpid == 0 ) {
		      # child
		      Kolab::LDAP::sync;
		      exit(0);
		  }
		  waitpid($kidpid, 0);
		  Kolab::log('SD', "Running $Kolab::config{'kolabconf_script'}");
		  system($Kolab::config{'kolabconf_script'}) == 0
		    or Kolab::log('SD', "Failed to run $Kolab::config{'kolabconf_script'}: $?", KOLAB_ERROR);
		  Kolab::log('SD', "$Kolab::config{'kolabconf_script'} complete");
		}
            }

            Kolab::log('SD', 'Waiting for LDAP updates');

            for ($ready = 1; $conn && $ready; $ready = $select->can_read(0)) {
                Kolab::log('SD', 'Reading ASN', KOLAB_DEBUG);
                my $newoffset = asn_read($conn, $pdu, $offset);
		if( !$conn->connected() or $offset == $newoffset ) {
		  Kolab::log('SD', 'Connection closed', KOLAB_DEBUG);
		  $conn->close;
		  undef $conn;
		}
		$offset = $newoffset;
                defined($offset) or $offset = 0;
            }

            if ($pdu) {
                $request = $LDAPRequest->decode($pdu);
                if (!$request) {
                    Kolab::log('SD', "Unable to decode slurpd request, Error = `" . $LDAPRequest->error . "'", KOLAB_ERROR);
		    $conn->close if $conn;
		    undef $conn;
		    undef $pdu;
                } else {
		    $_ = getRequestType($request);
		    Kolab::log('SD', "Request $_ received", KOLAB_DEBUG);
		    undef $pdu;

		    SWITCH: {
		      if (/^bindRequest/) { $pdu = responseBind($request); last SWITCH; }
                      if (/addRequest/) { $pdu = responseAdd($request); $changes = 1; last SWITCH; }
                      if (/delRequest/) { $pdu = responseDel($request); $changes = 1; last SWITCH; }
                      if (/modifyRequest/) { $pdu = responseMod($request); $changes = 1; last SWITCH; }
                      if (/modDNRequest/) { $pdu = responseModDN($request); $changes = 1; last SWITCH; }

                      if( $conn ) {
		        Kolab::log('SD', 'Unknown request, connection closed', KOLAB_DEBUG);
		        $conn->close;
		        undef $conn;
		      }
		    }
		}
	    }

            if ($pdu) {
                Kolab::log('SD', 'Writing response', KOLAB_DEBUG);
                syswrite($conn, $pdu, length($pdu));
                $response = $LDAPResponse->decode($pdu);
                if (!$response) {
                    Kolab::log('SD', "Unable to decode slurpd request, Error = `" . $LDAPRequest->error . "'");
		    $conn->close;
		    undef $conn;
                }
            }
        }
    }

    $server->close;

    1;
}

1;
__END__
# Below is stub documentation for your module. You'd better edit it!

=head1 NAME

Kolab::LDAP::Backend::slurpd - Perl extension for a slurpd backend

=head1 ABSTRACT

  Kolab::LDAP::Backend::slurpd handles a slurpd backend to the
  kolab daemon.

=head1 COPYRIGHT AND AUTHORS

Stuart Bingë and others (see AUTHORS file)

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
