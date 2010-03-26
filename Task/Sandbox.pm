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

use constant MERGE_TRIGGER_DIR => $ENV{PIX_HOME}."/merge/input/triggers";

use Carp qw(croak);

sub new() {
    my $proto = shift;
    my $class = ref($proto) || $proto;
    my $self = (@_ == 0) ?             # Error if no params given
	croak("No params given.\n")
	: {};
    
    # Store the queue:
    $self->{QUEUE} = (ref($_[0]) eq 'ARRAY') ? shift
	: croak("Needs queue array ref as parameter.");
    
    bless($self, $class);
    $main::logger->info("[Task::Sandbox]: Created with ID $self.");
    # Somewhere to store the paths to the exported data, ready for merging:
    $self->{EXPORT_TABLE} = [];
    return $self;
}

sub setup() {
    my $self = shift;
    $main::logger->info("[Task::Sandbox]: Doing setup. Exporting data....");
    map {
	# Ask the tasks to run their finalization steps:
	$_->finalize();
	# Store the export path: this is where the merge will read from (and will
	# be written to the trigger file):
	if ($_->status() == 0) {
	    push(@{$self->{EXPORT_TABLE}},$_->export_path());
	}	
    } @{$self->{QUEUE}};
}

sub create_trigger() {
    my $self = shift;
    # For the (unique) merge trigger name, re-use one of the UUIDs of the data directories:
    my $uuid = $self->{QUEUE}->[0]->uuid;
    my $trigger = MERGE_TRIGGER_DIR."/".$uuid.".trigger";
    $main::logger->info("[Task::Sandbox]: Writing trigger file for merge to $trigger");
    open(TRIGGER,"> $trigger");
    print TRIGGER join("\n",@{$self->{EXPORT_TABLE}});
    print TRIGGER "\n";
    close(TRIGGER);
}

1;
