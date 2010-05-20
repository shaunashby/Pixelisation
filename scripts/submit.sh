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

ldapsearch -LLLL -H 'ldap://ashby.isdc.unige.ch' -x \
-b "ou=ISGRI,ou=Datasets,dc=ashby,dc=isdc,dc=unige,dc=ch" \
'(&(dsStatus=999))' cn | grep "^cn" | sed -e 's/cn: //g' | while read cn; do
ldapsearch -LLLL -H 'ldap://ashby.isdc.unige.ch' -x \
-b "ou=ISGRI,ou=Datasets,dc=ashby,dc=isdc,dc=unige,dc=ch" \
"(&(dsStatus=999)(cn=${cn}))" dsHost | grep dsHost | sed -e 's/dsHost: //g' | while read host; do
    echo "$cn $host"
done
done