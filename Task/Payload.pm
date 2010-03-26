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

use constant NULL_URL => 'file:///dev/null';

sub new() {
    my $proto = shift;
    my $class = ref($proto) || $proto;
    my $self = (@_ == 0) ?             # Error if no params given
	croak("No params given.\n")
	: (ref($_[0]) eq 'HASH') ? $_[0] # Got hashref already - OK
	: { @_ };                        # Otherwise, store the params in a hash
    # Defaults for payload parameters:
    $self->{REVNUM} = 99999999;
    $self->{INSTRUMENT} = undef;
    $self->{URL} = NULL_URL;

    bless($self,$class);
    # Strip out information from payload:
    if (my ($rev,$inst,$url) = ($self->{payload} =~ /^(\d\d\d\d) (.*?) (.*?)$/)) {
	$self->{REVNUM} = $rev;
	$self->{INSTRUMENT} = $inst;
	$self->{URL} = $url;
    } 
    
    return $self;
}

sub instrument() {
    return shift->{INSTRUMENT};
}

sub revnum(){
    return shift->{REVNUM};
}

sub url(){
    return shift->{URL};
}

sub dump() {
    my $self = shift;
    printf(" * payload -- %04d %-s URL=%s\n",
	   $self->{REVNUM},
	   $self->{INSTRUMENT},
	   $self->{URL});
}

1;
