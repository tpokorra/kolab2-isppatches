##
##  apache.spec -- OpenPKG RPM Package Specification
##  Copyright (c) 2000-2010 OpenPKG Foundation e.V. <http://openpkg.net/>
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
Name:         apache
Summary:      Apache HTTP Server
URL:          http://httpd.apache.org/
Vendor:       Apache Software Foundation
Packager:     OpenPKG Foundation e.V.
Distribution: OpenPKG Community
Class:        BASE
Group:        Web
License:      ASF
Version:      2.2.15
Release:      20100406

#   package options
%option       with_mpm_prefork          yes
%option       with_mpm_worker           no
%option       with_mpm_event            no
%option       with_suexec               yes
%option       with_suexec_caller        %{l_nusr}
%option       with_suexec_userdir       public_html
%option       with_mod_deflate          no
%option       with_mod_ext_filter       no
%option       with_mod_substitute       no
%option       with_mod_ssl              no
%option       with_mod_dav              no
%option       with_mod_ldap             no
%option       with_mod_dbd              no
%option       with_mod_proxy            no
%option       with_mod_cache            no
%option       with_mod_diskcache        no
%option       with_mod_memcache         no
%option       with_mod_filecache        no
%option       with_mod_authn_alias      no

#   fixing implicit inter-module dependencies and correlations
%if "%{with_mpm_prefork}" == "yes"
%undefine     with_mpm_worker
%undefine     with_mpm_event
%endif
%if "%{with_mpm_worker}" == "yes"
%undefine     with_mpm_prefork
%undefine     with_mpm_event
%endif
%if "%{with_mpm_event}" == "yes"
%undefine     with_mpm_prefork
%undefine     with_mpm_worker
%endif
%if "%{with_mod_memcache}" == "yes" || "%{with_mod_diskcache}" == "yes"
%undefine     with_mod_cache
%define       with_mod_cache            yes
%endif

#   list of sources
Source0:      http://www.apache.org/dist/httpd/httpd-%{version}.tar.bz2
Source1:      rc.apache
Source2:      apache.base
Source3:      apache.conf
Source4:      apache.sh
Patch0:       apache.patch

#   build information
Prefix:       %{l_prefix}
BuildRoot:    %{l_buildroot}
BuildPreReq:  OpenPKG, openpkg >= 20060823, perl, make
PreReq:       OpenPKG, openpkg >= 20060823, perl
BuildPreReq:  apr, pcre
PreReq:       apr, pcre
%if "%{with_mpm_worker}" == "yes" || "%{with_mpm_event}" == "yes" || "%{with_mod_memcache}" == "yes"
BuildPreReq:  apr::with_threads = yes
PreReq:       apr::with_threads = yes
%endif
%if "%{with_mod_ldap}" == "yes"
BuildPreReq:  apr::with_ldap = yes
PreReq:       apr::with_ldap = yes
%endif
%if "%{with_mod_ssl}" == "yes"
BuildPreReq:  openssl >= 0.9.8
PreReq:       openssl >= 0.9.8
PreReq:       x509
%endif
%if "%{with_mod_deflate}" == "yes"
BuildPreReq:  zlib
PreReq:       zlib
%endif
AutoReq:      no
AutoReqProv:  no

%description
    The Apache Project is a collaborative software development effort
    aimed at creating a robust, commercial-grade, featureful, and
    freely-available source code implementation of an HTTP (Web) server.
    The project is jointly managed by a group of volunteers located
    around the world, using the Internet and the Web to communicate,
    plan, and develop the server and its related documentation. These
    volunteers are known as the Apache Group. In addition, hundreds
    of users have contributed ideas, code, and documentation to the
    project.

%track
    prog apache = {
        version   = %{version}
        url       = http://www.apache.org/dist/httpd/
        regex     = httpd-(2\.\d*[02468]\.\d+)\.tar\.(bz2|gz)
    }

%prep
    #   unpack Apache distribution
    %setup -q -n httpd-%{version}
    %patch -p0
    %{l_shtool} subst \
        -e 's;(" PLATFORM ");(%{l_openpkg_release -F "OpenPKG/%%t"});g' \
        server/core.c

%build
    #   configure package
    ( echo "ac_cv_func_uuid_create=no"
    ) >config.cache
    export CC="%{l_cc}"
    export CFLAGS="%{l_cflags -O}"
    export CPPFLAGS="%{l_cppflags}"
    export LDFLAGS="%{l_ldflags}"
    export LIBS=""
    case "%{l_platform -t}" in
        *-sunos* ) LIBS="$LIBS -lrt" ;;
    esac
%if "%{with_mod_ldap}" == "yes"
    LIBS="$LIBS -lssl -lcrypto"
%endif
    ./configure \
        --cache-file=./config.cache \
        --enable-layout=GNU \
        --prefix=%{l_prefix} \
        --with-program-name=apache \
        --sysconfdir=%{l_prefix}/etc/apache \
        --libexecdir=%{l_prefix}/libexec/apache \
        --includedir=%{l_prefix}/include/apache \
        --datadir=%{l_prefix}/share/apache \
        --localstatedir=%{l_prefix}/var/apache \
        --with-apr=%{l_prefix}/bin/apr-1-config \
        --with-apr-util=%{l_prefix}/bin/apu-1-config \
        --with-pcre=%{l_prefix} \
%if "%{with_mpm_prefork}" == "yes"
        --with-mpm="prefork" \
%endif
%if "%{with_mpm_worker}" == "yes"
        --with-mpm="worker" \
%endif
%if "%{with_mpm_event}" == "yes"
        --with-mpm="event" \
%endif
%if "%{with_mpm_worker}" == "yes" || "%{with_mpm_event}" == "yes" || "%{with_mod_memcache}" == "yes"
        --enable-threads \
%else
        --disable-threads \
%endif
%if "%{with_suexec}" == "yes"
        --enable-suexec \
        --with-suexec-bin=%{l_prefix}/sbin/suexec \
        --with-suexec-caller=%{with_suexec_caller} \
        --with-suexec-userdir=%{with_suexec_userdir} \
        --with-suexec-logfile=%{l_prefix}/var/apache/log/suexec.log \
%endif
%if "%{with_mod_deflate}" == "yes"
        --enable-deflate \
        --with-z=%{l_prefix} \
%endif
%if "%{with_mod_ext_filter}" == "yes"
        --enable-ext-filter \
%endif
%if "%{with_mod_substitute}" == "yes"
        --enable-substitute \
%endif
%if "%{with_mod_ssl}" == "yes"
        --enable-ssl \
        --with-ssl=%{l_prefix} \
%endif
%if "%{with_mod_dav}" == "yes"
        --enable-dav \
        --enable-dav-fs \
        --enable-dav-lock \
%endif
%if "%{with_mod_ldap}" == "yes"
        --enable-ldap \
        --enable-authnz-ldap \
%endif
%if "%{with_mod_dbd}" == "yes"
        --enable-dbd \
        --enable-authn-dbd \
%endif
%if "%{with_mod_proxy}" == "yes"
        --enable-proxy \
        --enable-proxy-connect \
        --enable-proxy-http \
        --enable-proxy-ftp \
        --enable-proxy-ajp \
        --enable-proxy-balancer \
%endif
%if "%{with_mod_cache}" == "yes"
        --enable-cache \
%if "%{with_mod_diskcache}" == "yes"
        --enable-disk-cache \
%endif
%if "%{with_mod_memcache}" == "yes"
        --enable-mem-cache \
%endif
%endif
%if "%{with_mod_filecache}" == "yes"
        --enable-file-cache \
%endif
%if "%{with_mod_authn_alias}" == "yes"
        --enable-authn-alias \
%endif
        --enable-filter \
        --enable-reqtimeout \
        --enable-usertrack \
        --enable-expires \
        --enable-so \
        --enable-speling \
        --enable-rewrite \
        --enable-headers \
        --enable-info \
        --enable-mime-magic \
        --enable-vhost-alias \
        --enable-auth-digest \
        --enable-auth-dbm \
        --enable-authz-dbm \
        --enable-authz-owner \
        --enable-unique-id \
        --enable-logio \
        --disable-shared

    #   build package
    %{l_make} %{l_mflags}

%install
    #   install package
    rm -rf $RPM_BUILD_ROOT
    %{l_make} %{l_mflags} install DESTDIR=$RPM_BUILD_ROOT

    #   create additional directories
    %{l_shtool} mkdir -f -p -m 755 \
        $RPM_BUILD_ROOT%{l_prefix}/etc/rc.d \
        $RPM_BUILD_ROOT%{l_prefix}/etc/apache/apache.d \
        $RPM_BUILD_ROOT%{l_prefix}/var/apache/run/apache.dav \
        $RPM_BUILD_ROOT%{l_prefix}/var/apache/run/apache.cache

    #   adjust GNU libtool configuration for apxs(1) runtime
    %{l_shtool} install -c -m 755 \
        -e 's;^build_libtool_libs=no;build_libtool_libs=yes;' \
        %{l_prefix}/share/apr/build-1/libtool \
        $RPM_BUILD_ROOT%{l_prefix}/share/apache/build/libtool

    #   install shell environment script
    %{l_shtool} install -c -m 644 %{l_value -s -a} \
         -e 's;@l_path@;%{l_build_path};' \
         -e 's;@l_ld_library_path@;%{l_build_ldlp};' \
         %{SOURCE apache.sh} \
         $RPM_BUILD_ROOT%{l_prefix}/etc/apache/

    #   create default configuration
    l_hostname=`%{l_shtool} echo -e %h`
    l_domainname=`%{l_shtool} echo -e %d | cut -c2-`
    %{l_shtool} install -c -m 644 %{l_value -s -a} \
        -e "s;@l_hostname@;$l_hostname;g" \
        -e "s;@l_domainname@;$l_domainname;g" \
        %{SOURCE apache.base} \
        %{SOURCE apache.conf} \
        $RPM_BUILD_ROOT%{l_prefix}/etc/apache/
    mv  $RPM_BUILD_ROOT%{l_prefix}/etc/apache/magic \
        $RPM_BUILD_ROOT%{l_prefix}/etc/apache/mime.magic

    #   install run-command script
    %{l_shtool} install -c -m 755 %{l_value -s -a} \
        -e 's;@with_mod_filecache@;%{with_mod_filecache};g' \
        %{SOURCE rc.apache} \
        $RPM_BUILD_ROOT%{l_prefix}/etc/rc.d/

    #   strip down installation
    find $RPM_BUILD_ROOT%{l_prefix}/share/apache -name "*.orig" -print | xargs rm -f
    rm -f $RPM_BUILD_ROOT%{l_prefix}/share/apache/htdocs/apache_pb*
    rm -rf $RPM_BUILD_ROOT%{l_prefix}/etc/apache/{extra,original}
    rm -rf $RPM_BUILD_ROOT%{l_prefix}/libexec/apache
    rm -f $RPM_BUILD_ROOT%{l_prefix}/cgi/test-cgi
    strip $RPM_BUILD_ROOT%{l_prefix}/bin/* >/dev/null 2>&1 || true
    strip $RPM_BUILD_ROOT%{l_prefix}/sbin/* >/dev/null 2>&1 || true
    ( cd $RPM_BUILD_ROOT%{l_prefix}/share/apache/manual
      find . -name "*.xml"   -print | xargs rm -f
      find . -name "*.xml.*" -print | xargs rm -f
      find . -name "*.xsl"   -print | xargs rm -f
      rm -rf style/xsl
      rm -rf style/latex
    ) || exit $?

    #   determine installation files
    %{l_rpmtool} files -v -ofiles -r$RPM_BUILD_ROOT \
        %{l_files_std} \
%if "%{with_suexec}" == "yes"
        '%attr(4755,%{l_susr},%{l_mgrp}) %{l_prefix}/sbin/suexec' \
%endif
        '%config %{l_prefix}/etc/apache/*' \
        '%config %attr(444,%{l_musr},%{l_mgrp}) %{l_prefix}/etc/apache/apache.base' \
        '%dir %attr(750,%{l_nusr},%{l_ngrp}) %{l_prefix}/var/apache/run/apache.dav' \
        '%dir %attr(750,%{l_nusr},%{l_ngrp}) %{l_prefix}/var/apache/run/apache.cache'

%files -f files

%clean
    rm -rf $RPM_BUILD_ROOT

%post
    #   after upgrade, restart service
    [ $1 -eq 2 ] || exit 0
    eval `%{l_rc} apache status 2>/dev/null`
    [ ".$apache_active" = .yes ] && %{l_rc} apache restart
    exit 0

%preun
    #   before erase, stop service and remove log files
    [ $1 -eq 0 ] || exit 0
    %{l_rc} apache stop 2>/dev/null
    rm -f $RPM_INSTALL_PREFIX/var/apache/log/*   >/dev/null 2>&1 || true
    rm -f $RPM_INSTALL_PREFIX/var/apache/run/*/* >/dev/null 2>&1 || true
    rm -f $RPM_INSTALL_PREFIX/var/apache/run/*   >/dev/null 2>&1 || true
    exit 0

