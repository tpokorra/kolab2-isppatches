STAGING = ../../stage

include ../../make-helper/kolab.mk

GIT_PACKAGE = $(shell grep "%define[ ]*V_gitpath" *.spec | sed -e "s/.*V_gitpath\s*\([0-9a-z-]*\).*/\1/")
SAFE_COMMIT = $(shell grep "%define[ ]*V_commit" *.spec | sed -e "s/.*V_commit\s*\([0-9a-z-]*\).*/\1/")
SOURCE_NAME = $(shell grep "%define[ ]*V_source_name" *.spec | sed -e "s/.*V_source_name\s*\([0-9a-z-]*\).*/\1/")
SOURCE_PACKAGE = $(SOURCE_NAME)-$(SAFE_COMMIT)

SOURCE_URL = http://files.kolab.org/incoming/wrobel/
SOURCE_0 = $(SOURCE_NAME)-$(VERSION)-$(SAFE_COMMIT).tar.bz2

include ../../make-helper/package.mk
include ../../make-helper/patch-series.mk

# Get the list of templates if there are any in the template directory
TEMPLATES = $(shell ls templates/$(PACKAGE)-$(SAFE_COMMIT)/*.template 2> /dev/null)

# Get the list of configuration files if there are any in the configuration directory
CONFIGURATION = $(shell ls configuration/$(PACKAGE)-$(SAFE_COMMIT)/*.php 2> /dev/null)

EXTRA = package.patch $(TEMPLATES) $(CONFIGURATION)

include ../../make-helper/package-new.mk
include ../../make-helper/horde-snapshot.mk
