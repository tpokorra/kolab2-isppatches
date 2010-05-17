# Macros
%define         V_package imp-h4
%define         V_gitpath imp
%define         V_commit  9774304b900cf35a6091e7be1761e5c07efa70bb
%define         V_version 4.999
%define         V_release 20100304
%define         V_source_name imp

# Package Information
Name:		%{V_package}
Summary:	IMP provides webmail access to IMAP and POP3 accounts.
URL:		http://www.horde.org/
Packager:	Gunnar Wrobel <wrobel@pardus.de> (p@rdus)
Version:	%{V_version}
Release:	%{V_release}
License:	GPL
Group:		MAIL
Distribution:	OpenPKG

# List of Sources
Source0:	http://ftp.horde.org/pub/%{V_package}/%{V_source_name}-%{V_version}-%{V_commit}.tar.bz2
Source1:        webclient4-imp_conf.php.template
Source2:        webclient4-imp_header.php.template
Source3:        webclient4-imp_hooks.php.template
Source4:        webclient4-imp_menu.php.template
Source5:        webclient4-imp_mime_drivers.php.template
Source6:        webclient4-imp_motd.php.template
Source7:        webclient4-imp_prefs.php.template
Source8:        webclient4-imp_servers.php.template
Source9:        webclient4-imp_spelling.php.template
Source10:       10-kolab_conf_base.php
Source11:       10-kolab_servers_base.php
Source12:       conf.php
Source13:       11-kolab_conf_imp.php

# List of Patches
Patch0:         package.patch

# Build Info
Prefix:		%{l_prefix}
BuildRoot:	%{l_buildroot}

#Pre requisites
BuildPreReq:  OpenPKG, openpkg >= 20070603
BuildPreReq:  php, php::with_pear = yes
PreReq:       horde-h4 >= 3.999
PreReq:       Horde_Imap_Client-H4
PreReq:       Horde_Editor-H4
PreReq:       Horde_Vfs-H4

AutoReq:      no
AutoReqProv:  no

%description 
IMP is the Internet Messaging Program. It is written in PHP and
provides webmail access to IMAP and POP3 accounts.

%prep
	%setup -q -c %{V_package}-%{V_version}

	cd %{V_source_name}-%{V_commit}
	%patch -p1 -P 0
	cd ..

%build

%install

	%{l_shtool} install -d $RPM_BUILD_ROOT%{l_prefix}/var/kolab/www/client4/imp
	%{l_shtool} install -d $RPM_BUILD_ROOT%{l_prefix}/var/kolab/www/client4/config/conf.d
	%{l_shtool} install -d $RPM_BUILD_ROOT%{l_prefix}/var/kolab/webclient4_data/storage
	%{l_shtool} install -d $RPM_BUILD_ROOT%{l_prefix}/etc/kolab/templates	

	cd %{V_source_name}-%{V_commit}

	cd config
	for CONFIG in *.dist;                          \
	    do                                         \
	      cp $CONFIG `basename $CONFIG .dist`;     \
	      mkdir -p `basename $CONFIG .php.dist`.d; \
	done
	cd ..

	#rm test.php

	#find . -type f | grep '\.orig$' | xargs rm -f

	cp -r * $RPM_BUILD_ROOT%{l_prefix}/var/kolab/www/client4/imp

        sqlite $RPM_BUILD_ROOT%{l_prefix}/var/kolab/webclient4_data/storage/imp.db < scripts/sql/imp.sql

	cd ..

	%{l_shtool} install -d $RPM_BUILD_ROOT%{l_prefix}/var/kolab/www/client4/imp/config/conf.d
	%{l_shtool} install -d $RPM_BUILD_ROOT%{l_prefix}/var/kolab/www/client4/imp/config/header.d
	%{l_shtool} install -d $RPM_BUILD_ROOT%{l_prefix}/var/kolab/www/client4/imp/config/hooks.d
	%{l_shtool} install -d $RPM_BUILD_ROOT%{l_prefix}/var/kolab/www/client4/imp/config/menu.d
	%{l_shtool} install -d $RPM_BUILD_ROOT%{l_prefix}/var/kolab/www/client4/imp/config/mime_drivers.d
	%{l_shtool} install -d $RPM_BUILD_ROOT%{l_prefix}/var/kolab/www/client4/imp/config/motd.d
	%{l_shtool} install -d $RPM_BUILD_ROOT%{l_prefix}/var/kolab/www/client4/imp/config/prefs.d
	%{l_shtool} install -d $RPM_BUILD_ROOT%{l_prefix}/var/kolab/www/client4/imp/config/servers.d
	%{l_shtool} install -d $RPM_BUILD_ROOT%{l_prefix}/var/kolab/www/client4/imp/config/spelling.d

	%{l_shtool} install -c -m 644 %{l_value -s -a} %{S:1} %{S:2} %{S:3} %{S:4} %{S:5} %{S:6} %{S:7} %{S:8} %{S:9} \
	  $RPM_BUILD_ROOT%{l_prefix}/etc/kolab/templates

	%{l_shtool} install -c -m 644 %{l_value -s -a} %{S:10} $RPM_BUILD_ROOT%{l_prefix}/var/kolab/www/client4/imp/config/conf.d/
	%{l_shtool} install -c -m 644 %{l_value -s -a} %{S:11} $RPM_BUILD_ROOT%{l_prefix}/var/kolab/www/client4/imp/config/servers.d/
	%{l_shtool} install -c -m 644 %{l_value -s -a} %{S:12} $RPM_BUILD_ROOT%{l_prefix}/var/kolab/www/client4/imp/config/
	%{l_shtool} install -c -m 644 %{l_value -s -a} %{S:13} $RPM_BUILD_ROOT%{l_prefix}/var/kolab/www/client4/config/conf.d/

	sed -i -e 's#@@@horde_confdir@@@#%{l_prefix}/var/kolab/www/client4/imp/config#' $RPM_BUILD_ROOT%{l_prefix}/etc/kolab/templates/*.php.template

	%{l_rpmtool} files -v -ofiles -r$RPM_BUILD_ROOT %{l_files_std} \
            '%config %{l_prefix}/etc/kolab/templates/webclient4-imp_conf.php.template' \
            '%config %{l_prefix}/etc/kolab/templates/webclient4-imp_header.php.template' \
            '%config %{l_prefix}/etc/kolab/templates/webclient4-imp_hooks.php.template' \
            '%config %{l_prefix}/etc/kolab/templates/webclient4-imp_menu.php.template' \
            '%config %{l_prefix}/etc/kolab/templates/webclient4-imp_mime_drivers.php.template' \
            '%config %{l_prefix}/etc/kolab/templates/webclient4-imp_motd.php.template' \
            '%config %{l_prefix}/etc/kolab/templates/webclient4-imp_prefs.php.template' \
            '%config %{l_prefix}/etc/kolab/templates/webclient4-imp_servers.php.template' \
            '%config %{l_prefix}/etc/kolab/templates/webclient4-imp_spelling.php.template' \
            '%config(noreplace) %defattr(-,%{l_nusr},%{l_ngrp}) %{l_prefix}/var/kolab/webclient4_data/storage/imp.db' \
            %dir '%defattr(-,%{l_nusr},%{l_ngrp})' %{l_prefix}/var/kolab/webclient4_data/storage \
	    '%defattr(-,%{l_nusr},%{l_ngrp})' %{l_prefix}/var/kolab/www/client4/imp/config/conf.php


%clean
	rm -rf $RPM_BUILD_ROOT

%files -f files
