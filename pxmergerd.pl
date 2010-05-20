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

use File::Copy qw(cp);

use Pixelisation::Config qw(:all);

use PX::Merge::Trigger;
use Task::Command::PixelMerge;

use Getopt::Std;

our($opt_d);

$| = 1;

# Parse opions:
getopts('d');

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
    directories => [ PXM_TRIGGER_DIR ],
    filter      => qr/\.trigger$/,
    sleep_interval => TRIGGER_CHECK_INTERVAL,
    event_class => 'PX::Merge::Trigger'
    );

$logger->info(">>>>>>>> daemon started. <<<<<<<<");

# Run the event loop:
while ( (my @triggers = $watcher->wait_for_events()) && (!$shutdown) ) {
    map {
	$logger->debug("Received trigger: ".$_->path());
	if ($_->type() eq 'create') {
	    # Track overall merge status so that we can decide where to copy
	    # processed trigger file at the end of the task: if any merge fails,
	    # the trigger file will be copied to FAIL_TRIGGER_DIR:
	    my $merge_status = 0;
	    # Iterate over input directories:
	    map {
		$logger->info("Bookkeeping: ".$_);
		$logger->info("Going to merge from ".$_->path);
		# Run the pixel_merge command:
		my $merge_cmd = Task::Command::PixelMerge->new(
		    'Input' => $_->path,
		    'Output' => PIXEL_ARCHIVE_DIR
		    );

		$merge_cmd->run;

		# Check the return status:
		if ($merge_cmd->status) {
		    $logger->warn("Task::Command::PixelMerge exited with status ".$merge_cmd->status);
		    map {
			chomp;
			$logger->warn("T::C::PM::STDERR > ".$_);
		    } @{ $merge_cmd->stderr };
		    $merge_status = 1;
		} else {
		    $logger->info("Merge complete for ".$_);
		}
	    } @{$_->inputs};
	    # Check merge status.
	    # Copy to completed triggers dir if status OK, otherwise copy to failed triggers dir:
	    if ($merge_status) {
		$logger->warn("Copying ".$_->path()." to triggers.FAILED");
	    	cp($_->path(), PXM_FAILED_TRIGGER_DIR );
	    } else {
		$logger->info("Copying ".$_->path()." to triggers.COMPLETED");
		cp($_->path(), PXM_COMPLETED_TRIGGER_DIR );
	    }
	} else {
	    $logger->info("--- got trigger of type: ".$_->type());
	}
    } @triggers;
}

$logger->warn("Shutting down.");

exit(0);
