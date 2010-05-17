include ../make-helper/kolab.mk

PACKAGE=kolabd
VERSION = $(shell grep "m4_define._VERSION" $(CURDIR)/$(PACKAGE)/configure.ac|sed "s/m4_define(_VERSION,\(.*\))/\1/")
RELEASE = $(shell date "+%Y%m%d")
KOLAB_VERSION = $(shell { grep '^KOLAB_VERSION=".*"' ../install-kolab.sh || echo CVS; } | sed 's/.*"\(.*\)".*/\1/')

MAKETAR = dist

all: $(PACKAGE)-$(VERSION)-$(RELEASE).src.rpm

$(KOLABRPMPKG)/$(PACKAGE)-$(VERSION)-$(RELEASE).$(PLATTAG).rpm $(PACKAGE)-$(VERSION)-$(RELEASE).src.rpm:
	test -d $(KOLABRPMSRC)/$(PACKAGE) || mkdir $(KOLABRPMSRC)/$(PACKAGE)
	cd $(PACKAGE) && ./bootstrap && ./configure --prefix=/kolab --enable-dist=kolab \
		&& make clean distcheck && mv $(PACKAGE)-$(VERSION).tar.bz2 $(KOLABRPMSRC)/$(PACKAGE)
	cp $(PACKAGE)/$(PACKAGE).spec $(KOLABRPMSRC)/$(PACKAGE)/
	cd $(KOLABRPMSRC)/$(PACKAGE) && $(RPM) -ba $(PACKAGE).spec --define 'kolab_version $(KOLAB_VERSION)'
	cp -p $(KOLABRPMPKG)/$(PACKAGE)-$(VERSION)-$(RELEASE).src.rpm .

binary:
	$(RPM) -bB $(PACKAGE).spec

dist: all
	cp $(KOLABRPMPKG)/$(PACKAGE)-$(VERSION)-$(RELEASE).src.rpm ../stage/source
	cp $(KOLABRPMPKG)/$(PACKAGE)-$(VERSION)-$(RELEASE).$(PLATTAG).rpm ../stage/$(PLATTAG)

tar:
	test -d $(MAKETAR)/$(PACKAGE) || mkdir -p $(MAKETAR)/$(PACKAGE)
	tar -cvj --exclude=CVS --exclude=\*~ --exclude=dist -f $(MAKETAR)/$(PACKAGE)/$(PACKAGE)-$(VERSION)-$(RELEASE).tar.bz2 *

.PHONY: clean_all
clean_all:

.PHONY: install
install: $(KOLABRPMPKG)/$(PACKAGE)-$(VERSION)-$(RELEASE).$(PLATTAG).rpm
	$(RPM) -Uhv --force $(KOLABRPMPKG)/$(PACKAGE)-$(VERSION)-$(RELEASE).$(PLATTAG).rpm
