include ../make-helper/kolab.mk

PACKAGE=kolab-webadmin
VERSION:=`grep 'm4_define(_VERSION' $(CURDIR)/$(PACKAGE)/configure.ac|sed 's/m4_define(_VERSION,\(.*\))/\1/'`
RELEASE:=`date '+%Y%m%d'`
KOLAB_VERSION = $(shell { grep '^KOLAB_VERSION=".*"' ../install-kolab.sh || echo CVS; } | sed 's/.*"\(.*\)".*/\1/')

all:
	test -d $(KOLABRPMSRC)/$(PACKAGE) || mkdir $(KOLABRPMSRC)/$(PACKAGE)
	cd $(PACKAGE) && ./bootstrap && ./configure --prefix=/kolab \
	&& make clean distcheck && mv $(PACKAGE)-$(VERSION).tar.bz2 $(KOLABRPMSRC)/$(PACKAGE) 
	cp $(PACKAGE)/$(PACKAGE).spec $(KOLABRPMSRC)/$(PACKAGE)/
	cd $(KOLABRPMSRC)/$(PACKAGE) && $(RPM) -ba $(PACKAGE).spec --define 'kolab_version $(KOLAB_VERSION)'

binary:
	$(RPM) -bB $(PACKAGE).spec

release:
	tar cvzf $(PACKAGE)-$(VERSION).tar.gz $(PACKAGE)
	$(RPM) -ba $(PACKAGE).spec

dist: all
	cp $(KOLABRPMSRC)/../PKG/$(PACKAGE)-$(VERSION)-$(RELEASE).src.rpm ../stage/source
	cp $(KOLABRPMPKG)/$(PACKAGE)-$(VERSION)-$(RELEASE).$(PLATTAG).rpm ../stage/$(PLATTAG)

.PHONY: clean_all
clean_all: clean

.PHONY: clean
clean:
	rm -rf $(KOLABDIR)/RPM/TMP/$(PACKAGE)*
	find . -name "*~" | xargs rm -rf
	rm -rf *.src.rpm
	rm -rf *.tar.bz2
