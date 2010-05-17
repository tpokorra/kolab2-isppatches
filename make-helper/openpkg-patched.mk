# Target for preparing the source area and building the package
$(KOLABRPMSRC)/$(PACKAGE)/kolab.patch: $(EXTRA)
	cp $(EXTRA) $(KOLABRPMSRC)/$(PACKAGE)

FETCH_RPM = fetch-rpm

# Shortcut for fetching the source rpm package
.PHONY:fetch-rpm
fetch-rpm: $(PACKAGE)-$(DOWNLOAD_VERSION)-$(OPENPKG_RELEASE).src.rpm

# Target for fetching the original openpkg package
$(PACKAGE)-$(DOWNLOAD_VERSION)-$(OPENPKG_RELEASE).src.rpm:
	wget -c $(OPENPKGURI)/$(PACKAGE)-$(DOWNLOAD_VERSION)-$(OPENPKG_RELEASE).src.rpm

# Target for the src rpm directory. The actual target is a .dir file
# as the directory modification time will show the timepoint of the
# last modified file in the directory. This would lead to remaking
# some targets every time.
$(KOLABRPMSRC)/$(PACKAGE)/.dir: $(PACKAGE)-$(DOWNLOAD_VERSION)-$(OPENPKG_RELEASE).src.rpm
	$(RPM) -ihv $(PACKAGE)-$(DOWNLOAD_VERSION)-$(OPENPKG_RELEASE).src.rpm
	touch $(KOLABRPMSRC)/$(PACKAGE)/$(PACKAGE).spec
	touch $(KOLABRPMSRC)/$(PACKAGE)/.dir

# Target for the src rpm spec file.
$(KOLABRPMSRC)/$(PACKAGE)/$(PACKAGE).spec: $(KOLABRPMSRC)/$(PACKAGE)/.dir

# Target for patching the spec file
$(KOLABRPMSRC)/$(PACKAGE)/$(PACKAGE).spec.patched: $(KOLABRPMSRC)/$(PACKAGE)/$(PACKAGE).spec $(KOLABRPMSRC)/$(PACKAGE)/kolab.patch
	cd $(KOLABRPMSRC)/$(PACKAGE) && patch < kolab.patch
	touch $(KOLABRPMSRC)/$(PACKAGE)/$(PACKAGE).spec.patched

# Prepare the patch for the package.
package.patch: $(PATCHES)
	echo > package.patch
	for PATCH in $(PATCHES);        \
	do                              \
	  cat $$PATCH >> package.patch; \
	done

RPM_SOURCES ?= $(KOLABRPMSRC)/$(PACKAGE)/$(SOURCE_0)

# Target for building the source package
$(KOLABRPMPKG)/$(RELEASETARGET): $(KOLABRPMSRC)/$(PACKAGE)/$(PACKAGE).spec.patched $(RPM_SOURCES)
	cd $(KOLABRPMSRC)/$(PACKAGE) && $(RPM) -bs $(PACKAGE).spec

# Target for building the binary package
$(KOLABRPMPKG)/$(PACKAGE)-$(VERSION)-$(RELEASE).$(PLATTAG).rpm: $(KOLABRPMSRC)/$(PACKAGE)/$(PACKAGE).spec.patched $(RPM_SOURCES)
	echo S: $(SOURCES)
	cd $(KOLABRPMSRC)/$(PACKAGE) && $(RPM) -ba $(PACKAGE).spec $(BUILD_OPTIONS)
