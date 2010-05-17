include ../make-helper/kolab.mk

PACKAGE = $(shell grep "^Name:" *.spec | sed -e "s/^Name:\s*\([a-z-]*\).*/\1/")
VERSION = $(shell grep "%define[ ]*V_version" *.spec | sed -e "s/.*V_version\s*\([0-9.]*\).*/\1/")
RELEASE = $(shell grep "%define[ ]*V_release" *.spec | sed -e "s/.*V_release\s*\([0-9]*\).*/\1/")

#SOURCE_URL=http://www.smarty.net/distributions/
SOURCE_URL=http://files.kolab.org/server/development-2.2/externals
SOURCE_0=Smarty-$(VERSION).tar.gz

BUILD_OPTIONS=

include ../make-helper/package.mk
include ../make-helper/package-new.mk
include ../make-helper/fetch.mk
