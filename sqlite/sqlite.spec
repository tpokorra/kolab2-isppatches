##
##  sqlite.spec -- OpenPKG RPM Package Specification
##  Copyright (c) 2000-2007 OpenPKG Foundation e.V. <http://openpkg.net/>
##  Copyright (c) 2000-2007 Ralf S. Engelschall <http://engelschall.com/>
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
%define       V_v3   3.6.22
%define       V_v2   2.8.17

#   package information
Name:         sqlite
Summary:      SQL Lite
URL:          http://www.sqlite.org/
Vendor:       D. Richard Hipp
Packager:     Gunnar Wrobel <wrobel@pardus.de> (p@rdus)
Distribution: OpenPKG
Group:        Database
License:      PD
Version:      %{V_v3}
Release:      20100309

#   package options
%option       with_utf8            no
%option       with_assert          no
%option       with_readline        no
%option       with_threads         no
%option       with_fts3            no
%option       with_rtree           no

#   list of sources
Source0:      http://www.sqlite.org/sqlite-%{V_v3}.tar.gz
Source1:      http://www.sqlite.org/sqlite-%{V_v2}.tar.gz
Patch0:       sqlite.patch.v2
Patch1:       sqlite.patch.v3

#   build information
Prefix:       %{l_prefix}
BuildRoot:    %{l_buildroot}
BuildPreReq:  OpenPKG, openpkg >= 20040130, make, gawk
PreReq:       OpenPKG, openpkg >= 20040130
%if "%{with_readline}" == "yes"
BuildPreReq:  readline, pkgconfig
PreReq:       readline
%endif
AutoReq:      no
AutoReqProv:  no

%description
    SQLite is a C library that implements an embeddable SQL database
    engine. Programs that link with the SQLite library can have SQL
    database access without running a separate RDBMS process. The
    distribution comes with a standalone command-line access program
    (sqlite) that can be used to administer an SQLite database and which
    serves as an example of how to use the SQLite library. SQLite is not
    a client library used to connect to a big database server. SQLite is
    the server. The SQLite library reads and writes directly to and from
    the database files on disk.

    This package contains both SQLite 3 (%{V_v3}) and optionally the old
    SQLite 2 (%{V_v2}). Notice that the two are API and database format
    incompatible but can be used in parallel (on different databases).
    Additionally, this package optionally provides the SQLite ODBC driver.

%prep
    %setup -q -c
    %setup -q -D -T -a 1
    %patch -p0 -P 0
    %patch -p0 -P 1

    #   post-adjust sources
    chmod a+x sqlite-%{V_v2}/install-sh
    %{l_shtool} subst \
        -e '/LINENO: error: C[+]* preprocessor/{N;N;N;N;s/.*/:/;}' \
        sqlite-%{V_v3}/configure sqlite-%{V_v2}/configure

%build
    #   configure and build SQLite 3 and SQLite 2
    cd sqlite-%{V_v2}
    CC="%{l_cc}"
    export CC
    CPPFLAGS="%{l_cppflags}"
    export CPPFLAGS
    CFLAGS="%{l_cflags -O}"
    export CFLAGS
    LDFLAGS="%{l_ldflags}"
    export LDFLAGS
    LIBS=""
    export LIBS
%if "%{with_assert}" == "no"
    CFLAGS="$CFLAGS -DNDEBUG=1"
%endif
%if "%{with_readline}" == "yes"
    config_TARGET_READLINE_INC="%{l_cppflags readline} `%{l_prefix}/bin/pkg-config --cflags readline`"
    export config_TARGET_READLINE_INC
    config_TARGET_READLINE_LIBS="%{l_ldflags} `%{l_prefix}/bin/pkg-config --libs readline`"
    export config_TARGET_READLINE_LIBS
%endif
    ./configure \
        --prefix=%{l_prefix} \
%if "%{with_utf8}" == "yes"
        --enable-utf8 \
%endif
%if "%{with_threads}" == "yes"
        --enable-threadsafe \
%endif
        --disable-shared
%if "%{with_assert}" == "yes"
    %{l_shtool} subst \
        -e 's;-DNDEBUG;;' \
        Makefile
%endif
    MFLAGS=""
    %{l_make} %{l_mflags -O} $MFLAGS
    cd ..


    #   configure and build SQLite
    cd sqlite-%{V_v3}
    CC="%{l_cc}"
    CFLAGS="%{l_cflags -O}"
    CPPFLAGS="-I. %{l_cppflags}"
    LDFLAGS="%{l_ldflags}"
    LIBS="-lm"
    export CC
    export CPPFLAGS
    export CFLAGS
    export LDFLAGS
    export LIBS
    GREP="grep" \
    ./configure \
        --prefix=%{l_prefix} \
%if "%{with_threads}" == "yes"
        --enable-threadsafe \
%else
        --disable-threadsafe \
%endif
%if "%{with_readline}" == "yes"
        --enable-readline \
        --with-readline-lib="`%{l_prefix}/bin/pkg-config --libs readline`" \
        --with-readline-inc="`%{l_prefix}/bin/pkg-config --cflags readline`" \
%else
        --disable-readline \
%endif
%if "%{with_debug}" == "yes"
        --enable-debug \
%else
        --disable-debug \
%endif
        --disable-tcl \
        --disable-amalgamation \
        --disable-shared \
        --enable-load-extension
    MFLAGS=""
%if "%{with_fts3}" == "yes"
    MFLAGS="$MFLAGS FTS3=1"
%endif
%if "%{with_rtree}" == "yes"
    MFLAGS="$MFLAGS RTREE=1"
%endif
    %{l_make} %{l_mflags -O} $MFLAGS
    cd ..


%install
    #   create installation hierarchy
    rm -rf $RPM_BUILD_ROOT
    %{l_shtool} mkdir -f -p -m 755 \
        $RPM_BUILD_ROOT%{l_prefix}/bin \
        $RPM_BUILD_ROOT%{l_prefix}/lib \
        $RPM_BUILD_ROOT%{l_prefix}/include \
        $RPM_BUILD_ROOT%{l_prefix}/man/man1

    #   install SQLite 3
    ( cd sqlite-%{V_v3}
      %{l_make} %{l_mflags} install \
          prefix=$RPM_BUILD_ROOT%{l_prefix}
      %{l_shtool} install -c -m 644 \
          sqlite3.1 $RPM_BUILD_ROOT%{l_prefix}/man/man1/sqlite3.1
    ) || exit $?

    #   install SQLite 2
    ( cd sqlite-%{V_v2}
      %{l_make} %{l_mflags} install \
          prefix=$RPM_BUILD_ROOT%{l_prefix}
      %{l_shtool} install -c -m 644 \
          sqlite.1 $RPM_BUILD_ROOT%{l_prefix}/man/man1/sqlite.1
    ) || exit $?

    #   strip down installation files
    strip $RPM_BUILD_ROOT%{l_prefix}/bin/* >/dev/null 2>&1 || true

    #   determine installation files
    %{l_rpmtool} files -v -ofiles -r$RPM_BUILD_ROOT \
        %{l_files_std} \
        '%not %dir %{l_prefix}/lib/pkgconfig'

%files -f files

%clean
    rm -rf $RPM_BUILD_ROOT
