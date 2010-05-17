include ../make-helper/kolab.mk

PACKAGE=imapd
DOWNLOAD_VERSION=2.3.13
OPENPKG_RELEASE=20081020
VERSION=2.3.16
RELEASE=20081020_kolab7

SOURCE_URL=ftp://ftp.andrew.cmu.edu/pub/cyrus
SOURCE_0=cyrus-imapd-2.3.16.tar.gz

PATCHES=patches/cyrus-imapd-$(VERSION)/KOLAB_cyrus-imapd-$(VERSION)_Cyradm_Annotations.patch \
        patches/cyrus-imapd-$(VERSION)/KOLAB_cyrus-imapd-$(VERSION)_Folder-names.patch \
        patches/cyrus-imapd-$(VERSION)/KOLAB_cyrus-imapd-$(VERSION)_Groups2.patch \
        patches/cyrus-imapd-$(VERSION)/KOLAB_cyrus-imapd-$(VERSION)_Logging.patch \
        patches/cyrus-imapd-$(VERSION)/KOLAB_cyrus-imapd-$(VERSION)_timsieved_starttls-sendcaps.patch \
        patches/cyrus-imapd-$(VERSION)/KOLAB_cyrus-imapd-$(VERSION)_UID.patch \
        patches/cyrus-imapd-$(VERSION)/KOLAB_cyrus-imapd-$(VERSION)_cross-domain-acls.patch

EXTRA=$(PATCHES) kolab.patch imapd.patch

BUILD_OPTIONS=--define 'with_fsl yes' --define 'with_group yes' --define 'with_group_igncase yes' --define 'with_atvdom yes' --define 'with_drac no' --define 'with_replication no' --define 'with_murder no' --define 'with_listext no' --define 'with_nntp no' --define 'with_ldap yes' --define 'with_annotate yes' --define 'with_morelogging yes' --define 'with_kolab yes' --define 'with_kolab_nocaps yes' --define 'with_crossdomain_acl yes'

include ../make-helper/package.mk
include ../make-helper/openpkg-patched.mk
include ../make-helper/fetch.mk
