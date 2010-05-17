# Set the default upstream directory.
UPSTREAM_DIR ?= ../../upstream

UPSTREAM=$(UPSTREAM_DIR)/git

GIT_REPO=horde
GIT_REPO_URL=git://dev.horde.org/horde/git/$(GIT_REPO)
GIT_REPO_UP_CMD=git pull origin master
GIT_REPO_CO_CMD=git clone
GIT_REPO_SC_CMD=git checkout

# Upload location for the fileserver. Configure the kolab filesserver
# in your ssh config at ~/.ssh/config. E.g.:
#
# Host=kolabfiles
# User=wrobel
# Hostname=files.kolab.org
#
FILESERVER = kolabfiles

# Target location for the repository checkout
$(UPSTREAM)/$(SAFE_COMMIT):
	mkdir -p "$(UPSTREAM)/$(SAFE_COMMIT)"

$(UPSTREAM)/$(SAFE_COMMIT)/$(GIT_REPO)/$(GIT_PACKAGE): $(UPSTREAM)/$(SAFE_COMMIT)
	-cd "$(UPSTREAM)/$(GIT_REPO)" && $(GIT_REPO_UP_CMD)
	cd "$(UPSTREAM)/$(GIT_REPO)" && $(GIT_REPO_SC_CMD) "$(SAFE_COMMIT)"

tmp/$(SOURCE_PACKAGE): $(UPSTREAM)/$(SAFE_COMMIT)/$(GIT_REPO)/$(GIT_PACKAGE)
	rm -rf tmp
	mkdir tmp
	cp -r "$(UPSTREAM)/$(GIT_REPO)/$(GIT_PACKAGE)" tmp/$(SOURCE_PACKAGE)

# Package the source
tmp/$(SOURCE_0): tmp/$(SOURCE_PACKAGE)
	cd tmp && tar cvjf $(SOURCE_0) $(SOURCE_PACKAGE)

# Indicator to avoid uploading the same package twice.
tmp/.sent: tmp/$(SOURCE_0)
	echo "put tmp/$(SOURCE_0)" | sftp $(FILESERVER)
	touch tmp/.sent

# Short name for uploading the snapshot.
.PHONY:snapshot
snapshot: tmp/.sent

# Short name for uploading the snapshot.
.PHONY:snapshot-local
snapshot-local: tmp/$(SOURCE_0)
	cp tmp/$(SOURCE_0) $(SOURCE_0)
