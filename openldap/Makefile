include ../make-helper/kolab.mk

PACKAGE = $(shell grep "^Name:" *.spec | sed -e "s/^Name:\s*\([a-z-]*\).*/\1/")
VERSION = $(shell grep "^Version:" *.spec | sed -e "s/^Version:\s*\([0-9.]*\).*/\1/")
RELEASE = $(shell grep "^Release:" *.spec | sed -e "s/^Release:\s*\([0-9]*\).*/\1/")

SOURCE_URL=ftp://ftp.openldap.org/pub/openldap/openldap-release
SOURCE_0=$(PACKAGE)-$(VERSION).tgz
EXTRA=fsl.openldap openldap.patch openldap.pc rc.openldap

BUILD_OPTIONS=--define 'with_pth no'

include ../make-helper/package.mk
include ../make-helper/package-new.mk
include ../make-helper/fetch.mk
