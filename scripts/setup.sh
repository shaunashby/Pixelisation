#!/bin/sh
#____________________________________________________________________ 
# File: setup.sh
#____________________________________________________________________ 
#  
# Author: Shaun ASHBY <Shaun.Ashby@gmail.com>
# Update: 2010-06-04 12:13:10+0200
# Revision: $Id$ 
#
# Copyright: 2010 (C) Shaun ASHBY
#
#--------------------------------------------------------------------

if [[ -n $PIX_BASE ]]; then
    if [[ -d $PIX_BASE/lib ]]; then
	VERSION=`perl -Ilib -MPixelisation -e 'print $Pixelisation::VERSION'`
	echo "Setting up directory structure for Pixelisation Toolkit version ${VERSION}"
	if [[ -f $PIX_BASE/lib/Pixelisation/Config.pm ]]; then
	    echo "Reading configuration from Pixelisation/Config.pm:"
	    echo
	    perl -Ilib -MPixelisation::Config -e '
use Pixelisation::Config qw(:all);
for my $TAG (@{ $Pixelisation::Config::EXPORT_TAGS{all} }) {
    print "$TAG ";
    print eval "$TAG";
    print "\n";
}
' | while read var value; do
		case $var in
		    # Check PIX_HOME. PIX_HOME should be the same as PIX_BASE/pix:
		    PIX_HOME)
			if [[ "${value}" != "${PIX_BASE}/pix" ]]; then
			    echo "** WARNING: PIX_HOME does not match PIX_BASE."
			    echo "            PIX_HOME has value $value."
			    echo "            PIX_BASE has value ${PIX_BASE}"
			    echo
			fi
			;;
		    TRIGGER_CHECK_INTERVAL)
			echo "Triggers will be checked every $value seconds."
			echo
			;;
		    PIXEL_MERGE_EXE)
			echo
			echo "Executable for pixel_merge: $value"
			if [[ ! -e $value ]]; then
			    echo "** WARNING: pixel_merge executable $value does not exist."
			fi
			echo
			;;
		    PFILES)
			echo "PAR files location: $value"
			if [[ ! -d $value ]]; then
			    echo "** WARNING: PAR files location $value does not exist."
			fi
			echo
			;;
		    # If it looks like a directory, create it:
		    *_DIR)
			if [[ ! -d $value ]]; then
			    echo "Creating directory $value"
			    mkdir -p $value
			fi
			;;
		    *)
			echo 
			echo "$var: $value"
			echo
			;;
		esac
	    done
	else
	    echo "ERROR: Pixelisation/Config.pm does not exist. Did you run "
	    echo ""
	    echo " perl Makefile.PL"	
	    echo " make"
	    echo " make test"
	    echo ""
	    echo "first?"
	    echo
	    exit 1
	fi
    else
	echo "ERROR: Can't find Pixelisation module dir (lib) under $PIX_BASE."
	exit 1
    fi
else 
    echo "ERROR: PIX_BASE is not set - should be set to the directory where Makefile.PL lives."
    exit 1
fi
