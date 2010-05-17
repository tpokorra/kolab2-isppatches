#!/bin/bash

# Script is a contribution from Stephan Buys <s.buys@codefusion.co.za>
# licened under the GPL
#
# This script retrieves the latest and greatest OpenPKG files that we
# are interested in...
#

# User environment variable if available
if [ "x$KOLABPKGURI" == "x" ]; then
	KOLABPKGURI="ftp://ftp.openpkg.org/current/SRC/"
fi

# First we retrieve all the latest file listing....
echo "Fetch new listing? (y/n)"
read answer

if [ "x$answer" = "xy" ]; then 
	wget -nr $KOLABPKGURI
fi

if [ -f "$PWD/index.html" ]; then 
	rm $PWD/index.html 
	echo index.html removed
fi

# Now we download all the appropriate files,
# this method should cut down the time needed to unnecesarilly retrieve
# the directory listing everytime... (usefull if you sit on 56K modem like me and get
# charged per second ;-)

# main caveat - this list needs to be maintained
# I have also assumed we use only OpenPKG current
if [ ! -f "$PWD/.listing" ]; then echo "Sorry no ".listing" file found, aborting..."; exit 1; fi


echo "Start download..."
for prog in make patch binutils gcc procmail zlib expat readline libiconv \
	perl perl-ldap perl-openpkg perl-ds perl-time perl-xml perl-term perl-crypto \
	perl-conv openssl perl-ssl perl-sys perl-util perl-mail perl-net \
	perl-www m4 bison flex pcre fsl gdbm db mm ncurses sed imap gettext \
	apache db imapd openldap postfix proftpd sasl openpkg libxml libxslt; do

    if [ "x$prog" = "xopenpkg" ]; then
      file="`grep openpkg- .listing | awk -F" +" '{print $9}' | grep sh`"
    else
      file="`grep \ $prog-[0-9] .listing | awk -F" +" '{print $9}'`"
    fi
    
    file=`echo $file | perl -e "@line = <>; foreach (@line) { chomp; s/\r//; print; }"`
    #file=`echo $file | sed -e "s/[\n\r]//"`
    filesize="`grep \ $file .listing | awk -F" +" '{print $5}'`"
    cmd="wget -c $KOLABPKGURI/$file"
    
    # Iterate through our filelist and retrieve the files
    if [ -f "$PWD/$file" ]; then 
      localsize="`ls -l | grep \ $file | awk -F" +" '{print $5}'`"
      # As we already have the index, avoid unnecesarry connections...
      # This will retrieve the rest of a file if the download has not completed yet
      if [ "x$filesize" != "x$localsize" ]; then
    	 echo "Resuming: $file"
	 $cmd
      fi
    else 
         # This will retrieve a file that does not exist locally.
    	 echo "Downloading: $file"
	 $cmd
    fi
done

#Fetch CVS packages
if [ "x$KOLABCVSDIR" != "x" ]; then
	test -d $KOLABCVSDIR || mkdir -p $KOLABCVSDIR
fi
packagelist="server/postfix server/proftpd server/sasl server/openldap server/imapd server/apache server/kolab server/db"
echo "Kolabcvsdir: $KOLABCVSDIR"
cd $KOLABCVSDIR
echo Checkout in: $PWD
if [ ! -d server/CVS ]; then
  export CVSROOT=:pserver:anonymous@intevation.de:/home/kroupware/jail/kolabrepository
  cvs co $packagelist
else
  echo "This folder contains a CVS repository. Proceed with cvs update? (y/n)"
  read ans
  if [ "x$ans" = "xy" ]; then 
    cvs up $packagelist
  fi
fi

echo "Download complete..."
