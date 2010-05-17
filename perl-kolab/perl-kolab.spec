##  COPYRIGHT
##  ---------
##
##  See AUTHORS file
##
##
##  LICENSE
##  -------
##
##  This program is free software; you can redistribute it and/or modify
##  it under the terms of the GNU General Public License as published by
##  the Free Software Foundation; either version 2 of the License, or
##  (at your option) any later version.
##
##  This program is distributed in the hope that it will be useful,
##  but WITHOUT ANY WARRANTY; without even the implied warranty of
##  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
##  GNU General Public License for more details.
##
##  You should have received a copy of the GNU General Public License
##  along with this program; if not, write to the Free Software
##  Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
##
##  $Revision: 1.116 $

#   versions of individual parts
%define       V_perl         5.8.8
%define       V_package      perl-kolab
%define       V_version      2.2.3+cvs20100330
%define       V_release      1

#   package information
Name:         %{V_package}
Summary:      Perl Modules for use with the Kolab server
URL:          http://www.kolab.org
Vendor:       Kolab Consortium
Packager:     Gunnar Wrobel <wrobel@pardus.de> (p@rdus)
Distribution: OpenPKG
Group:        Language
License:      GPL
Version:      %{V_version}
Release:      %{V_release}
Epoch:        1

#   list of sources
Source0:      %{V_package}-%{V_version}.tar.gz

#   build information
Prefix:       %{l_prefix}
BuildRoot:    %{l_buildroot}
# BuildPreReq:  OpenPKG, openpkg >= 2.0, perl >= @VERSION@, perl-openpkg >= @VERSION@
BuildPreReq:  OpenPKG, openpkg >= 2.5.0
PreReq:       OpenPKG, openpkg >= 2.5.0
PreReq:       perl >= %{V_perl}
PreReq:       perl-openpkg >= %{V_perl}
PreReq:       perl-db
PreReq:       perl-conv
PreReq:       perl-ldap
PreReq:       imapd
AutoReq:      no
AutoReqProv:  no

Provides:     kolabconf = %{version}-%{release}
Obsoletes:    kolabconf <= %{version}-%{release}

%description
    Perl modules for use with the Kolab server

%prep
    %setup -q -c

%build

%install
    %{l_prefix}/bin/perl-openpkg prepare
    %{l_prefix}/bin/perl-openpkg -d %{SOURCE0}  -A \
      "--config \"%{l_prefix}/etc/kolab\" --bin \"%{l_prefix}/bin\" --sbin \"%{l_prefix}/sbin\" --etc \"%{l_prefix}/etc/kolab\"" \
      configure build install
    cd %{V_package}-%{V_version}
    make install_sbin install_etc
    cd ..
    %{l_prefix}/bin/perl-openpkg -F perl-openpkg-files fixate cleanup
    %{l_rpmtool} files -v -ofiles -r$RPM_BUILD_ROOT %{l_files_std} `cat perl-openpkg-files`

%files -f files

%clean
    rm -rf $RPM_BUILD_ROOT

