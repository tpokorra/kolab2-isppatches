package Kolab::Util;

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
use IO::File;
use Sys::Syslog;

require Exporter;

our @ISA = qw(Exporter);

our %EXPORT_TAGS = (
    'all' => [ qw(

    ) ]
);

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw(
    &trim
    &ldapDateToEpoch
    &readConfig
    &readList
    &superLog
);

our $VERSION = '0.9';

sub trim
{
    my $string = shift;

    if (defined $string) {
        $string =~ s/^\s+//g;
        $string =~ s/\s+$//g;
        chomp $string;
    }

    return $string;
}

sub ldapDateToEpoch
{
    my $ldapdate = shift;

    (my $y, my $m, my $d, my $h, my $mi, my $se) = unpack('A4A2A2A2A2A2', $ldapdate);

    return timelocal($se, $mi, $h, $d, $m, $y);
}

sub superLog
{
    my $text = shift;
    #print STDERR "$text\n";
    syslog('info', "$text");
}

sub readConfig
{
    my $ref = shift;
    my (%cfg, $file);

    if (ref($ref) eq 'HASH') {
        %cfg = %$ref;
        $file = shift || 0;
    } else {
        $file = $ref;
    }

    if (!$file) { return %cfg; }

    my $sep = shift || ':';
    $sep = '\s' if ($sep eq ' ' || $sep eq '#');

    my $fd;
    if (!($fd = IO::File->new($file, 'r'))) { 
	superLog( "Warning: Could not read $file");
	return %cfg; 
    }

    foreach (<$fd>) {
        if (/^([^$sep#]+)$sep(.*)/) {
            $cfg{trim($1)} = trim($2);
        }
    }

    return %cfg;
}

sub readList
{
    my @list;

    my $file = shift || 0;
    if (!$file) { return @list; }

    my $fd;
    if (!($fd = IO::File->new($file, 'r'))) { return @list; }

    foreach (<$fd>) {
        if (/^([^#]+)/) {
            my $temp = trim($1);
            next if $temp eq '';
            push(@list, ($temp));
        }
    }

    return @list;
}

1;
__END__
# Below is stub documentation for your module. You'd better edit it!

=head1 NAME

Kolab::Util - Perl extension for general utility functions

=head1 ABSTRACT

  Kolab::Util contains several basic utility functions.

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
