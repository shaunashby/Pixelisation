#!/bin/sh
#____________________________________________________________________ 
# File: create-merge-triggers.sh
#____________________________________________________________________ 
#  
# Author: Shaun ASHBY <Shaun.Ashby@gmail.com>
# Update: 2010-05-04 10:23:57+0200
# Revision: $Id$ 
#
# Copyright: 2010 (C) Shaun ASHBY
#
#--------------------------------------------------------------------
start_id=1

if [[ -z $PIX_EXPORT_HOME ]]; then
    echo "ERROR: PIX_EXPORT_HOME variable must be set."
    exit 1
fi

cat ~/all-triggers-for-merge.txt | while read rev instr url; do
    # Convert URL to path in PIX_EXPORT_HOME:
    uuid=`echo $url | awk -F"/" '{print $8}'`
    # Check that the data dir really does exist:
    if [[ -d $PIX_EXPORT_HOME/$uuid ]]; then
	echo "$start_id:$rev:$instr:$PIX_EXPORT_HOME/$uuid" > ${uuid}.trigger
	start_id=`expr $start_id + 1`
    else
	echo "WARNING: No data dir $uuid under $PIX_EXPORT_HOME"
    fi
done