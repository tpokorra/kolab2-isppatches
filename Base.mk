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

# Is this an openpkg system?
OPENPKG=$(shell test -e $(HOME)/bin/openpkg && echo YES)

ifeq "x$(OPENPKG)" "xYES"
# Set the location of the rpm binary
ifeq "x$(RPM)" "x"
  RPM = $(HOME)/bin/openpkg rpm
endif
# Determine the suffix for binary packages on this system
ifeq "x$(PLATTAG)" "x"
  PLATTAG = $(shell $(RPM) -q --qf="%{ARCH}-%{OS}" openpkg)-$(HOME:/%=%)
endif
else
  RPM =
  PLATTAG = unknown
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

ifeq "x$(KOLABPKGURI)" "x"
  KOLABPKGURI = http://files.kolab.org/server/development-2.2/openpkg-orig-srpms/
endif
