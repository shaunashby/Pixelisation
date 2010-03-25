#____________________________________________________________________ 
# File: Queue.pm
#____________________________________________________________________ 
#  
# Author: Shaun ASHBY <Shaun.Ashby@gmail.com>
# Update: 2010-03-25 10:32:37+0100
# Revision: $Id$ 
#
# Copyright: 2010 (C) Shaun ASHBY
#
#--------------------------------------------------------------------
package Task::Queue;
use strict;
use warnings;

use Task::Sandbox;

use constant MAX_POP => 10;

sub new() {
    my $proto = shift;
    my $class = ref($proto) || $proto;
    my $self = shift || {};
    bless($self,$class);
    $self->{QUEUE} = [];
    $self->{POPULATION} = 0;
    return $self;
}

sub push() {
    my $self = shift;
    my ($item) = @_;
    # Add an item first, then check the number of members. Once we hit the
    # maximum population, the creation of a new sandbox is triggered:
    if ($self->_membership() > MAX_POP) {
	# Create a sandbox for this queue and generate the merge trigger. The
	# queue will be flushed after this step, returning 
	my $sandbox = Task::Sandbox->new( $self->{QUEUE} );       
	# Add the item to the new queue:
	$self->{QUEUE} = [ $item ];
    } else {
	# Add item to the queue until queue membership reaches MAX_POP:
	push(@{$self->{QUEUE}},$item);
    }
}

sub _membership() {
    my $self = shift;
    return $#{$self->{QUEUE}};
}

1;
