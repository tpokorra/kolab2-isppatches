PACKAGE ?= $(shell grep "%define[ ]*V_package" *.spec | sed -e "s/.*V_package\s*\([0-9a-z-]*\).*/\1/")
VERSION ?= $(shell grep "%define[ ]*V_version" *.spec | sed -e "s/.*V_version\s*\([0-9._a-z]*\).*/\1/")
RELEASE ?= $(shell grep "%define[ ]*V_release" *.spec | sed -e "s/.*V_release\s*\([0-9._a-z]*\).*/\1/")

SOURCE_URL ?= 
SOURCE_FORMAT ?= tar.gz
SOURCE_0 ?= $(PACKAGE)-$(VERSION).$(SOURCE_FORMAT)

BUILD_OPTIONS ?=

RELEASETARGET ?= $(PACKAGE)-$(VERSION)-$(RELEASE).src.rpm
BINTARGET ?= $(PACKAGE)-$(VERSION)-$(RELEASE).$(PLATTAG).rpm

CLEAN_EXTRA ?=

# Default target to generate the source rpm package
.PHONY: all
all: dist

# Target for placing the source rpm in the staging area. This target
# includes building the binary package which is an additional check for
# the final release. Thus it is the default target.
.PHONY: dist
dist: $(KOLABRPMPKG)/$(BINTARGET) $(STAGING)/source/$(RELEASETARGET) $(STAGING)/$(PLATTAG)/$(BINTARGET)

# Target for placing the source rpm in the staging area. This is the soft
# variant that is quicker and omits the binary package.
.PHONY: sdist
sdist: $(RELEASETARGET)

# Target for installing the binary rpm package in our current Kolab
# server installation
.PHONY: install
install: $(KOLABRPMPKG)/$(BINTARGET)
	$(RPM) -Uhv --force $(KOLABRPMPKG)/$(BINTARGET)

# Target for cleaning up the files that can be generated with this Makefile
.PHONY: clean
clean:
	rm -rf $(KOLABRPMSRC)/$(PACKAGE)
	rm -rf $(KOLABRPMTMP)/$(PACKAGE)*
	rm -f $(KOLABRPMPKG)/$(RELEASETARGET)
	rm -f $(KOLABRPMPKG)/$(BINTARGET)
	rm -f $(RELEASETARGET)
	rm -f *.tar.gz *.tgz *.tar.bz2
	rm -f *~
	rm -f package.patch
ifeq ($(CLEAN_EXTRA),)
else
	rm -rf $(CLEAN_EXTRA)
endif

# Target for fetching the source rpm into the current directory
$(RELEASETARGET): $(KOLABRPMPKG)/$(RELEASETARGET)
	cp $(KOLABRPMPKG)/$(RELEASETARGET) .

ifeq ($(SOURCE_0),)
FETCH_SOURCE =
else
SOURCES ?= $(SOURCE_0)

# Target for the source file in the src rpm directory.
$(KOLABRPMSRC)/$(PACKAGE)/$(SOURCE_0): $(KOLABRPMSRC)/$(PACKAGE) $(SOURCE_0)
	cp $(SOURCE_0) $(KOLABRPMSRC)/$(PACKAGE)/

FETCH_SOURCE = fetch-source

# Shortcut for fetching the source archive
.PHONY: fetch-source
fetch-source: $(SOURCES)

# Target for retrieving the source package
$(SOURCE_0):
	wget -c "$(SOURCE_URL)/$(SOURCE_0)"
endif

# Prepare the staging area
$(STAGING)/source/.dir:
	mkdir -p $(STAGING)/source
	touch $(STAGING)/source/.dir

# Final package location
$(STAGING)/source/$(RELEASETARGET): $(STAGING)/source/.dir $(RELEASETARGET)
	cp $(RELEASETARGET) $(STAGING)/source

# Prepare the binary staging area
$(STAGING)/$(PLATTAG)/.dir:
	mkdir -p $(STAGING)/$(PLATTAG)
	touch $(STAGING)/$(PLATTAG)/.dir

# Final binary package location
$(STAGING)/$(PLATTAG)/$(BINTARGET): $(STAGING)/$(PLATTAG)/.dir $(KOLABRPMPKG)/$(BINTARGET)
	cp $(KOLABRPMPKG)/$(BINTARGET) $(STAGING)/$(PLATTAG)
