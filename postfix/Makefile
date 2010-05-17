include ../make-helper/kolab.mk

PACKAGE=postfix
DOWNLOAD_VERSION=2.4.6
OPENPKG_RELEASE=20080101
VERSION=2.4.6
RELEASE=20080101_kolab

SOURCE_URL=
SOURCE_0=

PATCHES=

EXTRA=kolab.patch

BUILD_OPTIONS=--define 'with_fsl yes' --define 'with_ssl yes' --define 'with_sasl yes' --define 'with_ldap yes'

include ../make-helper/package.mk
include ../make-helper/openpkg-patched.mk
include ../make-helper/fetch.mk
