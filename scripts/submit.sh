#!/bin/sh
#____________________________________________________________________ 
# File: submit.sh
#____________________________________________________________________ 
#  
# Author: Shaun ASHBY <Shaun.Ashby@gmail.com>
# Update: 2010-05-11 13:02:31+0200
# Revision: $Id$ 
#
# Copyright: 2010 (C) Shaun ASHBY
#
#--------------------------------------------------------------------

function write_ldif() {
    instrument=$1
    cn=$2
    status=$3
    dn="cn=${cn},ou=${instrument},ou=Datasets,dc=ashby,dc=isdc,dc=unige,dc=ch"
     ( echo "dn: $dn"
       echo "changetype: modify"
       echo "replace: dsStatus"
       echo "dsStatus: $status"
       echo "" ) >> $LDIF
}

GPXLOGDIR=/home/ashby/gpx/logs
JOBSCRIPT=/home/ashby/ISDC-scripts/scripts/genpixels.job.sh

instrument=$1
status=800 # For submitting

if [[ -z $instrument ]]; then
    echo "No instrument given."
    exit 1
fi

ldapsearch -LLLL -H 'ldap://ashby.isdc.unige.ch' -x \
    -b "ou=${instrument},ou=Datasets,dc=ashby,dc=isdc,dc=unige,dc=ch" \
    '(&(dsStatus=999))' cn | grep "^cn" | sed -e 's/cn: //g' | while read cn; do
    ldapsearch -LLLL -H 'ldap://ashby.isdc.unige.ch' -x \
	-b "ou=${instrument},ou=Datasets,dc=ashby,dc=isdc,dc=unige,dc=ch" \
	"(&(dsStatus=999)(cn=${cn}))" dsHost | grep dsHost | sed -e 's/dsHost: //g' | while read host; do
	
	LDIF=modify-operation-$$.ldif; [[ ! -f $LDIF ]] && touch $LDIF
	JOBSC=job-$$.sh; [[ ! -f $JOBSC ]] && touch $JOBSC
	
	GPXLOGDIR=/home/ashby/gpx/logs
	jobname=r${cn}-${instrument}-gpx
	
	echo qsub -N $jobname \
	    -o ${GPXLOGDIR}/${host}/out \
	    -e ${GPXLOGDIR}/${host}/err \
	    -q all.q@${host} $JOBSCRIPT $instrument $cn >> $JOBSC
	
	write_ldif $instrument $cn $status
	
    done
done
