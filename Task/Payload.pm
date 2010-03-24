#____________________________________________________________________ 
# File: Payload.pm
#____________________________________________________________________ 
#  
# Author: Shaun ASHBY <Shaun.Ashby@gmail.com>
# Update: 2010-03-24 19:43:37+0100
# Revision: $Id$ 
#
# Copyright: 2010 (C) Shaun ASHBY
#
#--------------------------------------------------------------------
package Task::Payload;

use strict;
use warnings;

sub new() {
    my $proto = shift;
    my $class = ref($proto) || $proto;
    my $self = shift;
    bless($self,$class);
    return $self;
}

sub dump() {
    my $self =shift;
#    0123 isgri compute-0-0:/state/partition1/survey/rev_3/genpixels/0123/pixels"
    my ($rev,$inst,$url) = ($self->{payload} =~ /^(\d\d\d\d) (.*?) (.*?)$/);
    printf(" * payload -- %04d %-s URL=%s\n",$rev,$inst,$url);
}

1;
