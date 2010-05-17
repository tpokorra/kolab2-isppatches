include ../make-helper/kolab.mk

PACKAGE = sqlite
VERSION = $(shell grep "define *V_v3" sqlite.spec | sed -e "s/.*V_v3\s*\([0-9.]*\).*/\1/")
VERSION2 = $(shell grep "define *V_v2" sqlite.spec | sed -e "s/.*V_v2\s*\([0-9.]*\).*/\1/")
RELEASE = $(shell grep "^Release:" sqlite.spec | sed -e "s/^Release:\s*\([0-9]*\).*/\1/")
KOLABRELEASE = $(RELEASE)

SOURCE_URL = http://www.sqlite.org
SOURCE_0 = sqlite-$(VERSION2).tar.gz
SOURCE_1 = sqlite-$(VERSION).tar.gz

SOURCES=$(SOURCE_0) $(SOURCE_1)
RPM_SOURCES = $(KOLABRPMSRC)/$(PACKAGE)/$(SOURCE_0) $(KOLABRPMSRC)/$(PACKAGE)/$(SOURCE_1)

EXTRA = sqlite.patch.v2 sqlite.patch.v3

BUILD_OPTIONS =

# Target for retrieving the second source package
$(SOURCE_1):
	wget -c "$(SOURCE_URL)/$(SOURCE_1)"

# Target for the source file in the src rpm directory.
$(KOLABRPMSRC)/$(PACKAGE)/$(SOURCE_1): $(KOLABRPMSRC)/$(PACKAGE) $(SOURCE_1)
	cp $(SOURCE_1) $(KOLABRPMSRC)/$(PACKAGE)/


include ../make-helper/package.mk
include ../make-helper/package-new.mk
include ../make-helper/fetch.mk
