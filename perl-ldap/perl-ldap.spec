##
##  perl-ldap.spec -- OpenPKG RPM Package Specification
##  Copyright (c) 2000-2008 OpenPKG Foundation e.V. <http://openpkg.net/>
##
##  Permission to use, copy, modify, and distribute this software for
##  any purpose with or without fee is hereby granted, provided that
##  the above copyright notice and this permission notice appear in all
##  copies.
##
##  THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY EXPRESSED OR IMPLIED
##  WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
##  MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
##  IN NO EVENT SHALL THE AUTHORS AND COPYRIGHT HOLDERS AND THEIR
##  CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
##  SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
##  LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF
##  USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
##  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
##  OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT
##  OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
##  SUCH DAMAGE.
##

#   versions of individual parts
%define       V_perl         5.10.0
%define       V_perl_ldap    0.40

#   package information
Name:         perl-ldap
Summary:      Perl Modules for use with LDAP
URL:          http://www.cpan.org/
Vendor:       Perl Community
Packager:     Intevation GmbH
Class:        BASE
Group:        Perl
License:      GPL/Artistic
Version:      %{V_perl}
Release:      20100324

#   list of sources
Source0:      http://www.cpan.org/modules/by-module/Net/perl-ldap-%{V_perl_ldap}.tar.gz

#   build information
Prefix:       %{l_prefix}
BuildRoot:    %{l_buildroot}
BuildPreReq:  OpenPKG, openpkg >= 20040130, perl >= %{V_perl}, perl-openpkg >= %{V_perl}-20040126
PreReq:       OpenPKG, openpkg >= 20040130, perl >= %{V_perl}
BuildPreReq:  perl-conv, perl-crypto, perl-ssl, perl-sys, perl-www, perl-xml
PreReq:       perl-conv, perl-crypto, perl-ssl, perl-sys, perl-www, perl-xml
AutoReq:      no
AutoReqProv:  no

%description
    Perl modules for LDAP:
    - Net::LDAP (%{V_perl_ldap})

%track
    prog perl-ldap:perl-ldap = {
        version   = %{V_perl_ldap}
        url       = http://www.cpan.org/modules/by-module/Net/
        regex     = perl-ldap-(\d+\.\d\d)\.tar\.gz
    }

%prep
    %setup -q -c

%build

%install
    rm -rf $RPM_BUILD_ROOT
    %{l_prefix}/bin/perl-openpkg prepare
    %{l_prefix}/bin/perl-openpkg -d %{SOURCE0}  configure build install
    %{l_prefix}/bin/perl-openpkg -F perl-openpkg-files fixate cleanup
    %{l_rpmtool} files -v -ofiles -r$RPM_BUILD_ROOT %{l_files_std} `cat perl-openpkg-files`

%files -f files

%clean
    rm -rf $RPM_BUILD_ROOT

