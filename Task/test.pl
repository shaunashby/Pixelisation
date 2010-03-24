#!/opt/local/bin/perl
#____________________________________________________________________ 
# File: test.pl
#____________________________________________________________________ 
#  
# Author: Shaun ASHBY <Shaun.Ashby@gmail.com>
# Update: 2010-03-24 19:55:46+0100
# Revision: $Id$ 
#
# Copyright: 2010 (C) Shaun ASHBY
#
#--------------------------------------------------------------------
use lib "/Users/ashby/Desktop/ISDC/POE-Pixelisation";

use strict;
use warnings;

use Task::Payload;


my $pl = Task::Payload->new({ payload => "0123 isgri compute-0-0:/state/partition1/survey/rev_3/genpixels/0123/pixels" });


$pl->dump;
