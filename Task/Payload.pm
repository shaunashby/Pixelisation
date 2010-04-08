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

use Carp qw(croak);

use overload q{""} => \&to_string;

sub to_string() {
    my ($self) = @_;
    return sprintf("%04d:%s",$self->revnum(),$self->instrument());
}

sub new() {
    my $proto = shift;
    my $class = ref($proto) || $proto;
    my $self = (@_ == 0) ?             # Error if no params given
	croak("No params given.\n")
	: {};
    
    # We need the trigger object from which to extract the payload data:
    $self->{TRIGGER_OBJECT} = (ref($_[0]) eq 'PXExport::Trigger') ? shift
	: croak("Needs a trigger object as parameter (PXExport::Trigger object)");
    
    bless($self,$class);
    
    return $self;
}

sub node() { return shift->{TRIGGER_OBJECT}->node(); }
sub url() { return shift->{TRIGGER_OBJECT}->url(); }
sub source_path() { return shift->{TRIGGER_OBJECT}->source_path(); }
sub revnum() { return shift->{TRIGGER_OBJECT}->revnum(); }
sub instrument() { return shift->{TRIGGER_OBJECT}->instrument(); }
sub trigger_path() { return shift->{TRIGGER_OBJECT}->path(); }

1;
