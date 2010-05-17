include ../make-helper/kolab.mk

PACKAGE = $(shell grep "^Name:" *.spec | sed -e "s/^Name:\s*\([a-z-]*\).*/\1/")
VERSION = $(shell grep "^%define.*V_openssl" *.spec | sed -e "s/^%define.*V_openssl\s*\([0-9.]*\).*/\1/")
ZLIB_VERSION = $(shell grep "^%define.*V_zlib" *.spec | sed -e "s/^%define.*V_zlib\s*\([0-9.]*\).*/\1/")
RELEASE = $(shell grep "^Release:" *.spec | sed -e "s/^Release:\s*\([0-9]*\).*/\1/")
KOLABRELEASE = $(RELEASE)

SOURCE_URL = ftp://ftp.openssl.org/source/
SOURCE_1_URL = http://www.zlib.net/
SOURCE_0=$(PACKAGE)-$(VERSION).tar.gz
SOURCE_1=zlib-$(ZLIB_VERSION).tar.gz

SOURCES=$(SOURCE_0) $(SOURCE_1)
RPM_SOURCES = $(KOLABRPMSRC)/$(PACKAGE)/$(SOURCE_0) $(KOLABRPMSRC)/$(PACKAGE)/$(SOURCE_1)

EXTRA=$(PACKAGE).patch

BUILD_OPTIONS =

# Target for retrieving the second source package
$(SOURCE_1):
	wget -c "$(SOURCE_1_URL)/$(SOURCE_1)"

# Target for the source file in the src rpm directory.
$(KOLABRPMSRC)/$(PACKAGE)/$(SOURCE_1): $(KOLABRPMSRC)/$(PACKAGE) $(SOURCE_1)
	cp $(SOURCE_1) $(KOLABRPMSRC)/$(PACKAGE)/

include ../make-helper/package.mk
include ../make-helper/package-new.mk
include ../make-helper/fetch.mk
