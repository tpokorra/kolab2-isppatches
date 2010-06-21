#!/bin/sh
#
# $Id: install-kolab.sh,v 1.66 2010/06/08 08:21:41 gunnar Exp $
#
# Copyright (C) 2007, 2008, 2009 by Intevation GmbH
# Copyright (C) 2007 by Gunnar Wrobel
#
# Authors:
# Thomas Arendsen Hein <thomas@intevation.de>
# Gunnar Wrobel <wrobel@pardus.de>
# Sascha Wilde <wilde@intevation.de>
#
# This program is free software under the GNU GPL (>=v2)

KOLAB_VERSION="2.2.3+CVS"
KID="19414"

TAG="kolab"
USER=""
PREFIX=""

PACKAGES="openpkg-tools openldap postfix kolabd kolab-webadmin kolab-fbview kolab-webclient"
DEFINE="-D openldap::with_pth=no -D sasl::with_ldap -D sasl::with_login -D sasl::with_ntlm -D postfix::with_sasl -D postfix::with_ssl -D postfix::with_ldap -D imapd::with_kolab_nocaps"
EXCLUDEPKGS=""

#Flags
FLAG_BOOTSTRAP=""
FLAG_ENV=""
FLAG_CLEAN=""

usage() {
    echo "Usage:"
    echo "  $0         (will try to determine mode of action itself)"
    echo
    echo "Options:"
    echo
    echo "  Some of these options (for example UID, installation prefix)"
    echo "  only work as expected when installing from source packages."
    echo
    echo "  -t TAG     (alternate binary tag;          default is kolab)"
    echo "  -I UID     (alternate base uid;            default is 19414)"
    echo
    echo "  -c         (clean the environment specified with \$PREFIX; DANGEROUS!)"
    echo
    echo "  -p PREFIX  (alternate installation prefix; default is /\$TAG)"
    echo "  -u USER    (alternate user name;           default is \$TAG)"
    echo
    echo "  -V VERSION (alternate version;             default is $KOLAB_VERSION)"
    echo
    echo "  -x PACKAGE (exclude PACKAGE from installation, can be given more than once)"
    echo
    echo "  -X         (generate 00INDEX.rdf for packages in the current directory"
    echo "              using the OpenPKG installation in /\$PREFIX)"
    echo
    echo "  -B         (abort after generating the OpenPKG bootstrap packages)"
    echo "  -E         (abort after generating the OpenPKG environment)"
    echo
    echo "  -O         (additional build options, used for OpenPKG bootstraping from source)"
    echo
    echo "  -h         (display this help)"
}

# check if find command supports -mindepth and -maxdepth, see
# kolab/issue2924 (install-kolab.sh: -maxdepth/-mindepth not supported by all find implementations)
if [ "`find / -mindepth 0 -maxdepth 0 2>/dev/null`" = "/" ]; then
    FIND1="-mindepth 1 -maxdepth 1"
else
    echo "WARNING: Your find does not support -mindepth/-maxdepth, make sure" >&2
    echo "you are in the correct directory, see issues.kolab.org/issue2924" >&2
    FIND1=""
fi

mktmpdir() {
  newtmp="${TMPDIR-/tmp}/install-kolab.$RANDOM.$RANDOM.$RANDOM.$$"
  mkdir "$newtmp" || {
    echo "Could not create temporary directory! Exiting." 1>&2
    exit 1
  }
  echo "$newtmp"
}

shtool_get_plattag() {
  [ -f shtool ] || sh "$INSTALLER" -t | tar xf - shtool
  echo `sh shtool platform --type=binary`-$TAG
}

populate_workdir() {
  if [ -z "$SRCDIR" -o -z "$WORKDIR" ] ; then
    echo "Source or working directory missing." 1>&2
    exit 1
  fi
  cp "$SRCDIR"/openpkg-2*.rpm "$WORKDIR"
  cp "$SRCDIR"/openpkg-*.sh "$WORKDIR"
  ln -sf "$SRCDIR/00INDEX.rdf" "$WORKDIR"
  find "$SRCDIR" $FIND1 -name "*.rpm" \! -name "openpkg-2*.rpm" -exec ln -sf '{}' "$WORKDIR" \;
}

remove_from_list() {
# Return list $2 with all elements in list $1 removed.
  newlist=""
  for element in $2 ; do
    delelt=""
    for remove in $1 ; do
      if [ "$element" = "$remove" ] ; then
        delelt="t"
        break
      fi
    done
    [ "$delelt" ] || newlist="$newlist $element"
  done
  echo "$newlist"
}

while getopts hcBXEV:p:I:u:t:O:x: ARGS; do
    case $ARGS in
        h) # Display help
            usage
            exit 0
            ;;
        V) # User specified a specific Kolab version
            KOLAB_VERSION="$OPTARG"
            ;;
        p) # User specified an alternative prefix
            PREFIX="$OPTARG"
            ;;
        I) # User specified an alternative base Kolab UID
            KID="$OPTARG"
            ;;
        u) # User specified an alternative user name
            USER="$OPTARG"
            ;;
        t) # User specified an alternative tag
            TAG="$OPTARG"
            ;;
        B) # User only wants the OpenPKG bootstrap packages
            FLAG_BOOTSTRAP="Yes"
            ;;
        E) # User only wants the OpenPKG environment
            FLAG_ENV="Yes"
            ;;
        c) # User wants to erase the OpenPKG environment
            FLAG_CLEAN="Yes"
            ;;
        x) # exclude from installation
            EXCLUDEPKGS="$EXCLUDEPKGS $OPTARG"
            ;;
        X) # User wants to collect a set of packages into 00INDEX.rdf
            FLAG_INDEX="Yes"
            ;;
        O) # User wants additional options when building OpenPKG
            ADDITIONAL_BUILD_OPTS="$OPTARG"
            ;;
        *) # Unknown Option
            echo
            usage
            exit 1
            ;;
    esac
done

if [ -z "$USER" ]; then
    USER=$TAG
fi

if [ -z "$PREFIX" ]; then
    PREFIX="/$TAG"
fi

R_KID=`expr $KID + 1`
N_KID=`expr $R_KID + 1`

if [ "$FLAG_CLEAN" -o "$FLAG_INDEX" ]; then
    if [ -x "$PREFIX/bin/openpkg" ]; then
        if [ "$FLAG_CLEAN" ]; then
            echo
            echo "This will completely wipe your installation in $PREFIX!"
            echo "Are you certain you want to do that (YES/NO)?"
            read ANSWER
            if [ "$ANSWER" = "YES" ]; then
                $PREFIX/bin/openpkg rpm -e `$PREFIX/bin/openpkg rpm -qa` || exit $?
                echo "Erased OpenPKG environment $PREFIX"
                exit 0
            else
                echo "Not cleaning."
                exit 0
            fi
        elif [ "$FLAG_INDEX" ]; then
            BINARY=`find . $FIND1 -name "openpkg-2*.rpm" \! -name "openpkg-*.src.rpm" -print`
            if [ -z "$BINARY" ]; then
                echo "Generating 00INDEX.rdf for source distribution ..."
                exec "$PREFIX/bin/openpkg" index -r . -o 00INDEX.rdf -C $PREFIX/RPM/DB/00INDEX-cache.db -i .
            else
                PLATTAG=`"$PREFIX/bin/openpkg" rpm -q --qf="%{ARCH}-%{OS}" openpkg`-$TAG
                echo "Generating 00INDEX.rdf for binary ($PLATTAG) distribution ..."
                exec "$PREFIX/bin/openpkg" index -r . -o 00INDEX.rdf -C $PREFIX/RPM/DB/00INDEX-cache.db -i -p $PLATTAG .
            fi
        fi
    else
        echo "\"$PREFIX\" seems to be no OpenPKG environment."
        exit 1
    fi
fi

echo
echo "Kolab installation tag (TAG):       $TAG"
echo "Kolab installation prefix (PREFIX): $PREFIX"
echo "Kolab version (KOLAB_VERSION):      $KOLAB_VERSION"
echo "Kolab user name (USER):             $USER"
echo "Kolab user base UID (KID):          $KID"
echo "Kolab restricted UID (KID):         $R_KID"
echo "Kolab non-priviledged UID (KID):    $N_KID"
echo "Exclude following Kolab packages:   $EXCLUDEPKGS"
echo

prefix_openpkg_determine_action() {
    umask 022
    SRCDIR=`pwd`
    WORKDIR=`mktmpdir`
    echo "Changing to temporary working directory $WORKDIR ..."
    cd "$WORKDIR"
    populate_workdir

    echo "Received no instructions. Trying to determine required action..."
    if [ -d "$PREFIX/etc/openpkg" -a -z "$FLAG_BOOTSTRAP" ]; then
    # Assume an upgrade based on the current directory
	INSTALL=`pwd`
	if [ "$FLAG_ENV" ]; then
            echo "The OpenPKG environment already exists!"
            exit 1
	fi
	echo "Found an OpenPKG environment. Assuming upgrade..."
    else
	INSTALLER=`find . $FIND1 -name "openpkg-*.src.sh" -print`
	BINARY=`find . $FIND1 -name "openpkg-*.sh" \! -name "openpkg-*.src.sh" -print`
	if [ -z "$INSTALLER" ]; then
        # No install script? Determine if there is a binary script
            if [ -z "$BINARY" ]; then
		echo "Sorry there is no OpenPKG installation script in the current directory!"
		usage
		exit 0
            else
            # Looks like we only have a binary. Hope that it matches the plattform and install it
		INSTALL="$BINARY"
		echo "Found a binary OpenPKG package. This will be installed now."
            fi
	else
        # We have a source package. Check for a matching binary
            PLATTAG=`shtool_get_plattag`
            BIN=`basename "$INSTALLER" .src.sh`.$PLATTAG.sh
            if [ "$BINARY" = "$BIN" ]; then
            # There is a binary with the correct tag. Install it
		INSTALL=$BIN
		echo "Found a binary OpenPKG package with a correct tag. This will be installed now."
            else
            # Install from source
		INSTALL=$INSTALLER
		echo "Found a source based OpenPKG installer. Trying to install Kolab from source."
            fi
	fi
    fi

    if echo "$INSTALL" | grep '\.src\.sh$' >/dev/null; then
    # install from source
	SRC="$INSTALL"
	PLATTAG=`shtool_get_plattag`
	BIN=`basename "$INSTALL" .src.sh`.$PLATTAG.sh
	DIR=`dirname "$SRC"`
    elif echo "$INSTALL" | grep 'openpkg-.*\.sh$' >/dev/null; then
    # install from binary
	SRC=""
	BIN="$INSTALL"
	DIR=`dirname "$BIN"`
    elif [ -d "$PREFIX/etc/openpkg" ]; then
    # upgrade
	SRC=""
	BIN=""
	DIR="$INSTALL"
    fi
}

prefix_openpkg_determine_action

DIR=`cd $DIR; pwd`

if [ -n "$SRC" ]; then
    echo "Creating binary openpkg package from $SRC!"
    [ -n "$ADDITIONAL_BUILD_OPTS" ] && \
        echo "Using additional options: $ADDITIONAL_BUILD_OPTS"
    sh "$SRC" \
        $ADDITIONAL_BUILD_OPTS \
        --prefix="$PREFIX" \
        --tag="$TAG" --user="$USER" --group="$USER" \
        --muid="$KID" --ruid="$R_KID" --nuid="$N_KID" \
        --mgid="$KID" --rgid="$R_KID" --ngid="$N_KID" \
        || exit $?
    if [ "$FLAG_BOOTSTRAP" ]; then
        echo "Created the OpenPKG bootstrap packages, they are available in"
        echo "$DIR"
        exit 0
    fi
fi

if [ -n "$BIN" ]; then
    sh "$BIN" || exit $?
    if [ "$FLAG_ENV" ]; then
        echo "Created the OpenPKG environment!"
        exit 0
    fi
fi

if [ -n "$DIR" ]; then
    [ -z "$PLATTAG" ] && PLATTAG=`"$PREFIX/bin/openpkg" rpm -q --qf="%{ARCH}-%{OS}" openpkg`-$TAG
    if [ -n "$KOLAB_VERSION" ]; then
        DEFINE="$DEFINE
            -Dkolabd::kolab_version=$KOLAB_VERSION
            -Dkolab-webadmin::kolab_version=$KOLAB_VERSION
        "
    fi

    PACKAGES=`remove_from_list "$EXCLUDEPKGS" "$PACKAGES"`

    find "$DIR" $FIND1 -name "*.$PLATTAG.rpm" -exec ln -sf '{}' "$PREFIX/RPM/PKG/" \;
    echo "----------- SETUP COMPLETED -----------"
    echo
    echo " Now running:"
    echo
    echo "   $PREFIX/bin/openpkg build -kKBuZ -r \"$DIR\" -p \"$PLATTAG\" $DEFINE $PACKAGES | sh"
    echo
    echo "---------------------------------------"
    "$PREFIX/bin/openpkg" build -kKBuZ -r "$DIR" -p "$PLATTAG" $DEFINE $PACKAGES | sh || exit $?
fi

exit 0

# vim:ai et sta sw=4 sts=4 tw=0:
