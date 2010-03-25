#____________________________________________________________________ 
# File: Sandbox.pm
#____________________________________________________________________ 
#  
# Author: Shaun ASHBY <Shaun.Ashby@gmail.com>
# Update: 2010-03-25 14:30:32+0100
# Revision: $Id$ 
#
# Copyright: 2010 (C) Shaun ASHBY
#
#--------------------------------------------------------------------
package Task::Sandbox;

use strict;
use warnings;

use constant MERGE_TRIGGER_DIR => '@@MERGE_TRIGGER_DIR@@';

use Carp qw(croak confess);

sub new() {
    my $proto = shift;
    my $class = ref($proto) || $proto;
    my $self = (@_ == 0) ?             # Error if no params given
	croak("No params given.\n")
	: (ref($_[0]) eq 'HASH') ? $_[0] # Got hashref already - OK
	: { @_ };                        # Otherwise, store the params in a hash

    return bless($self, $class);
}

sub setup() {
    
}

sub trigger() {
    print "[Sandbox]: Writing trigger file for merge to ".MERGE_TRIGGER_DIR."\n";
}

sub flush_queue() {
    my $self = shift;
    # Call DESTROY for each of the Task::Queue::Item objects. This will
    # call some book-keeping routines and log 
    map { $_->DESTROY } @{$self->{QUEUE}};
    $self->{QUEUE} = [];
}


1;
