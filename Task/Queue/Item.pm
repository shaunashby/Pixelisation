#____________________________________________________________________ 
# File: Item.pm
#____________________________________________________________________ 
#  
# Author: Shaun ASHBY <Shaun.Ashby@gmail.com>
# Update: 2010-03-25 16:50:46+0100
# Revision: $Id$ 
#
# Copyright: 2010 (C) Shaun ASHBY
#
#--------------------------------------------------------------------
package Task::Queue::Item;

use strict;
use warnings;

use constant STAGING_DIR       => $ENV{PIX_HOME}."/staging";
use constant EXPORT_DIR        => $ENV{PIX_HOME}."/export";

use File::Copy qw(mv);
use File::Basename qw(fileparse);

use Carp qw(croak);

sub new() {
    my $proto = shift;
    my $class = ref($proto) || $proto;
    my $self = (@_ == 0) ?             # Error if no params given
	croak("No params given.\n")
	: {};

    $self->{PAYLOAD_OBJECT} = (ref($_[0]) eq 'Task::Payload') ? shift
	: croak("Needs a payload object as parameter (Task::Payload object)");

    # Set status to v high number. This will be set to 0 on succesful completion:
    $self->{STATUS} = 9999;
    
    return bless($self, $class);
}

sub run() {
    my $self = shift;
    $main::logger->info("[Task::Queue::Item]: Got payload ".$self->{PAYLOAD_OBJECT});
    $main::logger->info("[Task::Queue::Item]: Running task for ".$self->{PAYLOAD_OBJECT}->trigger_path());

    # Copy from the remote source to a local directory. We just use the URL as it is so that
    # we end up with a directory with a UUID under the staging area:    
    $self->{SOURCE_PATH} = $self->{PAYLOAD_OBJECT}->source_path;
    $self->{SOURCE_URL}  = $self->{PAYLOAD_OBJECT}->source_url; # includes node name

    # Strip off the top directory (a UUID):
    $self->{DEST_SUBDIR} = [ reverse ( split("/",$self->{SOURCE_PATH} ) ) ]->[0];
    $self->{DEST_UUID} = $self->{DEST_SUBDIR};

    # Set the export path:
    $self->{EXPORT_PATH} = EXPORT_DIR."/".$self->{DEST_SUBDIR};
    # Where data will be staged to:
    $self->{STAGING_PATH} = STAGING_DIR."/".$self->{DEST_SUBDIR};

    $main::logger->info(sprintf("[Task::Queue::Item]: Staging data from %s",$self->{SOURCE_URL}));
    $main::logger->info(sprintf("[Task::Queue::Item]: Staging data to %s",$self->{STAGING_PATH}));

    # FIXME: tmp path for the copy
    $self->{TMP_SOURCE_URL} = 'isdclogin2:/unsaved_data/ashby/8b3db1e5-dbff-4ca5-bf87-bbd9f72759da';
    open(RSYNC,"rsync -auv -e ssh ".$self->{TMP_SOURCE_URL}." ".STAGING_DIR."|");
    while(<RSYNC>) {
	if (my ($size,$speed) = ( $_ =~ /.*? received (.*?) bytes \s*(.*?) bytes\/sec$/ )) {
	    $main::logger->info(sprintf("[RSYNC] SIZE %s    SPEED %s",$size,$speed));
	}
	$main::logger->info(sprintf("[RSYNC] %s",$_));
    }
    close(RSYNC);
      
    
    # TEMP: Just create an empty directory to check moving etc.:
    use File::Path;
    mkpath($self->{STAGING_PATH});
}

sub staging_path() {
    return shift->{STAGING_PATH};
}

sub export_path() {
    return shift->{EXPORT_PATH};
}

sub status() {
    return shift->{STATUS};
}

sub uuid() {
    my $self = shift;
    $self->{DEST_UUID} =~ s/-//g;
    return $self->{DEST_UUID};
}

sub finalize() {
    my $self = shift;
    $main::logger->info("[Task::Queue::Item]: finalize called for $self");
    # Rename to indicate completion:
    mv($self->{PAYLOAD_OBJECT}->trigger_path(),$self->{PAYLOAD_OBJECT}->trigger_path().".done");
    # Export the data to the export area:
    $self->_export();
}

sub _export() {
    my $self = shift;
    $main::logger->info(sprintf("[Task::Queue::Item]: Exporting data to %s",EXPORT_DIR));
    if ( -d $self->{STAGING_PATH} ) {
	mv($self->{STAGING_PATH},$self->{EXPORT_PATH});
	$self->{STATUS} = 0; # Gooood
    } else {
	$main::logger->info(sprintf("[Task::Queue::Item]: Skipping export (non-existent path: %s)",
				    $self->{STAGING_PATH}));
	$self->{STATUS} = 10; # Baaad man
    }
}

1;
