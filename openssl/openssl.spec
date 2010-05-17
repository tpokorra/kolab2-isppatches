##
##  openssl.spec -- OpenPKG RPM Package Specification
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

#   package version
%define       V_openssl 1.0.0
%define       V_zlib    1.2.5

#   package information
Name:         openssl
Summary:      Cryptography and SSL/TLS Toolkit
URL:          http://www.openssl.org/
Vendor:       The OpenSSL Project
Packager:     OpenPKG Foundation e.V.
Distribution: OpenPKG Community
Class:        CORE
Group:        SSL
License:      BSD-style
Version:      %{V_openssl}
Release:      20100420

#   package options
%option       with_zlib     no
%option       with_idea     no
%option       with_threads  no
%option       with_pic      no

#   list of sources
Source0:      ftp://ftp.openssl.org/source/openssl-%{V_openssl}.tar.gz
Source1:      http://www.zlib.net/zlib-%{V_zlib}.tar.gz
Patch0:       openssl.patch

#   build information
Prefix:       %{l_prefix}
BuildRoot:    %{l_buildroot}
BuildPreReq:  OpenPKG, openpkg >= 20060823, perl, make, gcc
PreReq:       OpenPKG, openpkg >= 20060823, perl
%if "%{with_zlib}" == "yes"
BuildPreReq:  zlib
PreReq:       zlib
%endif
AutoReq:      no
AutoReqProv:  no

%description
    The OpenSSL Project is a collaborative effort to develop a robust,
    commercial-grade, full-featured, and Open Source toolkit implementing the
    Secure Sockets Layer (SSL v2/v3) and Transport Layer Security (TLS v1)
    protocols with full-strength cryptography world-wide. The project is
    managed by a worldwide community of volunteers that use the Internet to
    communicate, plan, and develop the OpenSSL tookit and its related
    documentation.

%prep
    %setup -q
%if "%{with_zlib}" == "yes"
    %setup -q -D -T -a 1
%endif
    %patch -p0
    %{l_shtool} subst \
        -e 's;-march=pentium;;g' \
        -e 's;-m486;-march=i486;g' \
        Configure
    %{l_shtool} subst \
        -e 's;BN_LLONG *;;' \
        Configure
    %{l_shtool} subst \
        -e 's;test "$OSTYPE" = msdosdjgpp;true;' \
        util/point.sh
    %{l_shtool} subst \
        -e 's;^\(#define DEVRANDOM_EGD\);\1 "%{l_prefix}/var/prngd/prngd.socket",;' \
        e_os.h
    %{l_shtool} subst \
        -e 's;^\(my $openssl\)\;;\1 = "%{l_prefix}/bin/openssl"\;;' \
        tools/c_rehash.in
%if "%{with_zlib}" == "yes"
    %{l_shtool} subst \
        -e "s;\\(-DZLIB_SHARED\\);-I`pwd`/zlib-%{V_zlib} \\1;" \
        Configure
    %{l_shtool} subst \
        -e 's;, "z",;, "%{l_prefix}/lib/openssl/zlib.so",;' \
        crypto/comp/c_zlib.c
%endif

%build
%if "%{with_zlib}" == "yes"
    ( cd zlib-%{V_zlib}
      CC="%{l_cc}" \
      CFLAGS="%{l_cflags -O}" \
      ./configure \
          --prefix=%{l_prefix} \
          --shared
      %{l_make} %{l_mflags -O}
    ) || exit $?
%endif
    %{l_prefix}/bin/perl util/perlpath.pl %{l_prefix}/bin/perl
    options="no-shared no-dso"
%if "%{with_pic}" == "yes"
    options="$options -fPIC"
    case "%{l_platform -t}" in
        amd64-*          ) options="$options no-asm" ;;
        sparc64-freebsd* ) options="$options no-asm" ;;
    esac
%else
    case "%{l_platform -t}" in
        amd64-*          ) options="$options -fPIC no-asm" ;;
        ia64-*           ) options="$options -fPIC"        ;;
        sparc64-freebsd* ) options="$options -fPIC no-asm" ;;
    esac
%endif
%if "%{with_zlib}" == "yes"
    options="$options zlib-dynamic"
%else
    options="$options no-zlib"
%endif
%if "%{with_idea}" != "yes"
    options="$options no-idea"
%endif
%if "%{with_threads}" == "yes"
    options="$options threads"
%else
    options="$options no-threads"
%endif
    PERL=%{l_prefix}/bin/perl \
    ./config \
        --prefix=%{l_prefix} \
        --openssldir=%{l_prefix}/etc/openssl \
        --libdir=lib \
        $options
    %{l_make} %{l_mflags}

%install
    rm -rf $RPM_BUILD_ROOT
    %{l_make} %{l_mflags} install INSTALL_PREFIX=$RPM_BUILD_ROOT
    strip $RPM_BUILD_ROOT%{l_prefix}/bin/openssl >/dev/null 2>&1 || true
    ( cd $RPM_BUILD_ROOT%{l_prefix}
      rmdir lib/engines
      rm -rf etc/openssl/private
      rm -rf etc/openssl/certs
      rm -rf etc/openssl/misc
      rm -rf etc/openssl/lib
      mv etc/openssl/man man
      mv bin/c_rehash bin/openssl-crehash
      cd man
      for dir in man[1-9]; do
          for file in `cd $dir; echo *`; do
              mv $dir/$file $dir/openssl_$file
          done
      done
    ) || exit $?
%if "%{with_zlib}" == "yes"
    %{l_shtool} mkdir -f -p -m 755 \
        $RPM_BUILD_ROOT%{l_prefix}/libexec/openssl
    %{l_shtool} install -c -m 644 \
        zlib-%{V_zlib}/libz.so \
        $RPM_BUILD_ROOT%{l_prefix}/libexec/openssl/zlib.so
%endif
    %{l_rpmtool} files -v -ofiles -r$RPM_BUILD_ROOT \
        %{l_files_std} \
        '%config %{l_prefix}/etc/openssl/openssl.cnf'

%files -f files

%clean
    rm -rf $RPM_BUILD_ROOT

