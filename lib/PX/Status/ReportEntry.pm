#____________________________________________________________________ 
# File: ReportEntry.pm
#____________________________________________________________________ 
#  
# Author: Shaun ASHBY <Shaun.Ashby@gmail.com>
# Update: 2010-05-25 13:28:00+0200
# Revision: $Id$ 
#
# Copyright: 2010 (C) Shaun ASHBY
#
#--------------------------------------------------------------------
package PX::Status::ReportEntry;

use strict;
use warnings;

use Carp qw(croak);

use overload q{""} => \&display;

sub new() {
    my $proto = shift;
    my $class = ref($proto) || $proto;
    my $self = (@_ == 0) ?             # Error if no params given
	croak("No params given.\n")
	: (ref($_[0]) eq 'HASH') ? shift
	: croak("Needs a parameter hash ref");
    $self->{jobclass} ||= 'export';
    return bless($self,$class);
}

sub jobclass() { return shift->{jobclass}; }

sub revnum() { return shift->{revnum}; }

sub instrument() { return shift->{instrument}; }

sub display() {
    my $self = shift;
    return sprintf("%-04d  %-s ",$self->{revnum}, $self->{instrument});
}

1;

__END__
