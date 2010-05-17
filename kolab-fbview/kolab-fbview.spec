# Versions
%define         V_horde_name horde-webmail
%define         V_package kolab-fbview
%define         V_year  2009
%define         V_month 04
%define         V_day   26
%define         V_version 1.2.0
%define         V_source_version 1.2
%define         V_date %{V_year}-%{V_month}-%{V_day}
%define         V_release %{V_year}%{V_month}%{V_day}

# Package Information
Name:		%{V_package}
Summary:	The Kolab Groupware fbview tool (based on horde)
URL:		http://www.kolab.org/
Packager:	Gunnar Wrobel <wrobel@pardus.de> (p@rdus)
Version:	%{V_version}
Release:	%{V_release}
License:	GPL
Group:		MAIL
Distribution:	OpenPKG

# List of Sources
Source0:	http://ftp.horde.org/pub/%{V_horde_name}/%{V_horde_name}-%{V_source_version}.tar.gz
Source1:        fbview-kolab-conf.template
Source2:        fbview-kronolith-kolab-conf.template

# List of Patches
Patch0:         series.patch

# Build Info
Prefix:		%{l_prefix}
BuildRoot:	%{l_buildroot}

#Pre requisites
BuildPreReq:  OpenPKG, openpkg >= 20070603
BuildPreReq:  php, php::with_pear = yes
PreReq:       kolabd
PreReq:       Kolab_Format >= 1.0.1
PreReq:       Kolab_Server >= 0.5.0
PreReq:       Kolab_Storage >= 0.4.0

Obsoletes:    fbview-horde, fbview-kronolith

AutoReq:      no
AutoReqProv:  no
#BuildArch:    noarch

%description 
Kolab fbview provides a reduced Horde webmail version that allow to
get a quick overview on the free/busy information from team members.

%prep
	%setup -q -c %{V_horde_name}-%{V_source_version}

	cd %{V_horde_name}-%{V_source_version}
	%patch -p2 -P 0
	cd ..

%build

%install

	%{l_shtool} install -d $RPM_BUILD_ROOT%{l_prefix}/var/kolab/www/fbview
	%{l_shtool} install -d $RPM_BUILD_ROOT%{l_prefix}/var/kolab/tmp
	%{l_shtool} install -d $RPM_BUILD_ROOT%{l_prefix}/var/kolab/storage
	%{l_shtool} install -d $RPM_BUILD_ROOT%{l_prefix}/etc/kolab/templates	

	cd %{V_horde_name}-%{V_source_version}

	find . -name 'test.php' | xargs rm

	find . -type f | grep '\.orig$' | xargs rm

	rm -rf dimp imp ingo mimp mnemo nag

	cd kronolith

	# Remove some stuff not necessary for fbview
	rm add.php day.php view.php                            \
           delete.php ics.php search.php week.php contacts.php \
           imple.php  month.php  pref_api.php workweek.php     \
           edit.php new.php year.php attend.php                \
           data.php event.php

	cd ..

	cp -r * $RPM_BUILD_ROOT%{l_prefix}/var/kolab/www/fbview/

	# The following section removes libraries again so that we
	# only need to patch/install them once in the system.
	#
	# kolab/issue3293 (Big code duplication and code version messup: Horde
        #                  libs in 2.2.1)

	# Use Archive_Tar-1.3.2 from /kolab/lib/php
	rm -rf $RPM_BUILD_ROOT%{l_prefix}/var/kolab/www/client/pear/Archive/Tar.php

	# Use Structures_Graph-1.0.2 from /kolab/lib/php
	rm -rf $RPM_BUILD_ROOT%{l_prefix}/var/kolab/www/client/pear/Structures

	# Use Console_Getopt-1.2.3 from /kolab/lib/php
	rm -rf $RPM_BUILD_ROOT%{l_prefix}/var/kolab/www/client/pear/Console/Getopt.php

	# Use XML_Util-1.2.1 from /kolab/lib/php
	rm -rf $RPM_BUILD_ROOT%{l_prefix}/var/kolab/www/client/pear/XML/Util.php

	# Use PEAR-1.7.2 from /kolab/lib/php
	rm -rf $RPM_BUILD_ROOT%{l_prefix}/var/kolab/www/client/pear/OS/Guess.php
	rm -rf $RPM_BUILD_ROOT%{l_prefix}/var/kolab/www/client/pear/PEAR

	# Use Horde_Util-0.1.0dev20090501 from /kolab/lib/php
	rm -rf $RPM_BUILD_ROOT%{l_prefix}/var/kolab/www/client/lib/Horde/Array.php
	rm -rf $RPM_BUILD_ROOT%{l_prefix}/var/kolab/www/client/lib/Horde/String.php
	rm -rf $RPM_BUILD_ROOT%{l_prefix}/var/kolab/www/client/lib/Horde/Util.php
	rm -rf $RPM_BUILD_ROOT%{l_prefix}/var/kolab/www/client/lib/Horde/Variables.php

	# Use Horde_NLS-0.0.2dev20090501 from /kolab/lib/php
	rm -rf $RPM_BUILD_ROOT%{l_prefix}/var/kolab/www/client/lib/Horde/NLS*

	# Kolab_Format is in sync
	rm -rf $RPM_BUILD_ROOT%{l_prefix}/var/kolab/www/client/lib/Horde/Kolab/Format*

	# Kolab_Server is in sync
	rm -rf $RPM_BUILD_ROOT%{l_prefix}/var/kolab/www/client/lib/Horde/Kolab/IMAP*
	rm -rf $RPM_BUILD_ROOT%{l_prefix}/var/kolab/www/client/lib/Horde/Kolab/Server*
	rm -rf $RPM_BUILD_ROOT%{l_prefix}/var/kolab/www/client/lib/Horde/Kolab/Session.php
	rm -rf $RPM_BUILD_ROOT%{l_prefix}/var/kolab/www/client/lib/Horde/Kolab/Test/Server.php

	# Kolab_Storage is in sync
	rm -rf $RPM_BUILD_ROOT%{l_prefix}/var/kolab/www/client/lib/Horde/Kolab/Deprecated.php
	rm -rf $RPM_BUILD_ROOT%{l_prefix}/var/kolab/www/client/lib/Horde/Kolab/Storage*
	rm -rf $RPM_BUILD_ROOT%{l_prefix}/var/kolab/www/client/lib/Horde/Kolab/Test/Storage.php


        sqlite $RPM_BUILD_ROOT%{l_prefix}/var/kolab/www/fbview/storage/horde.db < scripts/sql/groupware.sql

	cd ..

	%{l_shtool} install -c -m 644 %{l_value -s -a} %{S:1} %{S:2} \
	  $RPM_BUILD_ROOT%{l_prefix}/etc/kolab/templates	

	%{l_rpmtool} files -v -ofiles -r$RPM_BUILD_ROOT %{l_files_std} \
	    '%config(noreplace) %{l_prefix}/etc/kolab/templates/fbview-kolab-conf.template' \
	    '%config(noreplace) %{l_prefix}/etc/kolab/templates/fbview-kronolith-kolab-conf.template' \
	    '%config(noreplace) %{l_prefix}/var/kolab/www/fbview/config/*.php' \
	    '%config(noreplace) %{l_prefix}/var/kolab/www/fbview/kronolith/config/*.php' \
	    '%config(noreplace) %{l_prefix}/var/kolab/www/fbview/turba/config/*.php' \
            %dir '%defattr(-,%{l_nusr},%{l_ngrp})' %{l_prefix}/var/kolab/www/fbview/log \
            %dir '%defattr(-,%{l_nusr},%{l_ngrp})' %{l_prefix}/var/kolab/www/fbview/tmp \
            %dir '%defattr(-,%{l_nusr},%{l_ngrp})' %{l_prefix}/var/kolab/www/fbview/storage \
            %dir '%defattr(-,%{l_nusr},%{l_ngrp})' %{l_prefix}/var/kolab/www/fbview/storage/horde.db \
	    '%defattr(-,%{l_nusr},%{l_ngrp})' %{l_prefix}/var/kolab/www/fbview/config/conf.php \
	    '%defattr(-,%{l_nusr},%{l_ngrp})' %{l_prefix}/var/kolab/www/fbview/**/config/conf.php

%clean
	rm -rf $RPM_BUILD_ROOT

%files -f files
