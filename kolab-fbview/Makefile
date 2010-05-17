# If home is unset this Makefile assumes the Kolab server installation
# resides in /kolab. If this is not the case this Makefile must be
# called using
#
# HOME="/mykolabroot" make TARGET
#
ifeq "x$(HOME)" "x"
  HOME = /kolab
endif

# If HOME is set to /root it is likely that somebody is calling this
# Makefile as root user. In this case this Makefile assumes that the
# Kolab server installation resides in /kolab.
#
# In the (hopefully) unlikely event that somebody really installed the
# Kolab server in /root this Makefile will fail.
ifeq "x$(HOME)" "x/root"
  HOME = /kolab
endif

# Set the location of the rpm binary
ifeq "x$(RPM)" "x"
  RPM = $(HOME)/bin/openpkg rpm
endif

# Set the location for rpm source package installations
ifeq "x$(KOLABRPMSRC)" "x"
  KOLABRPMSRC = $(HOME)/RPM/SRC
endif

# Set the location for rpm packages
ifeq "x$(KOLABRPMPKG)" "x"
  KOLABRPMPKG = $(HOME)/RPM/PKG
endif

# Set the location for the rpm temporary directory
ifeq "x$(KOLABRPMTMP)" "x"
  KOLABRPMTMP = $(HOME)/RPM/TMP
endif

# Determine the suffix for binary packages on this system
ifeq "x$(PLATTAG)" "x"
	PLATTAG = $(shell $(RPM) -q --qf="%{ARCH}-%{OS}" openpkg)-$(HOME:/%=%)
endif

# Determine the staging area for collecting new source rpms
ifeq "x$(STAGING)" "x"
  STAGING = ../stage
endif

HORDE_NAME = $(shell grep "%define[ ]*V_horde_name" *.spec | sed -e "s/.*V_horde_name \([a-z-]*\).*/\1/")
YEAR = $(shell grep "%define[ ]*V_year" *.spec | sed -e "s/.*V_year\s*\([0-9]*\).*/\1/")
MONTH = $(shell grep "%define[ ]*V_month" *.spec | sed -e "s/.*V_month\s*\([0-9]*\).*/\1/")
DAY = $(shell grep "%define[ ]*V_day" *.spec | sed -e "s/.*V_day\s*\([0-9]*\).*/\1/")

DATE = ${YEAR}-${MONTH}-${DAY}

PACKAGE = $(shell grep "%define[ ]*V_package" *.spec | sed -e "s/.*V_package \([a-z-]*\).*/\1/")
VERSION = $(shell grep "%define[ ]*V_version" *.spec | sed -e "s/.*V_version\s*\([0-9._a-z]*\).*/\1/")
SOURCE_VERSION = $(shell grep "%define[ ]*V_source_version" *.spec | sed -e "s/.*V_source_version\s*\([0-9._a-z-]*\).*/\1/")
PASSWD_VERSION = $(shell grep "%define[ ]*V_passwd_version" *.spec | sed -e "s/.*V_passwd_version\s*\([0-9._a-z]*\).*/\1/")
RELEASE = ${YEAR}${MONTH}${DAY}

PATCHES_HORDE = ../kolab-webclient/patches/$(VERSION)/KOLAB
PATCHES_FBVIEW = ./patches/$(VERSION)/FBVIEW
TEMPLATES = $(shell find . -name "*.template")
CONFIGS = $(shell find . -name "*.php")

PACKAGE_0=$(HORDE_NAME)-$(SOURCE_VERSION).tar.gz
SOURCE_0=http://ftp.horde.org/pub/$(HORDE_NAME)/$(PACKAGE_0)

.PHONY: all
all: $(PACKAGE)-$(VERSION)-$(RELEASE).src.rpm

.PHONY: dist
dist: all
	cp $(PACKAGE)-$(VERSION)-$(RELEASE).src.rpm ../stage/

.PHONY: clean_all
clean_all:
	rm -rf /kolab/RPM/TMP/$(PACKAGE)
	rm -rf $(PACKAGE)-$(VERSION)-$(RELEASE).src.rpm
	rm -rf *~

$(KOLABRPMSRC)/$(PACKAGE)/$(PACKAGE_0):
	test -d $(KOLABRPMSRC)/$(PACKAGE) || mkdir $(KOLABRPMSRC)/$(PACKAGE)
	cd $(KOLABRPMSRC)/$(PACKAGE) && wget -c "$(SOURCE_0)"

.PHONY: $(KOLABRPMSRC)/$(PACKAGE)/series.patch
$(KOLABRPMSRC)/$(PACKAGE)/series.patch: $(KOLABRPMSRC)/$(PACKAGE)/$(PACKAGE_0)
	rm -f $(KOLABRPMSRC)/$(PACKAGE)/series.patch
	for PATCH in `cat $(PATCHES_HORDE)/series`;                          \
	do                                                                   \
	  cat $(PATCHES_HORDE)/$$PATCH >> $(KOLABRPMSRC)/$(PACKAGE)/series.patch;  \
	done
	for PATCH in `cat $(PATCHES_FBVIEW)/series`;                         \
	do                                                                   \
	  cat $(PATCHES_FBVIEW)/$$PATCH >> $(KOLABRPMSRC)/$(PACKAGE)/series.patch;  \
	done

$(KOLABRPMPKG)/$(PACKAGE)-$(VERSION)-$(RELEASE).$(PLATTAG).rpm $(PACKAGE)-$(VERSION)-$(RELEASE).src.rpm: Makefile $(PACKAGE).spec $(TEMPLATES) $(CONFIGS) ChangeLog $(KOLABRPMSRC)/$(PACKAGE)/series.patch

	cp $(PACKAGE).spec $(KOLABRPMSRC)/$(PACKAGE)

	if [ -n "$(TEMPLATES)" ]; then              \
	  for TEMPLATE in $(TEMPLATES);             \
	  do                                        \
	    cp $$TEMPLATE $(KOLABRPMSRC)/$(PACKAGE);\
	  done;                                     \
	fi

	if [ -n "$(CONFIGS)" ]; then                \
	  for CONFIG in $(CONFIGS);                 \
	  do                                        \
	    cp $$CONFIG $(KOLABRPMSRC)/$(PACKAGE);  \
	  done;                                     \
	fi

	cd $(KOLABRPMSRC)/$(PACKAGE) && $(RPM) -ba $(PACKAGE).spec

	cp -p $(KOLABRPMPKG)/$(PACKAGE)-$(VERSION)-$(RELEASE).src.rpm .

.PHONY: install
install: $(KOLABRPMPKG)/$(PACKAGE)-$(VERSION)-$(RELEASE).$(PLATTAG).rpm
	$(RPM) -Uhv --force $(KOLABRPMPKG)/$(PACKAGE)-$(VERSION)-$(RELEASE).$(PLATTAG).rpm
