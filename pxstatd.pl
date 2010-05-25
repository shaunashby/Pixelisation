#!/usr/bin/perl 
#____________________________________________________________________ 
# File: pxstatd.pl
#____________________________________________________________________ 
#  
# Author: Shaun ASHBY <Shaun.Ashby@gmail.com>
# Update: 2010-05-25 12:43:23+0200
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

use Pixelisation::Config qw(:all);
use PX::Status::Trigger;

use Getopt::Std;

our($opt_d);

$| = 1;

# Parse opions:
getopts('d');

# Configuration for Log::Log4perl:
my %logconf = (
    "log4perl.logger.PXStatus" => "INFO, PXStatusLogFile",
    "log4perl.appender.PXStatusLogFile" => "Log::Log4perl::Appender::File",
    "log4perl.appender.PXStatusLogFile.filename" => "./pxstatd.log",
    "log4perl.appender.PXStatusLogFile.layout" => "Log::Log4perl::Layout::PatternLayout",
    "log4perl.appender.PXStatusLogFile.layout.ConversionPattern" => "[%d %p] %m%n"
    );

# Init logging:
Log::Log4perl->init(\%logconf);

# Get the logger:
our $logger = get_logger('PXStatus');

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

# Watcher to watch both export and merge triggers.COMPLETED directories:
my $watcher = File::ChangeNotify->instantiate_watcher(
    directories => [ PXE_COMPLETED_TRIGGER_DIR, PXM_COMPLETED_TRIGGER_DIR ],
    filter      => qr/\.trigger$/,
    sleep_interval => TRIGGER_CHECK_INTERVAL,
    event_class => 'PX::Status::Trigger'
    );

$logger->info(">>>>>>>> status daemon started. <<<<<<<<");

# Run the event loop:
while ( (my @triggers = $watcher->wait_for_events()) && (!$shutdown) ) {
    map {
	$logger->info("Received COMPLETE trigger: ".$_->path());
	if ($_->type() eq 'create') {
	    # Loop over all ReportEntry objects:
	    map {
		$logger->info($_);
	    } @{ $_->report_entries };	    
	} else {
	    $logger->info("Regenerating status information from trigger file.");
	}
    } @triggers;
}

$logger->warn("Shutting down.");

exit(0);
