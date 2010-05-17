##
##  openldap.spec -- OpenPKG RPM Package Specification
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
Name:         openldap
Summary:      Lightweight Directory Access Protocol (LDAP) Toolkit
URL:          http://www.openldap.org/
Vendor:       OpenLDAP Project
Packager:     OpenPKG Foundation e.V.
Distribution: OpenPKG Community
Class:        BASE
Group:        LDAP
License:      GPL
Version:      2.4.21
Release:      20100105

#   package options
%option       with_server   yes
%option       with_fsl      yes
%option       with_crypt    yes
%option       with_overlays yes
%option       with_pth      yes
%option       with_pthreads no
%option       with_sasl     no
%option       with_perl     no
%option       with_odbc     no

#   list of sources
Source0:      ftp://ftp.openldap.org/pub/openldap/openldap-release/openldap-%{version}.tgz
Source1:      rc.openldap
Source2:      fsl.openldap
Source3:      openldap.pc
Patch0:       openldap.patch

#   build information
Prefix:       %{l_prefix}
BuildRoot:    %{l_buildroot}
BuildPreReq:  OpenPKG, openpkg >= 20060823, make, gcc
PreReq:       OpenPKG, openpkg >= 20060823
BuildPreReq:  openssl, db >= 4.5
PreReq:       openssl, db >= 4.5
%if "%{with_server}" == "yes" && "%{with_fsl}" == "yes"
BuildPreReq:  fsl
PreReq:       fsl
%endif
%if "%{with_server}" == "yes" && "%{with_pthreads}" == "yes"
BuildPreReq:  db::with_pthreads = yes
PreReq:       db::with_pthreads = yes
%endif
%if "%{with_server}" == "yes" && "%{with_pth}" == "yes"
BuildPreReq:  pth
PreReq:       pth
%endif
%if "%{with_sasl}" == "yes"
BuildPreReq:  sasl
PreReq:       sasl
%endif
%if "%{with_server}" == "yes" && "%{with_odbc}" == "yes"
BuildPreReq:  ODBC
PreReq:       ODBC
%endif
AutoReq:      no
AutoReqProv:  no

%description
    OpenLDAP is an open source implementation of the Lightweight
    Directory Access Protocol (LDAP). The suite includes libraries
    implementing the LDAP protocol plus a stand-alone LDAP server
    slapd(8).

%track
    prog openldap = {
        version   = %{version}
        url       = ftp://ftp.openldap.org/pub/openldap/openldap-release/
        regex     = openldap-(__VER__)\.tgz
    }

%prep
    %setup -q
    %patch -p0
    %{l_shtool} subst \
        -e 's;-ldb-4\.[1-9];-ldb;g' \
        -e 's;-ldb-4-[1-9];-ldb;g' \
        -e 's;-ldb-4[1-9];-ldb;g' \
        -e 's;-ldb-4;-ldb;g' \
        configure

%build
    cp /dev/null config.cache

    #   configuration: standard build flags
    export CC="%{l_cc}"
    export CFLAGS="%{l_cflags -O} -D_GNU_SOURCE"
    export CPPFLAGS="%{l_cppflags}"
    export LDFLAGS="%{l_ldflags}"
    export LIBS=""
    export ARGS=""
    ARGS="$ARGS --prefix=%{l_prefix}"
    ARGS="$ARGS --libexecdir=%{l_prefix}/libexec/openldap"
    ARGS="$ARGS --localstatedir=%{l_prefix}/var/openldap"
    ARGS="$ARGS --enable-syslog"
    ARGS="$ARGS --with-tls"
    ARGS="$ARGS --without-fetch"
    ARGS="$ARGS --without-gssapi"
    ARGS="$ARGS --disable-dynamic"
    ARGS="$ARGS --disable-shared"
%if "%{with_server}" == "yes"
    ARGS="$ARGS --enable-slapd"
    ARGS="$ARGS --disable-modules"
    ARGS="$ARGS --enable-local"
    ARGS="$ARGS --enable-bdb"
    ARGS="$ARGS --enable-hdb"
    ARGS="$ARGS --enable-rewrite"
    ARGS="$ARGS --enable-ldap"
    ARGS="$ARGS --enable-meta"
    ARGS="$ARGS --enable-monitor"
    ARGS="$ARGS --enable-dnssrv"
    ARGS="$ARGS --enable-null"
    ARGS="$ARGS --enable-shell"
    ARGS="$ARGS --with-proxycache"
%else
    ARGS="$ARGS --disable-slapd"
    ARGS="$ARGS --disable-modules"
%endif

    #   configuration: force to use OSSP fsl
%if "%{with_server}" == "yes"
    LDFLAGS="$LDFLAGS %{l_fsl_ldflags}"
    LIBS="$LIBS %{l_fsl_libs}"
%endif

    #   configuration: force to use GNU pth if enabled
%if "%{with_server}" == "yes"
%if "%{with_pth}" == "yes"
    CFLAGS="$CFLAGS `%{l_prefix}/bin/pth-config --cflags`"
    CPPFLAGS="$CPPFLAGS -I`%{l_prefix}/bin/pth-config --includedir`"
    LDFLAGS="$LDFLAGS `%{l_prefix}/bin/pth-config --ldflags`"
    LIBS="`%{l_prefix}/bin/pth-config --libs` $LIBS"
    ARGS="$ARGS --with-threads=pth"
    ( echo "ac_cv_header_sys_devpoll_h=no"
      echo "ac_cv_header_sys_epoll_h=no"
    ) >>config.cache
%else
%if "%{with_pthreads}" == "yes"
    ARGS="$ARGS --with-threads=posix"
%else
    ARGS="$ARGS --with-threads=no"
%endif
%endif
%endif

    #   configuration: optional overlay support
%if "%{with_server}" == "yes" && "%{with_overlays}" == "yes"
    ARGS="$ARGS --enable-overlays=yes"
%endif

    #   configuration: optional SASL support
%if "%{with_sasl}" == "yes"
    ( echo "ac_cv_lib_sasl2_sasl_client_init=yes"
    ) >>config.cache
    CPPFLAGS="%{l_cppflags sasl} $CPPFLAGS"
    ARGS="$ARGS --with-cyrus-sasl --enable-spasswd"
%else
    ARGS="$ARGS --without-cyrus-sasl --disable-spasswd"
%endif

    #   configuration: optional crypt(3) support
%if "%{with_crypt}" == "yes"
    ARGS="$ARGS --enable-crypt"
%endif

    #   configuration: optional Perl support
%if "%{with_server}" == "yes" && "%{with_perl}" == "yes"
    ARGS="$ARGS --enable-perl"
%endif

    #   configuration: optional ODBC-based RDBMS support
%if "%{with_server}" == "yes" && "%{with_odbc}" == "yes"
    ARGS="$ARGS --enable-sql"
%endif

    #   configuration: special platform support
    case "%{l_platform -t}" in
        *-sunos* ) CFLAGS="$CFLAGS -D_AVL_H"; LIBS="$LIBS -lrt" ;;
    esac

    #   configuration: use hard-links and make sure our Berkeley-DB is picked up first
    %{l_shtool} subst \
        -e 's;ln -s;ln;g' \
        -e 's;-ldb4[1-9];%{l_prefix}/lib/libdb.a;g' \
        -e 's;<db\.h>;"db.h";g' \
        configure

    #   configuration
    ./configure --cache-file=./config.cache $ARGS

    #   build toolkit
    %{l_make} %{l_mflags} depend
    %{l_make} %{l_mflags}

%install
    #   install toolkit
    rm -rf $RPM_BUILD_ROOT
    %{l_make} %{l_mflags} install DESTDIR=$RPM_BUILD_ROOT

    #   post adjustment: remove extra files
    rm -f $RPM_BUILD_ROOT%{l_prefix}/etc/openldap/*.default
    rm -f $RPM_BUILD_ROOT%{l_prefix}/etc/openldap/*/*.default

    #   post adjustment: move files
    rm -f $RPM_BUILD_ROOT%{l_prefix}/etc/openldap/DB_CONFIG.example
%if "%{with_server}" == "yes"
    mv  $RPM_BUILD_ROOT%{l_prefix}/var/openldap/openldap-data/DB_CONFIG.example \
        $RPM_BUILD_ROOT%{l_prefix}/var/openldap/openldap-data/DB_CONFIG
%endif

    #   post adjustment: enable and correct slapd.pid
%if "%{with_server}" == "yes"
    %{l_shtool} subst \
        -e 's;^[ #]*\(pidfile \).*$;\1 %{l_prefix}/var/openldap/run/slapd.pid;' \
        $RPM_BUILD_ROOT%{l_prefix}/etc/openldap/slapd.conf
%endif

    #   post adjustment: remove OSSP fsl dependency from libtool files
%if "%{with_server}" == "yes"
    %{l_shtool} subst \
        -e 's;-lfsl *;;' \
        $RPM_BUILD_ROOT%{l_prefix}/lib/*.la
%endif

    #   install run-command script
%if "%{with_server}" == "yes"
    %{l_shtool} mkdir -f -p -m 755 \
        $RPM_BUILD_ROOT%{l_prefix}/etc/rc.d
    %{l_shtool} install -c -m 755 %{l_value -s -a} \
        %{SOURCE rc.openldap} $RPM_BUILD_ROOT%{l_prefix}/etc/rc.d/
%endif

    #   install OSSP fsl configuration
%if "%{with_server}" == "yes"
    %{l_shtool} mkdir -f -p -m 755 \
        $RPM_BUILD_ROOT%{l_prefix}/etc/fsl
    %{l_shtool} install -c -m 644 %{l_value -s -a} \
        %{SOURCE fsl.openldap} \
        $RPM_BUILD_ROOT%{l_prefix}/etc/fsl/
%endif

    #   install pkg-config configuration
    %{l_shtool} mkdir -f -p -m 755 \
        $RPM_BUILD_ROOT%{l_prefix}/lib/pkgconfig
    libs="-lldap -llber"
%if "%{with_sasl}" == "yes"
    libs="$libs -lsasl2"
%endif
    %{l_shtool} install -c -m 644 %{l_value -s -a} \
        -e "s;@version@;%{version};" \
        -e "s;@libs@;$libs;" \
        %{SOURCE openldap.pc} \
        $RPM_BUILD_ROOT%{l_prefix}/lib/pkgconfig/

    #   optionally remove server-components
%if "%{with_server}" != "yes"
    rm -rf $RPM_BUILD_ROOT%{l_prefix}/etc/openldap/schema
    rm -f $RPM_BUILD_ROOT%{l_prefix}/etc/openldap/slapd.conf
    rm -rf $RPM_BUILD_ROOT%{l_prefix}/sbin
    rm -rf $RPM_BUILD_ROOT%{l_prefix}/libexec/openldap
    rm -f $RPM_BUILD_ROOT%{l_prefix}/include/slapi-plugin.h
    rm -f $RPM_BUILD_ROOT%{l_prefix}/man/man5/slap*
    rm -f $RPM_BUILD_ROOT%{l_prefix}/man/man8/slap*
%endif

    #   determine installation files
    %{l_rpmtool} files -v -ofiles -r$RPM_BUILD_ROOT \
        %{l_files_std} \
%if "%{with_server}" == "yes"
        '%config %{l_prefix}/etc/fsl/fsl.openldap' \
        '%config %{l_prefix}/etc/openldap/schema/*.schema' \
        '%config %{l_prefix}/etc/openldap/schema/*.ldif' \
%endif
        '%config %{l_prefix}/etc/openldap/*.conf'

%files -f files

%clean
    rm -rf $RPM_BUILD_ROOT

%pre
%if "%{with_server}" == "yes"
    #   before upgrade, save status and stop service
    [ $1 -eq 2 ] || exit 0
    eval `%{l_rc} openldap status 2>/dev/null | tee %{l_tmpfile}`
    %{l_rc} openldap stop 2>/dev/null
    exit 0
%endif

%post
    #   after upgrade, restore status
%if "%{with_server}" == "yes"
    [ $1 -eq 2 ] || exit 0
    { eval `cat %{l_tmpfile}`; rm -f %{l_tmpfile}; true; } >/dev/null 2>&1
    [ ".$openldap_active" = .yes ] && %{l_rc} openldap start
    exit 0
%endif

%preun
    #   before erase, stop service and remove log files
%if "%{with_server}" == "yes"
    [ $1 -eq 0 ] || exit 0
    %{l_rc} openldap stop 2>/dev/null
    rm -f $RPM_INSTALL_PREFIX/var/openldap/openldap.log* >/dev/null 2>&1 || true
    exit 0
%endif

