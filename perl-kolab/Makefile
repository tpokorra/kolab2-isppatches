include ../make-helper/kolab.mk

PACKAGE = $(shell grep "%define[ ]*V_package" *.spec | sed -e "s/.*V_package\s*\([a-z-]*\).*/\1/")
VERSION = $(shell grep "%define[ ]*V_version" *.spec | sed -e "s/.*V_version\s*\([a-z0-9.+]*\).*/\1/")
RELEASE = $(shell grep "%define[ ]*V_release" *.spec | sed -e "s/.*V_release\s*\([0-9]*\).*/\1/")

#SOURCE_URL=http://www.smarty.net/distributions/
SOURCE_URL=http://files.kolab.org/incoming/wrobel
SOURCE_0=perl-kolab-$(VERSION).tar.gz

BUILD_OPTIONS=

include ../make-helper/package.mk
include ../make-helper/package-new.mk
include ../make-helper/fetch.mk
