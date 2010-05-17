# Define the patch directory
PATCHES = patches/$(PACKAGE)-$(VERSION)

# Get the list of patches if there are any in the patch directory
PATCH_FILES = $(shell ls $(PATCHES)/series  2> /dev/null) \
              $(shell ls $(PATCHES)/*.patch 2> /dev/null) \
              $(shell ls $(PATCHES)/*.diff  2> /dev/null)


# Prepare the patch for the package.
package.patch: $(PATCH_FILES)
	rm -f $@
	touch $@
	if [ -e "$(PATCHES)/series" ]; then    \
	  for PATCH in `cat $(PATCHES)/series`;\
	  do                                   \
	    cat $(PATCHES)/$$PATCH >> $@;      \
	  done;                                \
	fi
