#!/opt/local/bin/perl
#____________________________________________________________________ 
# File: pxmergerd.pl
#____________________________________________________________________ 
#  
# Author: Shaun ASHBY <Shaun.Ashby@gmail.com>
# Update: 2010-03-26 13:14:10+0100
# Revision: $Id$ 
#
# Copyright: 2010 (C) Shaun ASHBY
#
#--------------------------------------------------------------------
use strict;
use warnings;
use POSIX;
use Log::Log4perl qw(get_logger :levels);
use File::ChangeNotify;

use PXMerge::Trigger;
use Getopt::Std;

our($opt_d);

$| = 1;

# Parse opions:
getopts('d');

# Where the daemon will run:
#use constant PIX_HOME => "/export/data2/pixels2/Pixelisation/pix";
use constant PIX_HOME => "/Users/ashby/Desktop/ISDC/pixelisation/Pixelisation/pix";

# Where we'll be scanning for triggers:
use constant MERGE_TRIGGER_DIR => PIX_HOME."/merge/input/triggers";

# Where the output pixels will be merged to:
use constant PIXEL_ARCHIVE_DIR => PIX_HOME."/archive";

# Configuration for Log::Log4perl:
my %logconf = (
    "log4perl.logger.PXMerger" => "INFO, PXMergerLogFile",
    "log4perl.appender.PXMergerLogFile" => "Log::Log4perl::Appender::File",
    "log4perl.appender.PXMergerLogFile.filename" => "./pxmerge.log",
    "log4perl.appender.PXMergerLogFile.layout" => "Log::Log4perl::Layout::PatternLayout",
    "log4perl.appender.PXMergerLogFile.layout.ConversionPattern" => "[%d %p] %m%n"
    );

# Init logging:
Log::Log4perl->init(\%logconf);

# Get the logger:
our $logger = get_logger('PXMerger');

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
    directories => [ MERGE_TRIGGER_DIR ],
    filter      => qr/\.trigger$/,
    sleep_interval => 20,
    event_class => 'PXMerge::Trigger'
    );

$logger->info("daemon started.");

# Run the event loop:
while ( (my @triggers = $watcher->wait_for_events()) && (!$shutdown) ) {
    map {
	$logger->debug("Trigger at path: ".$_->path());
	if ($_->type() eq 'create') {
	    map {
		$logger->info("Merge trigger input dir: ".$_);
	    } @{$_->inputs};
	} else {
	    $logger->info("--- got trigger of type: ".$_->type());
	}
    } @triggers;
}

$logger->warn("Shutting down.");

exit(0);
