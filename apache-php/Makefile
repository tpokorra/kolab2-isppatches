include ../make-helper/kolab.mk

PACKAGE=apache-php
DOWNLOAD_VERSION=5.3.1
OPENPKG_RELEASE=20091129
VERSION=5.3.2
RELEASE=20091129_kolab1

SOURCE_URL=http://www.php.net/distributions
SOURCE_0=php-5.3.2.tar.bz2

PATCHES=../php/patches/php-$(VERSION)/KOLAB_php-$(VERSION)_Annotations.patch \
        ../php/patches/php-$(VERSION)/KOLAB_php-$(VERSION)_myrights.patch

EXTRA=$(PATCHES) kolab.patch

BUILD_OPTIONS=--define 'with_imap_annotate yes' --define 'with_imap_myrights yes' \
              --define 'with_pear yes' --define 'with_gettext yes' \
              --define 'with_dom yes' --define 'with_mcrypt yes' --define 'with_iconv yes' \
              --define 'with_mbstring yes' --define 'with_mbregex yes' --define 'with_gd yes' \
              --define 'with_imap yes' --define 'with_ssl yes' --define 'with_ctype yes' \
              --define 'with_openldap yes' --define 'with_hash yes' --define 'with_zlib yes' \
              --define 'with_bdb yes' --define 'with_xml yes' --define 'with_mm yes' \
              --define 'with_sqlite yes' --define 'with_spl yes' \
              --define 'with_json yes' --define 'with_tokenizer yes'

include ../make-helper/package.mk
include ../make-helper/openpkg-patched.mk
include ../make-helper/fetch.mk
