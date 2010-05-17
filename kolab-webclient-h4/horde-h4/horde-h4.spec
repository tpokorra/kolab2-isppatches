# Macros
%define         V_package horde-h4
%define         V_commit  9774304b900cf35a6091e7be1761e5c07efa70bb
%define         V_version 3.999
%define         V_release 20100304
%define         V_source_name horde

# Package Information
Name:		%{V_package}
Summary:	The Horde base application.
URL:		http://www.horde.org/
Packager:	Gunnar Wrobel <wrobel@pardus.de> (p@rdus)
Version:	%{V_version}
Release:	%{V_release}
License:	GPL
Group:		MAIL
Distribution:	OpenPKG

# List of Sources
Source0:	http://ftp.horde.org/pub/%{V_package}/%{V_source_name}-%{V_version}-%{V_commit}.tar.bz2
Source1:        webclient4-conf.php.template
Source2:        webclient4-hooks.php.template
Source3:        webclient4-mime_drivers.php.template
Source4:        webclient4-motd.php.template
Source5:        webclient4-nls.php.template
Source6:        webclient4-prefs.php.template
Source7:        webclient4-registry.php.template
Source8:        10-kolab_hooks_base.php
Source9:        10-kolab_prefs_base.php
Source10:       10-kolab_conf_base.php

# List of Patches
Patch0:         package.patch

# Build Info
Prefix:		%{l_prefix}
BuildRoot:	%{l_buildroot}

#Pre requisites
BuildPreReq:  OpenPKG, openpkg >= 20070603
BuildPreReq:  php, php::with_pear = yes
PreReq:       kolabd
PreReq:       Horde_Autoloader-H4
PreReq:       Horde_Browser-H4
PreReq:       Horde_Core-H4
PreReq:       Horde_Log-H4

AutoReq:      no
AutoReqProv:  no

%description 
The Horde Application Framework is a general-purpose web application
framework in PHP, providing classes for dealing with preferences,
compression, browser detection, connection tracking, MIME handling,
and more.

This specific package does however remove all components of the actual
Horde framework and solely installs the base Horde application that
needs to be installed as a basis for the other Horde applications. The
Horde framework is installed using PEAR based packages.


%prep
	%setup -q -c %{V_source_name}-%{V_version}-%{V_commit}

	cd %{V_source_name}-%{V_commit}
	%patch -p1 -P 0
	cd ..

%build

%install

	%{l_shtool} install -d $RPM_BUILD_ROOT%{l_prefix}/var/kolab/www/client4
	%{l_shtool} install -d $RPM_BUILD_ROOT%{l_prefix}/var/kolab/webclient4_data/storage
	%{l_shtool} install -d $RPM_BUILD_ROOT%{l_prefix}/var/kolab/webclient4_data/log
	%{l_shtool} install -d $RPM_BUILD_ROOT%{l_prefix}/var/kolab/webclient4_data/tmp
	%{l_shtool} install -d $RPM_BUILD_ROOT%{l_prefix}/var/kolab/webclient4_data/sessions
	%{l_shtool} install -d $RPM_BUILD_ROOT%{l_prefix}/etc/kolab/templates	

	cd %{V_source_name}-%{V_commit}

	cd config
	for CONFIG in *.dist;                          \
	    do                                         \
	      cp $CONFIG `basename $CONFIG .dist`;     \
	      mkdir -p `basename $CONFIG .php.dist`.d; \
	done
	cd ..

#	rm test.php

	#find . -type f | grep '\.orig$' | xargs rm -f

	cp -r * $RPM_BUILD_ROOT%{l_prefix}/var/kolab/www/client4/

        sqlite $RPM_BUILD_ROOT%{l_prefix}/var/kolab/webclient4_data/storage/horde.db < scripts/sql/horde_alarms.sql
        sqlite $RPM_BUILD_ROOT%{l_prefix}/var/kolab/webclient4_data/storage/horde.db < scripts/sql/horde_perms.sql
        sqlite $RPM_BUILD_ROOT%{l_prefix}/var/kolab/webclient4_data/storage/horde.db < scripts/sql/horde_syncml.sql

	cd ..

	%{l_shtool} install -d $RPM_BUILD_ROOT%{l_prefix}/var/kolab/www/client4/config/conf.d
	%{l_shtool} install -d $RPM_BUILD_ROOT%{l_prefix}/var/kolab/www/client4/config/hooks.d
	%{l_shtool} install -d $RPM_BUILD_ROOT%{l_prefix}/var/kolab/www/client4/config/mime.d
	%{l_shtool} install -d $RPM_BUILD_ROOT%{l_prefix}/var/kolab/www/client4/config/motd.d
	%{l_shtool} install -d $RPM_BUILD_ROOT%{l_prefix}/var/kolab/www/client4/config/nls.d
	%{l_shtool} install -d $RPM_BUILD_ROOT%{l_prefix}/var/kolab/www/client4/config/prefs.d
	%{l_shtool} install -d $RPM_BUILD_ROOT%{l_prefix}/var/kolab/www/client4/config/registry.d

	%{l_shtool} install -c -m 644 %{l_value -s -a} %{S:1} %{S:2} %{S:3} %{S:4} %{S:5} %{S:6} %{S:7} \
	  $RPM_BUILD_ROOT%{l_prefix}/etc/kolab/templates

	%{l_shtool} install -c -m 644 %{l_value -s -a} %{S:8} $RPM_BUILD_ROOT%{l_prefix}/var/kolab/www/client4/config/hooks.d/
	%{l_shtool} install -c -m 644 %{l_value -s -a} %{S:9} $RPM_BUILD_ROOT%{l_prefix}/var/kolab/www/client4/config/prefs.d/
	%{l_shtool} install -c -m 644 %{l_value -s -a} %{S:10} $RPM_BUILD_ROOT%{l_prefix}/var/kolab/www/client4/config/conf.d/

	sed -i -e 's#@@@webserver_document_root@@@#%{l_prefix}/var/kolab/www#' $RPM_BUILD_ROOT%{l_prefix}/etc/kolab/templates/*.php.template

	%{l_rpmtool} files -v -ofiles -r$RPM_BUILD_ROOT %{l_files_std} \
	    '%config %{l_prefix}/etc/kolab/templates/webclient4-conf.php.template' \
            '%config %{l_prefix}/etc/kolab/templates/webclient4-hooks.php.template' \
            '%config %{l_prefix}/etc/kolab/templates/webclient4-mime_drivers.php.template' \
            '%config %{l_prefix}/etc/kolab/templates/webclient4-motd.php.template' \
            '%config %{l_prefix}/etc/kolab/templates/webclient4-nls.php.template' \
            '%config %{l_prefix}/etc/kolab/templates/webclient4-prefs.php.template' \
            '%config %{l_prefix}/etc/kolab/templates/webclient4-registry.php.template' \
            %dir '%defattr(-,%{l_nusr},%{l_ngrp})' %{l_prefix}/var/kolab/webclient4_data/log \
            %dir '%defattr(-,%{l_nusr},%{l_ngrp})' %{l_prefix}/var/kolab/webclient4_data/storage \
            %dir '%defattr(-,%{l_nusr},%{l_ngrp})' %{l_prefix}/var/kolab/webclient4_data/storage/horde.db \
            %dir '%defattr(-,%{l_nusr},%{l_ngrp})' %{l_prefix}/var/kolab/webclient4_data/tmp \
            %dir '%defattr(-,%{l_nusr},%{l_ngrp})' %{l_prefix}/var/kolab/webclient4_data/sessions \
	    '%defattr(-,%{l_nusr},%{l_ngrp})' %{l_prefix}/var/kolab/www/client4/config/conf.php

%clean
	rm -rf $RPM_BUILD_ROOT

%files -f files
