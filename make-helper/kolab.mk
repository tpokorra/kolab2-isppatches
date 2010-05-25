KOLAB_VERSION = 2.2.3

# Check if we are in a test environment
TEST_ENVIRONMENT=$(test -e test_environment && echo YES)
ifeq "x$(TEST_ENVIRONMENT)" "xYES"
    BINARY_PKGS_DIR=$(. test_environment && echo $$BINARY_PKGS_DIR)
    SOURCE_PKGS_DIR=$(.  test_environment && echo $$SOURCE_PKGS_DIR)
    KOLABDIR=$(. test_environment && echo $$KOLABDIR)
    KOLABUID=$(. test_environment && echo $$KOLABUID)
    OPENPKG=$(KOLABDIR)/bin/openpkg
else
    BINARY_PKGS_DIR=/root/kolab-server-$(KOLAB_VERSION)/ix86-debian5.0 
    SOURCE_PKGS_DIR=/root/kolab-server-$(KOLAB_VERSION)/sources
    KOLABUID=19414
endif

# Initial sanity check for the OpenPKG tool
OPENPKG ?= $(shell which openpkg && echo YES)
ifeq "x$(OPENPKG)" "x"
  $(error Did not find the "openpkg" tool. Make sure your environment settings are sane. On a standard kolab system you might need to run "eval `/kolab/etc/rc --eval all env`")
endif

# Set KOLABDIR to the base directory of the OpenPKG/Kolab installation if it is unset
KOLABDIR ?= $(shell openpkg rpm -q --qf '%{INSTALLPREFIX}\n' openpkg)

# Error out if there is no kolab directory
ifeq ($(KOLABDIR),)
  $(error Could not determine KOLABDIR!)
endif

# The core Kolab server user
KOLABUSR=$(KOLABDIR:/%=%)

# Set the location of the rpm binary if it is unset
RPM ?= $(KOLABDIR)/bin/openpkg rpm

# Set the location for rpm source package installations if it is unset
KOLABRPMSRC ?= $(KOLABDIR)/RPM/SRC

# Set the location for rpm packages if it is unset
KOLABRPMPKG ?= $(KOLABDIR)/RPM/PKG

# Set the location for the rpm temporary directory if it is unset
KOLABRPMTMP ?= $(KOLABDIR)/RPM/TMP

# Set the current working directory if it is unset
CURSRCDIR ?= $(CURDIR)

# Set the download location for Kolab source RPMs if it is unset
KOLABPKGURI ?= http://files.kolab.org/server/release/kolab-server-2.2.0/sources/

# Set the download location for OpenPKG source RPMs if it is unset
OPENPKGURI ?= http://files.kolab.org/server/development-2.2/openpkg-orig-srpms/

# Determine the suffix for binary packages on this system if it is unset
PLATFORM ?= $(shell $(RPM) -q --qf="%{ARCH}-%{OS}" openpkg)

# Determine the suffix for binary packages on this system if it is unset
PLATTAG ?= $(PLATFORM)-$(KOLABDIR:/%=%)

# Determine the staging area for collecting new source rpms if it is unset
STAGING ?= ../stage
