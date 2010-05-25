STAGING = ../../stage

include ../../make-helper/kolab.mk

# Set the default upstream directory.
UPSTREAM_DIR ?= ../../upstream

# Location of the PEAR script
PEAR=$(KOLABDIR)/bin/pear

# Determine the pear package name from the package.info file
PEAR_PKGDIR = $(shell grep "^pear_pkgdir=" package.info | sed -e "s/pear_pkgdir='\([A-Za-z0-9\-\_\/]*\)'\s*/\1/")

# Determine the pear package name from the package.info file
PEAR_PACKAGE = $(shell grep "^pear_package=" package.info | sed -e "s/pear_package='\([A-Za-z0-9\_-]*\)'.*/\1/")

# Determine the package info url from the package.info file
PACKAGE_URL = $(shell grep "^package_url=" package.info | sed -e "s/package_url='\([A-Z]*\).*/\1/")

# Determine the package origin from the package.info file
PACKAGE_ORIGIN = $(shell grep "^package_origin=" package.info | sed -e "s/package_origin='\([A-Z]*\).*/\1/")

# Determine the package version control type from the package.info file
PACKAGE_VC = $(shell grep "^package_origin=" package.info | sed -e "s/package_origin='[A-Z]*-\([A-Z]*\)'.*/\1/")

# Determine the package name from the package.info file
PACKAGE = $(shell grep "^package=" package.info | sed -e "s/package='\([A-Za-z0-9\_-]*\)'.*/\1/")

# Determine the package version from the package.info file
VERSION = $(shell grep "^version=" package.info | sed -e "s/version='\([0-9.a-zA-Z]*\)'.*/\1/")

# Determine the file end of the source package
FILEEND = $(shell grep "^pkg_fileend=" package.info | sed -e "s/pkg_fileend='*\([0-9.a-z]*\)'.*/\1/")

# Determine the release number from the package.info file
RELEASE = $(shell grep "^release=" package.info | sed -e "s/release='\([0-9]*\)'.*/\1/")

# Determine the repository
REPO = $(shell grep "^repo=" package.info | sed -e "s/repo='\([A-Za-z0-9_\-]*\)'.*/\1/")

# Determine the exact commit that should be retrieved from the repository
COMMIT = $(shell grep "^repo_commit=" package.info | sed -e "s/repo_commit='\([A-Za-z0-9_:]*\)'.*/\1/")
SAFE_COMMIT = $(shell grep "^repo_commit=" package.info | sed -e "s/repo_commit=':*\([A-Za-z0-9_]*\)'.*/\1/")

# Determine the release tag a package derived from a repository checkout should get
RELTAG = $(shell grep "^repo_release=" package.info | sed -e "s/repo_release='\([0-9]*\)'.*/\1/")

# Determine the download url for the PEAR package from the package.info file
SOURCE_URL=$(shell grep "^sourceurl=" package.info | sed -e "s/sourceurl='\(.*\)'$$/\1/")

# Additional variables for tweaking the PEAR package.xml
ALTERNATE_CHANNEL= $(shell grep "^alternate_channel=" package.info | sed -e "s/alternate_channel='\(.*\)'$$/\1/")
ALTERNATE_MAINTAINER= $(shell grep "^alternate_maintainer=" package.info | sed -e "s/alternate_maintainer='\(.*\)'$$/\1/")
ALTERNATE_MAINTAINER_SNIPPET= $(shell grep "^alternate_maintainer_snippet=" package.info | sed -e "s/alternate_maintainer_snippet='\(.*\)'$$/\1/")

# Allow to set the with_chroot option
WITH_CHROOT = $(shell if [ -e ../.opt.chroot ]; then echo "yes"; else echo "no"; fi)

# Upload location for the fileserver. Configure the kolab filesserver
# in your ssh config at ~/.ssh/config. E.g.:
#
# Host=kolabfiles
# User=wrobel
# Hostname=files.kolab.org
#
FILESERVER = kolabfiles

# Set the default package file end
ifeq ($(FILEEND),)
FILEEND=tgz
endif

# Generate the full package name
SOURCE_0=$(PEAR_PACKAGE)-$(VERSION).$(FILEEND)

# Get the list of patches if there are any in the patch directory
PATCHES = $(shell ls patches/$(PACKAGE)-$(VERSION)/*.patch 2> /dev/null) \
          $(shell ls patches/$(PACKAGE)-$(VERSION)/*.diff  2> /dev/null)

# Get the list of php (config) files if there are any in this directory
PHP_FILES = $(shell ls *.php 2> /dev/null)

# Get the list of template files if there are any in this directory
TEMPLATE_FILES = $(shell ls *.template 2> /dev/null)

# Generate a list of extra files for the package
EXTRA=ChangeLog package.patch $(PHP_FILES) $(TEMPLATE_FILES)

# Temporary repository checkout location
ifeq ($(PACKAGE_VC),CVS)
UPSTREAM=$(UPSTREAM_DIR)/cvs
else
ifeq ($(PACKAGE_VC),GIT)
UPSTREAM=$(UPSTREAM_DIR)/git
endif
endif

# The current date
DATE=$(shell date +%Y-%m-%d)

# CVS information
ifeq ($(REPO),)
CVS_REPO=framework
else
CVS_REPO=$(REPO)
endif
CVS_REPO_URL=:pserver:cvsread@anoncvs.horde.org:/repository
CVS_REPO_UP_CMD=cvs update
CVS_REPO_CO_CMD=cvs -d $(CVS_REPO_URL) co
CVS_REPO_SC_CMD=cvs update -r

# GIT information
ifeq ($(REPO),)
GIT_REPO=horde
else
GIT_REPO=$(REPO)
endif
GIT_REPO_URL=git://dev.horde.org/horde/git/$(GIT_REPO)
GIT_REPO_UP_CMD=git pull origin master
GIT_REPO_CO_CMD=git clone
GIT_REPO_SC_CMD=git checkout

ifneq ($(SPEC_PRESENT),)
CLEAN_EXTRA = tmp
else
CLEAN_EXTRA = tmp $(PACKAGE).spec
endif

include ../../make-helper/package.mk
include ../../make-helper/fetch.mk

# Target location for the repository checkout
$(UPSTREAM)/$(SAFE_COMMIT):
	mkdir -p "$(UPSTREAM)/$(SAFE_COMMIT)"

# Target for building the binary package
$(KOLABRPMPKG)/$(PACKAGE)-$(VERSION)-$(RELEASE).$(PLATTAG).rpm: $(KOLABRPMSRC)/$(PACKAGE)/$(PACKAGE).spec
	cd $(KOLABRPMSRC)/$(PACKAGE) && $(RPM) -ba $(PACKAGE).spec

# Target for building the source package
$(KOLABRPMPKG)/$(PACKAGE)-$(VERSION)-$(RELEASE).src.rpm: $(KOLABRPMSRC)/$(PACKAGE)/$(PACKAGE).spec
	cd $(KOLABRPMSRC)/$(PACKAGE) && $(RPM) -bs $(PACKAGE).spec

# Target for preparing the source area and building the package
$(KOLABRPMSRC)/$(PACKAGE)/$(PACKAGE).spec: Makefile $(PACKAGE).spec $(EXTRA) $(KOLABRPMSRC)/$(PACKAGE)/$(SOURCE_0)
	cp $(PACKAGE).spec $(EXTRA) $(KOLABRPMSRC)/$(PACKAGE)

# Target for the src rpm directory.
$(KOLABRPMSRC)/$(PACKAGE):
	test -d $(KOLABRPMSRC)/$(PACKAGE) || mkdir $(KOLABRPMSRC)/$(PACKAGE)

# Get the repository checkout
ifeq ($(PACKAGE_VC),CVS)
$(UPSTREAM)/$(SAFE_COMMIT)/$(CVS_REPO)/$(PEAR_PKGDIR): $(UPSTREAM)/$(SAFE_COMMIT)
	@echo The password is 'horde'
	@cvs -d $(CVS_REPO_URL) login
	cd "$(UPSTREAM)/$(SAFE_COMMIT)" && $(CVS_REPO_CO_CMD) $(CVS_REPO)
	cd "$(UPSTREAM)/$(SAFE_COMMIT)/$(CVS_REPO)" && $(CVS_REPO_SC_CMD) "$(COMMIT)"
else
ifeq ($(PACKAGE_VC),GIT)
$(UPSTREAM)/$(GIT_REPO):
	cd "$(UPSTREAM)" && $(GIT_REPO_CO_CMD) $(GIT_REPO_URL)

$(UPSTREAM)/.$(GIT_REPO)-commit_$(COMMIT): $(UPSTREAM)/$(GIT_REPO)
	-cd "$(UPSTREAM)/$(GIT_REPO)" && $(GIT_REPO_UP_CMD)
	cd "$(UPSTREAM)/$(GIT_REPO)" && $(GIT_REPO_SC_CMD) "$(COMMIT)"
	rm -f $(UPSTREAM)/.$(GIT_REPO)-commit_*
	touch $@
endif
endif

# Generate the source package from the repository checkout
ifeq ($(PACKAGE_VC),CVS)
tmp/$(PACKAGE): $(UPSTREAM)/$(SAFE_COMMIT)/$(CVS_REPO)/$(PEAR_PKGDIR)
	rm -rf tmp
	mkdir tmp
	cp -r "$(UPSTREAM)/$(SAFE_COMMIT)/$(CVS_REPO)/$(PEAR_PKGDIR)" tmp/$(PACKAGE)
else
ifeq ($(PACKAGE_VC),GIT)
tmp/$(PACKAGE): $(UPSTREAM)/.$(GIT_REPO)-commit_$(COMMIT)
	rm -rf tmp
	mkdir tmp
	cp -r "$(UPSTREAM)/$(GIT_REPO)/$(PEAR_PKGDIR)" tmp/$(PACKAGE)
endif
endif

ifneq ($(PACKAGE_VC),)
# Package the source
tmp/$(SOURCE_0): tmp/$(PACKAGE)
	sed -i -e "/version/,+1 s#<release>\(.*\)</release>#<release>\1dev$(RELTAG)</release>#" tmp/$(PACKAGE)/package.xml
	sed -i -e "/lead/,+1 s#<date>.*</date>#<date>$(DATE)</date>#" tmp/$(PACKAGE)/package.xml
ifneq ($(ALTERNATE_CHANNEL),)
	sed -i -e 's#<channel>.*</channel>#<channel>$(ALTERNATE_CHANNEL)</channel>#' tmp/$(PACKAGE)/package.xml
endif
ifneq ($(ALTERNATE_MAINTAINER),)
	if [ -z "`grep $(ALTERNATE_MAINTAINER) tmp/$(PACKAGE)/package.xml`" ]; then \
	  sed -i -e '/lead/,/\/lead/ D'  tmp/$(PACKAGE)/package.xml; \
	  sed -i -e '/date.*\/date/ i\ $(ALTERNATE_MAINTAINER_SNIPPET)'  tmp/$(PACKAGE)/package.xml; \
	fi
endif
	cd tmp && $(PEAR) package $(PACKAGE)/package.xml

# Indicator to avoid uploading the same package twice.
tmp/.sent: tmp/$(SOURCE_0)
	echo "put tmp/$(SOURCE_0)" | sftp $(FILESERVER)
	touch tmp/.sent

# Short name for uploading the snapshot.
.PHONY:snapshot
snapshot: tmp/.sent
endif

# Short name for uploading the snapshot.
.PHONY:snapshot-local
snapshot-local: tmp/$(SOURCE_0)
	cp tmp/$(SOURCE_0) $(SOURCE_0)

# Prepare the patch for the package.
package.patch: $(PATCHES)
	echo > package.patch
	for PATCH in $(PATCHES);        \
	do                              \
	  cat $$PATCH >> package.patch; \
	done

# TODO: Fix SPEC_PRESENT so that we may include a custom install
# section for PEAR packages that are more than just a library.
ifneq ($(SPEC_PRESENT),)
else
$(PACKAGE).spec: ../../pear/pear.spec.template package.info
	. ./package.info &&                                    \
	  cat ../../pear/pear.spec.template |                  \
	  sed -e "s#[@]pear_pkgdir[@]#$${pear_pkgdir}#g"       \
	      -e "s#[@]pear_package[@]#$${pear_package}#g"     \
	      -e "s#[@]package[@]#$${package}#g"               \
	      -e "s#[@]package_url[@]#$${package_url}#g"       \
	      -e "s#[@]package_origin[@]#$${package_origin}#g" \
	      -e "s#[@]repo_commit[@]#$${repo_commit}#g"       \
	      -e "s#[@]repo_release[@]#$${repo_release}#g"     \
	      -e "s#[@]version[@]#$${version}#g"               \
	      -e "s#[@]release[@]#$${release}#g"               \
	      -e "s#[@]sourceurl[@]#$${sourceurl}#g"           \
	      -e "s#[@]php_lib_loc[@]#$${php_lib_loc}#g"       \
	      -e "s#[@]www_loc[@]#$${www_loc}#g"               \
	      -e "s#[@]summary[@]#$${summary}#g"               \
	      -e "s#[@]license[@]#$${license}#g"               \
	      -e "s#[@]buildprereq[@]#$${buildprereq}#g"       \
	      -e "s#[@]prereq[@]#$${prereq}#g"                 \
	      -e "s#[@]description[@]#$${description}#g"       \
	      -e "s#[@]with_chroot[@]#$(WITH_CHROOT)#g" >      \
	  $(PACKAGE).spec
endif
