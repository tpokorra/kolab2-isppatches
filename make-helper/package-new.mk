EXTRA ?=

# Target for the src rpm directory. The actual target is a .dir file
# as the directory modification time will show the timepoint of the
# last modified file in the directory. This would lead to remaking
# some targets every time.
$(KOLABRPMSRC)/$(PACKAGE)/.dir:
	mkdir -p $(KOLABRPMSRC)/$(PACKAGE)
	touch $(KOLABRPMSRC)/$(PACKAGE)/.dir

# Target for the src rpm spec file.
$(KOLABRPMSRC)/$(PACKAGE)/$(PACKAGE).spec: $(KOLABRPMSRC)/$(PACKAGE)/.dir $(PACKAGE).spec $(EXTRA)
	cp $(PACKAGE).spec $(EXTRA) $(KOLABRPMSRC)/$(PACKAGE)

RPM_SOURCES ?= $(KOLABRPMSRC)/$(PACKAGE)/$(SOURCE_0)

# Target for building the source package
$(KOLABRPMPKG)/$(RELEASETARGET): $(KOLABRPMSRC)/$(PACKAGE)/$(PACKAGE).spec $(RPM_SOURCES)
	cd $(KOLABRPMSRC)/$(PACKAGE) && $(RPM) -bs $(PACKAGE).spec

# Target for building the binary package
$(KOLABRPMPKG)/$(PACKAGE)-$(VERSION)-$(RELEASE).$(PLATTAG).rpm: $(KOLABRPMSRC)/$(PACKAGE)/$(PACKAGE).spec $(RPM_SOURCES)
	cd $(KOLABRPMSRC)/$(PACKAGE) && $(RPM) -ba $(PACKAGE).spec $(BUILD_OPTIONS)
