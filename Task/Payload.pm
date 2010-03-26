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

use constant NULL_URL => 'file:/dev/null';

use Carp qw(croak);

use overload q{""} => \&to_string;

sub to_string() {
    my ($self) = @_;
    return  sprintf("rev=%04d i=%s n=%s srcpth=%s",
		    $self->{REVNUM},
		    $self->{INSTRUMENT},
		    $self->{SOURCENODE},
		    $self->{SOURCEPATH});
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

    # Defaults for payload parameters:
    $self->{REVNUM} = 99999999;
    $self->{INSTRUMENT} = 'NONE';
    $self->{SOURCEURL} = NULL_URL;
    
    $self->{PAYLOAD} = $self->{TRIGGER_OBJECT}->payload;

    bless($self,$class);

    # Strip out information from payload:
    if (my ($rev,$inst,$url) = ($self->{PAYLOAD} =~ /^(\d\d\d\d) (.*?) (.*?)$/)) {
	$self->{REVNUM} = $rev;
	$self->{INSTRUMENT} = $inst;

	# Split the URL into node and path parts:
	my ($sourcenode,$sourcepath) = split(':',$url);
	$self->{SOURCENODE} = $sourcenode;
	$self->{SOURCEPATH} = $sourcepath;
	$self->{SOURCEURL} = $url;		
    }
    return $self;
}

sub instrument() {
    return shift->{INSTRUMENT};
}

sub revnum(){
    return shift->{REVNUM};
}



# FIXME: I'm sure most of this code should be pushed to the
# actual trigger class (Moose):
sub source_node() {
    return shift->{SOURCENODE};
}

sub source_url(){
    return shift->{SOURCEURL};
}

sub source_path() {
    return shift->{SOURCEPATH};
}

sub trigger_path() {
    return shift->{TRIGGER_OBJECT}->path;
}

1;
