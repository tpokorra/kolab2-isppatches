# Variables
%define         V_version       2.6.20
%define         V_release       20081212

# Package Information
Name:		php-smarty
Summary:	Template engine for PHP
URL:		http://www.smarty.net/
Packager:	Intevation GmbH
Version:	%{V_version}
Release:	%{V_release}
License:	LGPL
Group:		Languages
Distribution:	OpenPKG

# List of Sources
Source0:	http://www.smarty.net/distributions/Smarty-%{version}.tar.gz

# Build Info
Prefix:		%{l_prefix}
BuildRoot:	%{l_buildroot}
AutoReq:      no
AutoReqProv:  no
#BuildArch:    noarch

%description
Smarty is a template engine for PHP. Smarty provides your basic
variable substitution and dynamic block functionality, and also takes
a step further to be a "smart" template engine, adding features such
as configuration files, template functions, variable modifiers, and
making all of this functionality as easy as possible to use for both
programmers and template designers.

%prep
	%setup -q -n Smarty-%{version} 

%build

%install
	rm -rf $RPM_BUILD_ROOT
	%{l_shtool} install -d $RPM_BUILD_ROOT%{l_prefix}/lib/php/Smarty/internals
	%{l_shtool} install -d $RPM_BUILD_ROOT%{l_prefix}/lib/php/Smarty/plugins
	%{l_shtool} install -d $RPM_BUILD_ROOT%{l_prefix}/share/php-smarty/manual/stylesheet-images
	%{l_shtool} install -m 644 libs/{Config_File,Smarty{,_Compiler}}.class.php \
		$RPM_BUILD_ROOT%{l_prefix}/lib/php/Smarty
	%{l_shtool} install -m 644 libs/debug.tpl $RPM_BUILD_ROOT%{l_prefix}/lib/php/Smarty
	%{l_shtool} install -m 644 libs/internals/*.php $RPM_BUILD_ROOT%{l_prefix}/lib/php/Smarty/internals
	%{l_shtool} install -m 644 libs/plugins/*.php $RPM_BUILD_ROOT%{l_prefix}/lib/php/Smarty/plugins
	%{l_shtool} install -m 644 BUGS ChangeLog FAQ INSTALL NEWS README RELEASE_NOTES TODO \
		$RPM_BUILD_ROOT%{l_prefix}/share/php-smarty
	%{l_rpmtool} files -v -ofiles -r$RPM_BUILD_ROOT %{l_files_std} \
		%doc %{l_prefix}/share/php-smarty/BUGS %{l_prefix}/share/php-smarty/ChangeLog \
		%{l_prefix}/share/php-smarty/FAQ %{l_prefix}/share/php-smarty/INSTALL \
		%{l_prefix}/share/php-smarty/NEWS %{l_prefix}/share/php-smarty/README  \
		%{l_prefix}/share/php-smarty/RELEASE_NOTES %{l_prefix}/share/php-smarty/TODO 

%clean
	rm -rf $RPM_BUILD_ROOT

%files -f files

%post
	echo "Removing old compiled templates from %{l_prefix}/var/kolab/php/admin/templates_c"
	rm -f %{l_prefix}/var/kolab/php/admin/templates_c/*
