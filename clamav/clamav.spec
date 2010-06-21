##
##  clamav.spec -- OpenPKG RPM Package Specification
##  Copyright (c) 2000-2009 OpenPKG Foundation e.V. <http://openpkg.net/>
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

#   package information
Name:         clamav
Summary:      Clam Antivirus
URL:          http://www.clamav.net/
Vendor:       Tomasz Kojm
Packager:     Intevation GmbH
Group:        AntiVirus
License:      GPL
Version:      0.96.1
Release:      20100607

#   package options
%option       with_milter  no

#   list of sources
Source0:      http://switch.dl.sourceforge.net/clamav/clamav-%{version}.tar.gz
Source1:      rc.clamav
Patch0:       clamav.patch

#   build information
Prefix:       %{l_prefix}
BuildRoot:    %{l_buildroot}
BuildPreReq:  OpenPKG, openpkg >= 20060823, gcc, bzip2, pkgconfig, bc
PreReq:       OpenPKG, openpkg >= 20060823
BuildPreReq:  zlib, bzip2, curl, gmp, libiconv, openssl
PreReq:       zlib, bzip2, curl, gmp, libiconv, openssl
%if "%{with_milter}" == "yes"
BuildPreReq:  milter
PreReq:       milter
%endif
AutoReq:      no
AutoReqProv:  no

%description
    Clam AntiVirus is an anti-virus toolkit for UNIX. The main
    purpose of this software is the integration with mail servers
    (attachment scanning). The package provides a flexible and scalable
    multi-threaded daemon, a command line scanner, and a tool for
    automatic updating via Internet. The programs are based on a shared
    library distributed with the Clam AntiVirus package, which you can
    use with your own software. The virus database is based on the virus
    database from OpenAntiVirus, but contains additional signatures.

%track
    prog clamav = {
        version   = %{version}
        url       = http://sourceforge.net/projects/clamav/files/
        regex     = clamav-(\d+\.\d+(\.\d+)*)\.tar\.gz
    }

%prep
    %setup -q
    %patch -p1

%build
    #   configure package
    CC="%{l_cc}" \
    CFLAGS="%{l_cflags -O}" \
    CPPFLAGS="%{l_cppflags}" \
    LDFLAGS="%{l_ldflags}" \
    GREP="grep" \
    ./configure \
        --prefix=%{l_prefix} \
        --mandir=%{l_prefix}/man \
        --sysconfdir=%{l_prefix}/etc/clamav \
        --with-zlib=%{l_prefix} \
        --with-libcurl \
        --with-user=%{l_rusr} \
        --with-group=%{l_rgrp} \
        --without-tcpwrappers \
        --disable-clamav \
        --disable-clamuko \
        --disable-urandom \
        --disable-cr \
%if "%{with_milter}" == "yes"
        --enable-milter \
        --with-sendmail=/dev/null \
%else
        --disable-milter \
%endif
        --disable-unrar \
        --disable-shared

    #   build package
    %{l_make} %{l_mflags -O}

%install
    rm -rf $RPM_BUILD_ROOT

    #   perform standard package installation
    %{l_make} %{l_mflags} install AM_MAKEFLAGS="DESTDIR=$RPM_BUILD_ROOT"

    #   install default configuration
    %{l_shtool} mkdir -f -p -m 755 \
        $RPM_BUILD_ROOT%{l_prefix}/etc/clamav
    %{l_shtool} install -c -m 644 \
        -e 's;^\(Example\);#\1;' \
        -e 's;^#\(LogFile\) /.*;\1 %{l_prefix}/var/clamav/clamd.log;' \
        -e 's;^#\(LogTime.*\);\1;' \
        -e 's;^#\(PidFile\).*;\1 %{l_prefix}/var/clamav/clamd.pid;' \
        -e 's;^\(LocalSocket\).*;\1 %{l_prefix}/var/clamav/clamd.sock;' \
        -e 's;^#\(FixStaleSocket.*\);\1;' \
        -e 's;^#\(DatabaseDirectory\).*;\1 %{l_prefix}/share/clamav;' \
        -e 's;^#\(User\).*;\1 %{l_rusr};' \
        etc/clamd.conf \
        $RPM_BUILD_ROOT%{l_prefix}/etc/clamav/
    %{l_shtool} install -c -m 644 \
        -e 's;^\(Example\);#\1;' \
        -e 's;^#\(DatabaseDirectory\).*;\1 %{l_prefix}/share/clamav;' \
        -e 's;^#\(UpdateLogFile\).*;\1 %{l_prefix}/var/clamav/freshclam.log;' \
        -e 's;^#\(NotifyClamd\).*;\1 %{l_prefix}/etc/clamav/clamd.conf;' \
        etc/freshclam.conf \
        $RPM_BUILD_ROOT%{l_prefix}/etc/clamav/

    #   install run-command script
    %{l_shtool} mkdir -f -p -m 755 \
        $RPM_BUILD_ROOT%{l_prefix}/etc/rc.d
    %{l_shtool} install -c -m 755 %{l_value -s -a} \
        %{SOURCE rc.clamav} $RPM_BUILD_ROOT%{l_prefix}/etc/rc.d/

    #   strip-down installation hierarchy
    strip $RPM_BUILD_ROOT%{l_prefix}/bin/*  >/dev/null 2>&1 || true
    strip $RPM_BUILD_ROOT%{l_prefix}/sbin/* >/dev/null 2>&1 || true
%if "%{with_milter}" == "no"
    rm -f $RPM_BUILD_ROOT%{l_prefix}/man/man8/clamav-milter.8
%endif

    #   create additional installation directory
    %{l_shtool} mkdir -f -p -m 755 \
        $RPM_BUILD_ROOT%{l_prefix}/var/clamav

    #   determine installation files
    %{l_rpmtool} files -v -ofiles -r$RPM_BUILD_ROOT \
        %{l_files_std} \
        '%config %{l_prefix}/etc/clamav/*.conf' \
        '%attr(755,%{l_rusr},%{l_mgrp}) %{l_prefix}/var/clamav' \
        '%attr(755,%{l_rusr},%{l_rgrp}) %{l_prefix}/share/clamav'

%files -f files

%clean
    rm -rf $RPM_BUILD_ROOT

%pre
    #   before upgrade, save status and stop service
    [ $1 -eq 2 ] || exit 0
    eval `%{l_rc} clamav status 2>/dev/null | tee %{l_tmpfile}`
    %{l_rc} clamav stop 2>/dev/null
    exit 0

%post
    if [ $1 -eq 2 ]; then
        #   after upgrade, restore status
        eval `cat %{l_tmpfile}`; rm -f %{l_tmpfile}
        [ ".$clamav_active" = .yes ] && %{l_rc} clamav start
    fi
    exit 0

%preun
    #   before erase, stop service and remove log files
    [ $1 -eq 0 ] || exit 0
    %{l_rc} clamav stop 2>/dev/null
    rm -f $RPM_INSTALL_PREFIX/var/clamav/*.log* >/dev/null 2>&1 || true
    exit 0

