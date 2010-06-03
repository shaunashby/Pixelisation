#____________________________________________________________________ 
# File: Entry.pm
#____________________________________________________________________ 
#  
# Author: Shaun ASHBY <Shaun.Ashby@gmail.com>
# Update: 2010-06-03 13:52:31+0200
# Revision: $Id$ 
#
# Copyright: 2010 (C) Shaun ASHBY
#
#--------------------------------------------------------------------
package PX::Status::LDAP::Entry;

use strict;
use warnings;

use Carp qw(croak);

sub new() {
    my $proto = shift;
    my $class = ref($proto) || $proto;
    my $self = (@_ == 0) ?             # Error if no params given
	croak("No params given.\n")
	: (ref($_[0]) eq 'HASH') ? shift
	: croak("Needs a parameter hash ref (cn,ou,keyword,value).");

    map {
	croak("Entry requires $_ in input."), unless (exists($self->{$_}));
    } qw(cn ou keyword value);

    return bless($self,$class);
}

sub cn() { return shift->{cn}; }

sub ou() { return shift->{ou}; }

sub keyword() { return shift->{keyword}; }

sub value() { return shift->{value}; }

1;
