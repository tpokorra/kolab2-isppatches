# This is a very rough draft for updating a patch series using
# mercurial queues. The Makefile could see some optimizations but for
# the occasional upstream update it hopefully does fine.
#
# Author: G. Wrobel

.PHONY: update
update:
	@if [ -d $(PN)-$(NEW_VERSION) ]; then echo "Patches for the new version do already exist!" && exit 1; fi
	mkdir -p tmp
ifeq "x$(COMPRESSION)" "xGZ"
	cd tmp && test -e $(PN)-$(OLD_VERSION).tar.gz || wget $(SOURCE_URL)/$(PN)-$(OLD_VERSION).tar.gz
	cd tmp && tar xfz $(PN)-$(OLD_VERSION).tar.gz
endif
ifeq "x$(COMPRESSION)" "xBZ2"
	cd tmp && test -e $(PN)-$(OLD_VERSION).tar.bz2 || wget $(SOURCE_URL)/$(PN)-$(OLD_VERSION).tar.bz2
	cd tmp && tar xfj $(PN)-$(OLD_VERSION).tar.bz2
endif
	cd tmp/$(PN)-$(OLD_VERSION) && hg init && hg commit --addremove -m "$(PN)-$(OLD_VERSION)"
	cd tmp && hg clone $(PN)-$(OLD_VERSION) $(PN)-PATCHED
	printf "[extensions]\nhgext.mq =\n" > tmp/$(PN)-PATCHED/.hg/hgrc
	cd tmp/$(PN)-PATCHED && hg qinit
	cp $(PN)-$(OLD_VERSION)/series tmp/$(PN)-PATCHED/.hg/patches/
	cd $(PN)-$(OLD_VERSION); \
	for FL in KOLAB*; do \
	  cp $$FL ../tmp/$(PN)-PATCHED/.hg/patches/$${FL/$(PN)-$(OLD_VERSION)_/}; \
	done
	cp $(PN)-$(OLD_VERSION)/series tmp/$(PN)-PATCHED/.hg/patches/
	cd tmp/$(PN)-PATCHED && hg qpush -a && hg qpop -a
	cd tmp && hg clone $(PN)-$(OLD_VERSION) $(PN)-$(NEW_VERSION)
	cd tmp/$(PN)-$(NEW_VERSION) && hg locate -0 | xargs -0 rm
ifeq "x$(COMPRESSION)" "xGZ"
	cd tmp && wget $(SOURCE_URL)/$(PN)-$(NEW_VERSION).tar.gz
	cd tmp && tar xfz $(PN)-$(NEW_VERSION).tar.gz
endif
ifeq "x$(COMPRESSION)" "xBZ2"
	cd tmp && wget $(SOURCE_URL)/$(PN)-$(NEW_VERSION).tar.bz2
	cd tmp && tar xfj $(PN)-$(NEW_VERSION).tar.bz2
endif
	cd tmp/$(PN)-$(NEW_VERSION) && hg commit --addremove -m "$(PN)-$(NEW_VERSION)"
	cd tmp/$(PN)-PATCHED && hg pull ../$(PN)-$(NEW_VERSION) && hg update
	@echo
	@echo
	@echo "The patch series will be pushed now. If errors occur you will need to "
	@echo "move into the directory tmp/$(PN)-PATCHED:"
	@echo
	@echo "cd tmp/$(PN)-PATCHED"
	@echo
	@echo "and fix the merge conflicts. Once you did that you will need to run"
	@echo "run \"hg qrefresh\" and continue with \"hg qpush\" until the full series applied"
	@echo "successfully. Finally you may move back to the current directory and run \"make patches\""
	@echo
	@echo
	cd tmp/$(PN)-PATCHED && hg qpush -a

.PHONY: patches
patches:
	@if [ -d $(PN)-$(NEW_VERSION) ]; then echo "Patches for the new version do already exist!" && exit 1; fi
	mkdir $(PN)-$(NEW_VERSION)
	cd tmp/$(PN)-PATCHED/.hg/patches; \
	for FL in KOLAB*; do \
	  cp $$FL ../../../../$(PN)-$(NEW_VERSION)/$${FL/KOLAB_/KOLAB_$(PN)-$(NEW_VERSION)_}; \
	done
	cp tmp/$(PN)-PATCHED/.hg/patches/series $(PN)-$(NEW_VERSION)/ 
	rm -rf tmp

.PHONY: clean
clean:
	rm -rf tmp
	rm -f *~
