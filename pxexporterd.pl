#!/opt/local/bin/perl
#____________________________________________________________________ 
# File: pxexporterd.pl
#____________________________________________________________________ 
#  
# Author: Shaun ASHBY <Shaun.Ashby@gmail.com>
# Update: 2010-03-24 11:22:25+0100
# Revision: $Id$ 
#
# Copyright: 2010 (C) Shaun ASHBY
#
#--------------------------------------------------------------------
use strict;
use warnings;
use lib ".";

use POSIX;
use Log::Log4perl qw(get_logger :levels);

use File::ChangeNotify;

use PXExport::Trigger;

use Task::Payload;
use Task::Queue;
use Task::Queue::Item;

use Getopt::Std;
our($opt_d);

$| = 1;

# Parse opions:
getopts('d');

# Where the daemon will run:
use constant PIX_HOME => '/Users/ashby/Desktop/ISDC/POE-Pixelisation/pix';
# Where we'll be scanning for triggers:
use constant JOB_TRIGGER_DIR => PIX_HOME."/job/input/triggers";

# Configuration for Log::Log4perl:
my %logconf = (
    "log4perl.logger.PXExporter" => "INFO, PXExporterLogFile",
    "log4perl.appender.PXExporterLogFile" => "Log::Log4perl::Appender::File",
    "log4perl.appender.PXExporterLogFile.filename" => "./pxexport.log",
    "log4perl.appender.PXExporterLogFile.layout" => "Log::Log4perl::Layout::PatternLayout",
    "log4perl.appender.PXExporterLogFile.layout.ConversionPattern" => "[%d %p] %m%n"
    );

# Init logging:
Log::Log4perl->init(\%logconf);

# Get the logger:
our $logger = get_logger('PXExporter');

# Signal handlers set this to true if execution should stop:
my $shutdown = 0;

# If we want to run as a daemon:
if ($opt_d) {
    chdir PIX_HOME                 or $logger->logdie("Can't chdir to ".PIX_HOME.": $!");
    umask 0;

    # Handle signals:
    $SIG{'TERM'} = sub { $logger->logwarn("TERM signal received...shutting down."); $shutdown = 1 };
    $SIG{'KILL'} = sub { $logger->logwarn("KILL signal received...shutting down."); $shutdown = 1 };
    $SIG{'HUP'} = sub { return 'IGNORE' };
    $SIG{'PIPE'} = sub { return 'IGNORE' };

    # Close standard filehandles:
    open STDIN, '/dev/null'   or $logger->logdie("Can't read /dev/null: $!");
    open STDOUT, '>/dev/null' or $logger->logdie("Can't write to /dev/null: $!");
    open STDERR, '>/dev/null' or $logger->logdie("Can't write to /dev/null: $!");
    
    defined(my $pid = fork)   or $logger->logdie("Can't fork: $!");

    exit if $pid;

    POSIX::setsid()           or $logger->logdie("Can't start a new session: $!");
}

my $watcher = File::ChangeNotify->instantiate_watcher(
    directories => [ JOB_TRIGGER_DIR ],
    filter      => qr/\.trigger$/,
    sleep_interval => 20,
    event_class => 'PXExport::Trigger'
    );

# The queue holds a list of Task::Queue::Items (these are worker objects which
# are run sequentially, each handling the copy of one revolution of data to
# a processing sandbox):
my $queue = Task::Queue->new;
my $id = 1;
$logger->info("daemon started.");

# Run the event loop:
while ( (my @triggers = $watcher->wait_for_events()) && (!$shutdown) ) {
    map {
	$logger->debug("Trigger at path: ".$_->path());
	if ($_->type() eq 'create') {
	    # Create payload. Pass in the trigger object:
	    my $payload = Task::Payload->new( $_ );
	    # Create the task for this payload and pass in the ID:
	    my $task = Task::Queue::Item->new( $payload, $id );
	    # Run the copy task:
	    $task->run();	
	    # Add the task to the queue:
	    $queue->push( $task );
	    $id++;
	} else {
	    $logger->info("--- got trigger of type: ".$_->type());
	}
    } @triggers;
}

$logger->info("Processed $id triggers");
$logger->warn("Shutting down.");

exit(0);
