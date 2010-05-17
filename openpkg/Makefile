OPENPKGURI=http://files.kolab.org/server/release/kolab-server-2.2.0/sources/

include ../make-helper/kolab.mk

PACKAGE=openpkg
DOWNLOAD_VERSION=20071227
OPENPKG_RELEASE=20071227
VERSION=20071227
RELEASE=$(OPENPKG_RELEASE)_kolab2

SOURCE_URL=
SOURCE_0=

RPM_SOURCES= 

PATCHES=

EXTRA=$(PATCHES) kolab.patch $(PACKAGE2)-${VERSION2}.tar.gz $(PACKAGE2).patch

KOLABPKGURI2 = http://files.kolab.org/server/development-2.2/openpkg-orig-srpms/
PACKAGE2=tar
VERSION2=1.22
RELEASE2=20090305

RELEASETARGET=$(PACKAGE)-$(VERSION)-$(RELEASE).src.sh

include ../make-helper/package.mk
include ../make-helper/openpkg-patched.mk
include ../make-helper/fetch.mk

$(KOLABRPMPKG)/$(RELEASETARGET): $(KOLABRPMSRC)/$(PACKAGE)/$(PACKAGE).spec.patched $(PACKAGE2)-$(VERSION2)-$(RELEASE2).src.rpm
	cd $(KOLABRPMSRC)/$(PACKAGE) && rm $(PACKAGE2)-1.19.tar.gz && ./openpkg.boot -s

$(PACKAGE2).patch: $(KOLABRPMSRC)/$(PACKAGE2)/.dir
	cp $(KOLABRPMSRC)/$(PACKAGE2)/$(PACKAGE2).patch .

$(PACKAGE2)-${VERSION2}.tar.gz: $(KOLABRPMSRC)/$(PACKAGE2)/.dir
	cp $(KOLABRPMSRC)/$(PACKAGE2)/$(PACKAGE2)-${VERSION2}.tar.gz .

$(KOLABRPMSRC)/$(PACKAGE2)/.dir: $(PACKAGE2)-$(VERSION2)-$(RELEASE2).src.rpm
	$(RPM) -ihv $(PACKAGE2)-$(VERSION2)-$(RELEASE2).src.rpm
	touch $(KOLABRPMSRC)/$(PACKAGE2)/.dir

$(PACKAGE2)-$(VERSION2)-$(RELEASE2).src.rpm:
	wget -c $(KOLABPKGURI2)/$(PACKAGE2)-$(VERSION2)-$(RELEASE2).src.rpm
