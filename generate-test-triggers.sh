#!/bin/sh
#____________________________________________________________________ 
# File: generate-test-triggers.sh
#____________________________________________________________________ 
#  
# Author: Shaun ASHBY <Shaun.Ashby@gmail.com>
# Update: 2010-03-26 11:36:27+0100
# Revision: $Id$ 
#
# Copyright: 2010 (C) Shaun ASHBY
#
#--------------------------------------------------------------------
TRIGGER_PATH=./pix/job/input/triggers
REVNUM=$1

if [[ -z $REVNUM ]]; then
    echo "No revnum to generate trigger for...bye."
    exit 1
fi

UUID=`uuidgen`
INSTRUMENT=isgri
NODE=cluster
PATH=/share/pixels2/pixel_merge/data-/compute-0-2/${UUID}

echo "$REVNUM $INSTRUMENT $NODE:$PATH" >> $TRIGGER_PATH/${REVNUM}.trigger
#0124 isgri URL=compute-0-0:/state/partition1/survey/rev_3/genpixels/0124/pixels


