include ../make-helper/kolab.mk

PACKAGE = $(shell grep "^Name:" *.spec | sed -e "s/^Name:\s*\([a-z-]*\).*/\1/")
VERSION = $(shell grep "^Version:" *.spec | sed -e "s/^Version:\s*\([0-9.]*\).*/\1/")
RELEASE = $(shell grep "^Release:" *.spec | sed -e "s/^Release:\s*\([0-9]*\).*/\1/")

SOURCE_URL=http://files.kolab.org/server/development-2.2/externals
SOURCE_0=$(PACKAGE)-$(VERSION).tar.gz
EXTRA=clamav.patch rc.clamav

include ../make-helper/package.mk
include ../make-helper/package-new.mk
include ../make-helper/fetch.mk
