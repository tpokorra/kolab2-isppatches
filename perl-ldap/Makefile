include ../make-helper/kolab.mk

PACKAGE = perl-ldap
PKGVER = $(shell grep "%define[ ]*V_perl_" *.spec | sed -e "s/.*V_perl_[a-z]*\s*\([0-9.]*\).*/\1/")
VERSION = $(shell grep "%define[ ]*V_perl " *.spec | sed -e "s/.*V_perl \s*\([0-9.]*\).*/\1/")
RELEASE = $(shell grep "^Release:" *.spec | sed -e "s/^Release:\s*\([0-9a-z_]*\).*/\1/")

SOURCE_URL=http://files.kolab.org/incoming/wrobel
SOURCE_0=$(PACKAGE)-$(PKGVER).tar.gz
EXTRA=

BUILD_OPTIONS=

include ../make-helper/package.mk
include ../make-helper/package-new.mk
include ../make-helper/fetch.mk
