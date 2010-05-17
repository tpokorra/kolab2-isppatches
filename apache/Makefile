include ../make-helper/kolab.mk

PACKAGE = $(shell grep "^Name:" *.spec | sed -e "s/^Name:\s*\([a-z-]*\).*/\1/")
VERSION = $(shell grep "^Version:" *.spec | sed -e "s/^Version:\s*\([0-9.]*\).*/\1/")
RELEASE = $(shell grep "^Release:" *.spec | sed -e "s/^Release:\s*\([0-9]*\).*/\1/")

SOURCE_URL=http://www.apache.org/dist/httpd/
SOURCE_0=httpd-$(VERSION).tar.bz2
EXTRA=apache.base apache.conf apache.patch apache.sh rc.apache

BUILD_OPTIONS=--define 'with_mod_ssl yes' --define 'with_mod_ldap yes'         \
              --define 'with_mod_authn_alias yes' --define 'with_mod_ldap yes' \
              --define 'with_mod_ssl yes' --define 'with_mod_authn_alias yes'

include ../make-helper/package.mk
include ../make-helper/package-new.mk
include ../make-helper/fetch.mk
