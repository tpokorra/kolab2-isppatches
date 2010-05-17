include make-helper/kolab.mk

BASE_PACKAGES=apache-php              \
              clamav                  \
              db                      \
              gmp                     \
              imapd                   \
              openldap                \
              openpkg                 \
              perl-ldap               \
              php                     \
              php-smarty              \
              postfix                 \
              sqlite

PERL_PACKAGES=perl-kolab

PERL_MAKEFILES=$(PERL_PACKAGES:%=%/Makefile)

KOLAB_PACKAGES=perl-kolab              \
               kolabd                  \
               kolab-webadmin          \

PEAR_CHANNEL_PACKAGES=                       \
               pear/PEAR-Horde-Channel       \
               pear/PEAR-PHPUnit-Channel     \

PEAR_ONLY_PACKAGES=                     \
               pear/PEAR-Auth_SASL      \
               pear/PEAR-Cache          \
               pear/PEAR-Console_Table  \
               pear/PEAR-DB             \
               pear/PEAR-Date           \
               pear/PEAR-Date_Holidays  \
               pear/PEAR-Date_Holidays_Austria          \
               pear/PEAR-Date_Holidays_Brazil           \
               pear/PEAR-Date_Holidays_Denmark          \
               pear/PEAR-Date_Holidays_Discordian       \
               pear/PEAR-Date_Holidays_EnglandWales     \
               pear/PEAR-Date_Holidays_Germany          \
               pear/PEAR-Date_Holidays_Iceland          \
               pear/PEAR-Date_Holidays_Ireland          \
               pear/PEAR-Date_Holidays_Italy            \
               pear/PEAR-Date_Holidays_Japan            \
               pear/PEAR-Date_Holidays_Netherlands      \
               pear/PEAR-Date_Holidays_Norway           \
               pear/PEAR-Date_Holidays_Romania          \
               pear/PEAR-Date_Holidays_Slovenia         \
               pear/PEAR-Date_Holidays_Sweden           \
               pear/PEAR-Date_Holidays_UNO              \
               pear/PEAR-Date_Holidays_USA              \
               pear/PEAR-Date_Holidays_Ukraine          \
               pear/PEAR-File_Find      \
               pear/PEAR-HTTP_Request   \
               pear/PEAR-Log            \
               pear/PEAR-Mail           \
               pear/PEAR-Mail_mimeDecode \
               pear/PEAR-Mail_Mime      \
               pear/PEAR-Net_DIME       \
               pear/PEAR-Net_LDAP       \
               pear/PEAR-Net_LDAP2      \
               pear/PEAR-Net_LMTP       \
               pear/PEAR-Net_SMTP       \
               pear/PEAR-Net_Sieve      \
               pear/PEAR-Net_Socket     \
               pear/PEAR-Net_URL        \
               pear/PEAR-SOAP           \
               pear/PEAR-Services_Weather \
               pear/PEAR-XML_Parser     \
               pear/PEAR-XML_Serializer \
               pear/PEAR-XML_Util       \
               pear/PHPUnit

PEAR_HORDE_PACKAGES=                    \
               pear/Horde_Alarm         \
               pear/Horde_Argv          \
               pear/Horde_Auth          \
               pear/Horde_Block         \
               pear/Horde_Browser       \
               pear/Horde_CLI           \
               pear/Horde_Cache         \
               pear/Horde_Cipher        \
               pear/Horde_Compress      \
               pear/Horde_Crypt         \
               pear/Horde_DOM           \
               pear/Horde_Data          \
               pear/Horde_DataTree      \
               pear/Horde_Date          \
               pear/Horde_Editor        \
               pear/Horde_Feed          \
               pear/Horde_File_CSV      \
               pear/Horde_File_PDF      \
               pear/Horde_Form          \
               pear/Horde_Framework     \
               pear/Horde_Group         \
               pear/Horde_History       \
               pear/Horde_Http_Client   \
               pear/Horde_Image         \
               pear/Horde_IMAP          \
               pear/Horde_Kolab         \
               pear/Horde_LDAP          \
               pear/Horde_Loader        \
               pear/Horde_Lock          \
               pear/Horde_Log           \
               pear/Horde_MIME          \
               pear/Horde_Maintenance   \
               pear/Horde_Mobile        \
               pear/Horde_NLS           \
               pear/Horde_Net_SMS       \
               pear/Horde_Notification  \
               pear/Horde_Perms         \
               pear/Horde_Prefs         \
               pear/Horde_RPC           \
               pear/Horde_SQL           \
               pear/Horde_Secret        \
               pear/Horde_Serialize     \
               pear/Horde_SessionHandler \
               pear/Horde_SessionObjects \
               pear/Horde_Share         \
               pear/Horde_SpellChecker  \
               pear/Horde_SyncML        \
               pear/Horde_Template      \
               pear/Horde_Text_Diff     \
               pear/Horde_Text_Filter   \
               pear/Horde_Text_Flowed   \
               pear/Horde_Text_Textile  \
               pear/Horde_Token         \
               pear/Horde_Tree          \
               pear/Horde_UI            \
               pear/Horde_Util          \
               pear/Horde_VC            \
               pear/Horde_XML_WBXML     \
               pear/Horde_Xml_Element   \
               pear/Horde_Yaml          \
               pear/Horde_iCalendar

PEAR_KOLAB_PACKAGES=                    \
               php-kolab/Kolab_Filter   \
               php-kolab/Kolab_Format   \
               php-kolab/Kolab_Freebusy \
               php-kolab/Kolab_Server   \
               php-kolab/Kolab_Storage

PEAR_PACKAGES= $(PEAR_CHANNEL_PACKAGES)      \
               $(PEAR_ONLY_PACKAGES)         \
               $(PEAR_HORDE_PACKAGES)        \
               $(PEAR_KOLAB_PACKAGES)        \

CLIENT_PACKAGES=kolab-webclient/dimp            \
                kolab-webclient/horde           \
                kolab-webclient/imp             \
                kolab-webclient/ingo            \
                kolab-webclient/kronolith       \
                kolab-webclient/kolab-webclient \
                kolab-webclient/mimp            \
                kolab-webclient/mnemo           \
                kolab-webclient/passwd          \
                kolab-webclient/nag             \
                kolab-webclient/turba           \
#                kolab-fbview                    \

BASE_FILES=install-kolab.sh \
           1st.README

CURRENT_SOURCE_RELEASE = http://files.kolab.org/server/release/kolab-server-$(KOLAB_VERSION)/sources/
CURRENT_BINARY_RELEASE = http://files.kolab.org/server/release/kolab-server-$(KOLAB_VERSION)/$(PLATFORM)/

PHPUNIT=$(KOLABDIR)/bin/phpunit

PHPUNIT_TESTS=$(KOLABDIR)/lib/php/test/Kolab_Server/Horde/Kolab/Server/AllTests.php \
              $(KOLABDIR)/lib/php/test/Kolab_Format/Horde/Kolab/Format/AllTests.php \
              $(KOLABDIR)/lib/php/test/Kolab_Storage/Horde/Kolab/Storage/AllTests.php \
              $(KOLABDIR)/lib/php/test/Kolab_Filter/Horde/Kolab/Filter/AllTests.php \
              $(KOLABDIR)/lib/php/test/Kolab_FreeBusy/Horde/Kolab/FreeBusy/AllTests.php

PEAR_H4_CHANNEL_PACKAGES=               \
        pear-h4/PEAR-PHPUnit-Channel-H4 \
#        pear-h4/PEAR-Horde-Channel-H4   \

PEAR_H4_PACKAGES=                       \
        pear-h4/PEAR-Auth_SASL-H4       \
        pear-h4/PEAR-DB-H4              \
        pear-h4/PEAR-Log-H4             \
        pear-h4/PEAR-Mail-H4            \
        pear-h4/PEAR-Net_SMTP-H4        \
        pear-h4/PEAR-Net_Socket-H4      \
        pear-h4/PEAR-PEAR-H4            \
        pear-h4/PHPUnit-H4

HORDE_H4_PACKAGES=                      \
        pear-h4/Horde_Ajax-H4           \
        pear-h4/Horde_Alarm-H4          \
        pear-h4/Horde_Auth-H4           \
        pear-h4/Horde_Autoloader-H4     \
        pear-h4/Horde_Block-H4          \
        pear-h4/Horde_Browser-H4        \
        pear-h4/Horde_Cache-H4          \
        pear-h4/Horde_Cipher-H4         \
        pear-h4/Horde_Cli-H4            \
        pear-h4/Horde_Core-H4           \
        pear-h4/Horde_Date-H4           \
        pear-h4/Horde_Db-H4             \
        pear-h4/Horde_Editor-H4         \
        pear-h4/Horde_Exception-H4      \
        pear-h4/Horde_Form-H4           \
        pear-h4/Horde_Group-H4          \
        pear-h4/Horde_Image-H4          \
        pear-h4/Horde_Imap_Client-H4    \
        pear-h4/Horde_Injector-H4       \
        pear-h4/Horde_Ldap-H4           \
        pear-h4/Horde_Log-H4            \
        pear-h4/Horde_LoginTasks        \
        pear-h4/Horde_Mime-H4           \
        pear-h4/Horde_Nls-H4            \
        pear-h4/Horde_Notification-H4   \
        pear-h4/Horde_Perms-H4          \
        pear-h4/Horde_Prefs-H4          \
        pear-h4/Horde_Secret-H4         \
        pear-h4/Horde_Serialize-H4      \
        pear-h4/Horde_SessionObjects-H4 \
        pear-h4/Horde_Template-H4       \
        pear-h4/Horde_Test-H4           \
        pear-h4/Horde_Text_Filter-H4    \
        pear-h4/Horde_Text_Flowed-H4    \
        pear-h4/Horde_Token-H4          \
        pear-h4/Horde_Tree-H4           \
        pear-h4/Horde_Ui-H4             \
        pear-h4/Horde_Url-H4            \
        pear-h4/Horde_Util-H4           \
        pear-h4/Horde_Vfs-H4            \
        pear-h4/Kolab_Server-H4         \
        pear-h4/Kolab_Session-H4
#        pear-h4/Horde_Argv-H4           \
#        pear-h4/Horde_Compress-H4       \
#        pear-h4/Horde_Controller-H4     \
#        pear-h4/Horde_Crypt-H4          \
#        pear-h4/Horde_Data-H4           \
#        pear-h4/Horde_Feed-H4           \
#        pear-h4/Horde_File_CSV-H4       \
#        pear-h4/Horde_File_PDF-H4       \
#        pear-h4/Horde_History-H4        \

CLIENT_H4_PACKAGES=                     \
        kolab-webclient-h4/horde-h4     \
        kolab-webclient-h4/imp-h4       \
#                 kolab-webclient/ingo            \
#                 kolab-webclient/kronolith       \
#                 kolab-webclient/kolab-webclient \
#                 kolab-webclient/mnemo           \
#                 kolab-webclient/passwd          \
#                 kolab-webclient/nag             \
#                 kolab-webclient/turba           \

PHPUNIT_TESTS_H4=$(HOME)/lib/php-h4/test/Kolab_Server/Horde/Kolab/Server/AllTests.php \

# The default target is building the distributable Kolab Server
# packages
.PHONY: all
all: dist

# Fetches our basic requirements. This target allows testing if the
# basic building blocks are available. But you may also use it to
# download all requirements and unplug your network before running
# "make dist"
.PHONY: fetch
fetch: fetch-base fetch-pear-only fetch-pear-horde fetch-pear-kolab fetch-client

# The core target that builds the server packages.
.PHONY: dist
dist: $(KOLABDIR) dist-base dist-pear-channel dist-kolab dist-pear-only dist-pear-horde dist-pear-kolab dist-client files

# Clean up all directories.
.PHONY: clean
clean: clean-base clean-pear-channel clean-kolab clean-pear-only clean-pear-horde clean-pear-kolab clean-client clean-stage
	find . | grep "~$$" | xargs rm -rf

####################
# BASE START
####################
# Sub targets for our basic Kolab Server packages.

.PHONY: fetch-base
fetch-base: $(BASE_PACKAGES:%=fetch-%)

.PHONY: $(BASE_PACKAGES:%=fetch-%)
$(BASE_PACKAGES:%=fetch-%):
	make -e -C $(@:fetch-%=%) fetch

.PHONY: clean-base
dist-base: $(BASE_PACKAGES:%=dist-%)

.PHONY: $(BASE_PACKAGES:%=dist-%)
$(BASE_PACKAGES:%=dist-%):
	make -e -C $(@:dist-%=%) dist

.PHONY: clean-base
clean-base: $(BASE_PACKAGES:%=clean-%)

.PHONY: $(BASE_PACKAGES:%=clean-%)
$(BASE_PACKAGES:%=clean-%):
	make -e -C $(@:clean-%=%) clean

####################
# BASE END
####################

####################
# KOLAB START
####################
#
# @TODO: These packages are still unclean. kolabd and kolab-webadmin
# do not deliver clean source archives as their configure script
# produces platform dependent source code. The configuration should
# only happen via configuration files and not via configure.
#

.PHONY: dist-kolab
dist-kolab: $(PERL_MAKEFILES) $(KOLAB_PACKAGES:%=dist-%)

.PHONY: $(KOLAB_PACKAGES:%=dist-%)
$(KOLAB_PACKAGES:%=dist-%):
	make -e -C $(@:dist-%=%) dist

$(PERL_MAKEFILES): $(@:%=%.PL)
	cd $(@:%/Makefile=%) && perl Makefile.PL

.PHONY: clean-kolab
clean-kolab: $(KOLAB_PACKAGES:%=clean-%)

.PHONY: $(KOLAB_PACKAGES:%=clean-%)
$(KOLAB_PACKAGES:%=clean-%):
	make -e -C $(@:clean-%=%) clean_all

####################
# KOLAB END
####################

####################
# PEAR ONLY START
####################
# Sub targets for pear packages from pear.php.net

.PHONY: fetch-pear-only
fetch-pear-only: $(PEAR_ONLY_PACKAGES:%=fetch-%)

.PHONY: $(PEAR_ONLY_PACKAGES:%=fetch-%)
$(PEAR_ONLY_PACKAGES:%=fetch-%):
	make -e -C $(@:fetch-%=%) fetch

.PHONY: dist-pear-only
dist-pear-only: $(PEAR_ONLY_PACKAGES:%=dist-%)

.PHONY: $(PEAR_ONLY_PACKAGES:%=dist-%)
$(PEAR_ONLY_PACKAGES:%=dist-%):
	make -e -C $(@:dist-%=%) dist

.PHONY: clean-pear-only
clean-pear-only: $(PEAR_ONLY_PACKAGES:%=clean-%)

.PHONY: $(PEAR_ONLY_PACKAGES:%=clean-%)
$(PEAR_ONLY_PACKAGES:%=clean-%):
	make -e -C $(@:clean-%=%) clean

####################
# PEAR ONLY END
####################

####################
# PEAR HORDE START
####################
# Sub targets for pear packages from pear.horde.org

.PHONY: fetch-pear-horde
fetch-pear-horde: $(PEAR_HORDE_PACKAGES:%=fetch-%)

.PHONY: $(PEAR_HORDE_PACKAGES:%=fetch-%)
$(PEAR_HORDE_PACKAGES:%=fetch-%):
	make -e -C $(@:fetch-%=%) fetch

.PHONY: dist-pear-horde
dist-pear-horde: $(PEAR_HORDE_PACKAGES:%=dist-%)

.PHONY: $(PEAR_HORDE_PACKAGES:%=dist-%)
$(PEAR_HORDE_PACKAGES:%=dist-%):
	make -e -C $(@:dist-%=%) dist

.PHONY: clean-pear-horde
clean-pear-horde: $(PEAR_HORDE_PACKAGES:%=clean-%)

.PHONY: $(PEAR_HORDE_PACKAGES:%=clean-%)
$(PEAR_HORDE_PACKAGES:%=clean-%):
	make -e -C $(@:clean-%=%) clean

.PHONY: snapshot-pear-horde
snapshot-pear-horde: $(PEAR_HORDE_PACKAGES:%=snapshot-%)

.PHONY: $(PEAR_HORDE_PACKAGES:%=snapshot-%)
$(PEAR_HORDE_PACKAGES:%=snapshot-%):
	make -e -C $(@:snapshot-%=%) snapshot

####################
# PEAR HORDE END
####################

####################
# PEAR KOLAB START
####################
# Sub targets for pear packages from pear.php.net

.PHONY: fetch-pear-kolab
fetch-pear-kolab: $(PEAR_KOLAB_PACKAGES:%=fetch-%)

.PHONY: $(PEAR_KOLAB_PACKAGES:%=fetch-%)
$(PEAR_KOLAB_PACKAGES:%=fetch-%):
	make -e -C $(@:fetch-%=%) fetch

.PHONY: dist-pear-kolab
dist-pear-kolab: $(PEAR_KOLAB_PACKAGES:%=dist-%)

.PHONY: $(PEAR_KOLAB_PACKAGES:%=dist-%)
$(PEAR_KOLAB_PACKAGES:%=dist-%):
	make -e -C $(@:dist-%=%) dist

.PHONY: clean-pear-kolab
clean-pear-kolab: $(PEAR_KOLAB_PACKAGES:%=clean-%)

.PHONY: $(PEAR_KOLAB_PACKAGES:%=clean-%)
$(PEAR_KOLAB_PACKAGES:%=clean-%):
	make -e -C $(@:clean-%=%) clean

####################
# PEAR KOLAB END
####################

####################
# PEAR CHANNEL START
####################
# Sub targets for pear channels

.PHONY: dist-pear-channel
dist-pear-channel: $(PEAR_CHANNEL_PACKAGES:%=dist-%)

.PHONY: $(PEAR_CHANNEL_PACKAGES:%=dist-%)
$(PEAR_CHANNEL_PACKAGES:%=dist-%):
	make -e -C $(@:dist-%=%) dist

.PHONY: clean-pear-channel
clean-pear-channel: $(PEAR_CHANNEL_PACKAGES:%=clean-%)

.PHONY: $(PEAR_CHANNEL_PACKAGES:%=clean-%)
$(PEAR_CHANNEL_PACKAGES:%=clean-%):
	make -e -C $(@:clean-%=%) clean

####################
# PEAR CHANNEL END
####################

####################
# CLIENT START
####################
# Sub targets for the web client

.PHONY: fetch-client
fetch-client: $(CLIENT_PACKAGES:%=fetch-%)

.PHONY: $(CLIENT_PACKAGES:%=fetch-%)
$(CLIENT_PACKAGES:%=fetch-%):
	make -e -C $(@:fetch-%=%) fetch

.PHONY: dist-client
dist-client: $(CLIENT_PACKAGES:%=dist-%)

.PHONY: $(CLIENT_PACKAGES:%=dist-%)
$(CLIENT_PACKAGES:%=dist-%):
	make -e -C $(@:dist-%=%) dist

.PHONY: clean-client
clean-client: $(CLIENT_PACKAGES:%=clean-%)

.PHONY: $(CLIENT_PACKAGES:%=clean-%)
$(CLIENT_PACKAGES:%=clean-%):
	make -e -C $(@:clean-%=%) clean

####################
# CLIENT END
####################

####################
# HORDE 4 START
####################
# Wrapper targets for the Horde 4 installation

# Fetches our basic Horde 4 requirements.
.PHONY: fetch-h4
fetch-h4: fetch-pear-h4-only fetch-pear-h4-horde fetch-h4-client

# The core target that builds the Horde 4 packages.
.PHONY: dist-h4
dist-h4: dist-pear-h4-channel dist-pear-h4-only dist-pear-h4-horde dist-client-h4

# Clean up all directories.
.PHONY: clean-h4
clean-h4: clean-pear-h4-channel clean-pear-h4-only clean-pear-h4-horde clean-client-h4

# Generate all snapshots
.PHONY: snapshot-h4
snapshot-h4: snapshot-pear-h4-horde snapshot-client-h4

ifeq "x$(TEST_ENVIRONMENT)" "xYES"
.PHONY: install-h4
install-h4: dist-h4
	cd stage/$(PLATTAG) && \
	openpkg rpm -Uhv --force --nodeps *-h4*.rpm
	openpkg rpm -Uhv --force --nodeps *-H4*.rpm
endif

####################
# HORDE 4 END
####################

####################
# PEAR H4 START
####################
# Sub targets for pear packages from pear.php.net

.PHONY: fetch-pear-h4-only
fetch-pear-h4-only: $(PEAR_H4_PACKAGES:%=fetch-%)

.PHONY: $(PEAR_H4_PACKAGES:%=fetch-%)
$(PEAR_H4_PACKAGES:%=fetch-%):
	make -e -C $(@:fetch-%=%) fetch

.PHONY: dist-pear-h4-only
dist-pear-h4-only: $(PEAR_H4_PACKAGES:%=dist-%)

.PHONY: $(PEAR_H4_PACKAGES:%=dist-%)
$(PEAR_H4_PACKAGES:%=dist-%):
	make -e -C $(@:dist-%=%) dist

.PHONY: clean-pear-h4-only
clean-pear-h4-only: $(PEAR_H4_PACKAGES:%=clean-%)

.PHONY: $(PEAR_H4_PACKAGES:%=clean-%)
$(PEAR_H4_PACKAGES:%=clean-%):
	make -e -C $(@:clean-%=%) clean

####################
# PEAR H4 END
####################

#####################
# HORDE H4 START
#####################
# Sub targets for pear packages from pear.horde.org

.PHONY: fetch-pear-h4-horde
fetch-pear-h4-horde: $(HORDE_H4_PACKAGES:%=fetch-%)

.PHONY: $(HORDE_H4_PACKAGES:%=fetch-%)
$(HORDE_H4_PACKAGES:%=fetch-%):
	make -e -C $(@:fetch-%=%) fetch

.PHONY: dist-pear-h4-horde
dist-pear-h4-horde: $(HORDE_H4_PACKAGES:%=dist-%)

.PHONY: $(HORDE_H4_PACKAGES:%=dist-%)
$(HORDE_H4_PACKAGES:%=dist-%):
	make -e -C $(@:dist-%=%) dist

.PHONY: clean-pear-h4-horde
clean-pear-h4-horde: $(HORDE_H4_PACKAGES:%=clean-%)

.PHONY: $(HORDE_H4_PACKAGES:%=clean-%)
$(HORDE_H4_PACKAGES:%=clean-%):
	make -e -C $(@:clean-%=%) clean

.PHONY: snapshot-pear-h4-horde
snapshot-pear-h4-horde: $(HORDE_H4_PACKAGES:%=snapshot-%)

.PHONY: $(HORDE_H4_PACKAGES:%=snapshot-%)
$(HORDE_H4_PACKAGES:%=snapshot-%):
	make -e -C $(@:snapshot-%=%) snapshot

.PHONY: snapshot-local-pear-h4-horde
snapshot-local-pear-h4-horde: $(HORDE_H4_PACKAGES:%=snapshot-local-%)

.PHONY: $(HORDE_H4_PACKAGES:%=snapshot-local-%)
$(HORDE_H4_PACKAGES:%=snapshot-local-%):
	make -e -C $(@:snapshot-local-%=%) snapshot-local

####################
# HORDE H4 END
####################

#######################
# PEAR H4 CHANNEL START
#######################
# Sub targets for pear channels

.PHONY: dist-pear-h4-channel
dist-pear-h4-channel: $(PEAR_H4_CHANNEL_PACKAGES:%=dist-%)

.PHONY: $(PEAR_H4_CHANNEL_PACKAGES:%=dist-%)
$(PEAR_H4_CHANNEL_PACKAGES:%=dist-%):
	make -e -C $(@:dist-%=%) dist

.PHONY: clean-pear-h4-channel
clean-pear-h4-channel: $(PEAR_H4_CHANNEL_PACKAGES:%=clean-%)

.PHONY: $(PEAR_H4_CHANNEL_PACKAGES:%=clean-%)
$(PEAR_H4_CHANNEL_PACKAGES:%=clean-%):
	make -e -C $(@:clean-%=%) clean

#####################
# PEAR H4 CHANNEL END
#####################

####################
# CLIENT H4 START
####################
# Sub targets for the web client

.PHONY: fetch-client-h4
fetch-h4-client: $(CLIENT_H4_PACKAGES:%=fetch-%)

.PHONY: $(CLIENT_H4_PACKAGES:%=fetch-%)
$(CLIENT_H4_PACKAGES:%=fetch-%):
	make -e -C $(@:fetch-%=%) fetch

.PHONY: dist-client-h4
dist-client-h4: $(CLIENT_H4_PACKAGES:%=dist-%)

.PHONY: $(CLIENT_H4_PACKAGES:%=dist-%)
$(CLIENT_H4_PACKAGES:%=dist-%):
	make -e -C $(@:dist-%=%) dist

.PHONY: clean-client-h4
clean-client-h4: $(CLIENT_H4_PACKAGES:%=clean-%)

.PHONY: $(CLIENT_H4_PACKAGES:%=clean-%)
$(CLIENT_H4_PACKAGES:%=clean-%):
	make -e -C $(@:clean-%=%) clean

.PHONY: snapshot-client-h4
snapshot-client-h4: $(CLIENT_H4_PACKAGES:%=snapshot-%)

.PHONY: $(CLIENT_H4_PACKAGES:%=snapshot-%)
$(CLIENT_H4_PACKAGES:%=snapshot-%):
	make -e -C $(@:snapshot-%=%) snapshot

.PHONY: snapshot-local-client-h4
snapshot-local-client-h4: $(CLIENT_H4_PACKAGES:%=snapshot-local-%)

.PHONY: $(CLIENT_H4_PACKAGES:%=snapshot-local-%)
$(CLIENT_H4_PACKAGES:%=snapshot-local-%):
	make -e -C $(@:snapshot-local-%=%) snapshot-local

####################
# CLIENT H4 END
####################

####################
# STAGING START
####################
# Sub targets for the package staging area.

stage/source:
	mkdir -p stage/source

.PHONY: clean-stage
clean-stage:
	rm -rf stage

.PHONY: files
files: stage/source
	cp $(BASE_FILES) stage/source/
	echo 'Remember to update 00INDEX.rdf!'

####################
# STAGING END
####################

####################
# SETUP START
####################
# Sub targets for installing a server from the binary distribution.
# The whole section is only active if we manually marked the server
# as being a test machine (by creating the test_environment file).

ifeq "x$(TEST_ENVIRONMENT)" "xYES"
# Convenience target for installing the server
.PHONY:install-server
install-server: $(KOLABDIR)

# Convenience target for downloading the binary server packages
.PHONY:download-binary
download-binary: $(BINARY_PKGS_DIR)

# Downloads the binary packages for installation
$(BINARY_PKGS_DIR):
	mkdir -p $@
	cd $@ && wget -r -l1 -nd --no-parent $(CURRENT_BINARY_RELEASE)

# Installs the Kolab server from the binary packages
$(KOLABDIR): $(BINARY_PKGS_DIR)
	cd $(BINARY_PKGS_DIR) && sh install-kolab.sh -t $(KOLABUSR) -I $(KOLABUID) 2>&1 | tee kolab-install.log

# Convenience target for downloading the source server packages
.PHONY:download-source
download-source: $(SOURCE_PKGS_DIR)

# Downloads the binary packages for installation
$(SOURCE_PKGS_DIR):
	mkdir -p $@
	cd $@ && wget -r -l1 -nd --no-parent $(CURRENT_SOURCE_RELEASE)

# Installs the Kolab server from the source packages. This should not
# be the common target is mainly meant as a helper if you are working
# on a platform where binaries cannot be downloaded from files.kolab.org
.PHONY:install-server-from-source
install-server-from-source: $(SOURCE_PKGS_DIR)
	cd $(SOURCE_PKGS_DIR) && sh install-kolab.sh -t $(KOLABUSR) -I $(KOLABUID) 2>&1 | tee kolab-install.log

# Convenience target to uninstall the server
.PHONY:clean-server
clean-server:
	@echo "THIS WILL COMPLETELY WIPE YOUR KOLAB SERVER INSTALLATION IN $(KOLABDIR)!!!"
	@echo "You have 5 seconds to abort..."
	@sleep 5
	/kolab/bin/openpkg rpm -e `/kolab/bin/openpkg rpm -qa`
	rm -rf $(KOLABDIR)
else
# If we are not in a test environment then we assume the Kolab server has
# been installed manually. This target should never be invoked as there
# is already a check in make-helpers/kolab.mk
$(KOLABDIR):
	@echo "The Kolab server installation is missing from $(KOLABDIR)."
endif

####################
# SETUP END
####################

####################
# UPDATE START
####################
# Sub targets for updating an installed server to the packages
# generated from CVS.
# The whole section is only active if we manually marked the server
# as being a test machine (by creating the test_environment file).

ifeq "x$(TEST_ENVIRONMENT)" "xYES"
.PHONY: update
update: dist
	cd stage/$(PLATTAG) && \
	openpkg rpm -Uhv --force --nodeps *.rpm
endif

####################
# UPDATE END
####################

####################
# TESTING START
####################
# Sub targets for running test scripts on the server.
#

#
# @TODO: Warning: Does not work yet! Needs to be completed.
#

.PHONY: test
test:
	@for TEST in $(PHPUNIT_TESTS); \
	do                             \
          PHPUNIT='';                  \
	  $(PHPUNIT) -d date.timezone="Europe/Berlin" -d log_errors=1 -d error_log="/tmp/$${TEST//\//_}-php-errors.log" $$TEST 2>&1 | tee /tmp/$${TEST//\//_}-phpunit.log | grep "^OK" > /dev/null || PHPUNIT="FAIL"; \
	  if [ -n "$$PHPUNIT" ]; then  \
	    echo;                      \
	    echo "FAIL ($$TEST): Some phpunit tests failed!"; \
	    echo; echo "PHPUnit Report:";echo; \
	    cat /tmp/$${TEST//\//_}-phpunit.log; \
	    echo; echo "PHP Error log:";echo; \
            cat /tmp/$${TEST//\//_}-php-errors.log; \
	  else                         \
	    echo -n ".";               \
	  fi;                          \
	done; echo

####################
# TESTING END
####################
