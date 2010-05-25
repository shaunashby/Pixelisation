#____________________________________________________________________ 
# File: Merge.pm
#____________________________________________________________________ 
#  
# Author: Shaun ASHBY <Shaun.Ashby@gmail.com>
# Update: 2010-05-25 15:34:46+0200
# Revision: $Id$ 
#
# Copyright: 2010 (C) Shaun ASHBY
#
#--------------------------------------------------------------------
package PX::Status::ReportEntry::Merge;

use strict;
use warnings;

use PX::Status::ReportEntry;
use base 'PX::Status::ReportEntry';

sub new() {
    my $proto = shift;
    my $class = ref($proto) || $proto;
    my $self = $class->SUPER::new(shift);
    bless($self, $class);
    return $self;
}

sub inputdir() { return shift->{inputdir}; }

1;

__END__
