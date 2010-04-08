#____________________________________________________________________ 
# File: PXMerge::Input.pm
#____________________________________________________________________ 
#  
# Author: Shaun ASHBY <Shaun.Ashby@gmail.com>
# Update: 2010-04-08 11:14:25+0200
# Revision: $Id$ 
#
# Copyright: 2010 (C) Shaun ASHBY
#
#--------------------------------------------------------------------
package PXMerge::Input;

use strict;
use warnings;

use overload q{""} => \&to_string;

sub new() {
    my $proto = shift;
    my $class = ref($proto) || $proto;
    my $self = (@_ == 0) ?             # Error if no params given
	croak("No params given.\n")
	: (ref($_[0]) eq 'HASH') ? shift
	: croak("Needs a parameter hash ref");
    return bless($self,$class);
}

sub path() { return shift->{path}; }

sub to_string() {
    my $self = shift;
    return sprintf("ID%04d:REV%04d:%s",$self->{id},$self->{revnum},$self->{instrument});
}

1;
