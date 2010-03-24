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

use Getopt::Std;
our($opt_d);

# Parse opions:
getopts('d');

# Where we'll be scanning for triggers:
use constant TRIGGERDIR => $ENV{HOME}."/triggers";
use constant EXPORTDIR => $ENV{HOME}."/export";

# Configuration for Log::Log4perl:
my %logconf = (
    "log4perl.logger.PXExporter" => "INFO, PXExporterLogFile",
    "log4perl.appender.PXExporterLogFile" => "Log::Log4perl::Appender::File",
    "log4perl.appender.PXExporterLogFile.filename" => "./pxexport.log",
    "log4perl.appender.PXExporterLogFile.layout" => "Log::Log4perl::Layout::PatternLayout",
    "log4perl.appender.PXExporterLogFile.layout.ConversionPattern" => "[%d PID:%P %p] %m%n"
    );

# Init logging:
Log::Log4perl->init(\%logconf);

# Get the logger:
my $log = get_logger('PXExporter');

# Signal handlers set this to true if execution should stop:
my $shutdown = 0;

# If we want to run as a daemon:
if ($opt_d) {
    chdir '/'                 or $log->logdie("Can't chdir to /: $!");
    umask 0;

    # Handle signals:
    $SIG{'TERM'} = sub { $log->logwarn("TERM signal received...shutting down."); $shutdown = 1 };
    $SIG{'KILL'} = sub { $log->logwarn("KILL signal received...shutting down."); $shutdown = 1 };
    $SIG{'HUP'} = sub { return 'IGNORE' };
    $SIG{'PIPE'} = sub { return 'IGNORE' };

    # Close standard filehandles:
    open STDIN, '/dev/null'   or $log->logdie("Can't read /dev/null: $!");    
    open STDOUT, '>/dev/null' or $log->logdie("Can't write to /dev/null: $!");
    open STDERR, '>/dev/null' or $log->logdie("Can't write to /dev/null: $!");
    
    defined(my $pid = fork)   or $log->logdie("Can't fork: $!");

    exit if $pid;

    POSIX::setsid()           or $log->logdie("Can't start a new session: $!");
}

my $watcher = File::ChangeNotify->instantiate_watcher(
    directories => [ TRIGGERDIR ],
    filter      => qr/\.trigger$/,
    sleep_interval => 5,
    event_class => 'PXExport::Trigger'
    );

my $taskqueue = [];

# Run the event loop:
while ( (my @triggers = $watcher->wait_for_events()) && (!$shutdown) ) {
    map {
	$log->info("Trigger at path: ".$_->path());
	$log->info("--- type: ".$_->type());

	# Create payload:
	my $payload = Task::Payload->new({ payload => $_->payload });
	$payload->dump;
    } @triggers;

}

$log->warn("Shutting down.");

exit(0);
