#!/opt/local/bin/perl
#____________________________________________________________________ 
# File: generate-ldif.pl
#____________________________________________________________________ 
#  
# Author: Shaun ASHBY <Shaun.Ashby@gmail.com>
# Update: 2010-04-12 10:34:53+0200
# Revision: $Id$ 
#
# Copyright: 2010 (C) Shaun ASHBY
#
#--------------------------------------------------------------------
package Dataset;
use Moose;

has 'host' => (
    is => 'rw',
    isa => 'Str'
    );

has 'instrument' => (
    is => 'rw',
    isa => 'Str'
    );

has 'revnum' => (
    is => 'rw',
    isa => 'Int'
    );

has 'ldif' => (
    is => 'rw',
    isa => 'Str',
    lazy_build => 1
    );

sub _build_ldif() {
    my ($self) = shift;
    my $ldif = sprintf("dn: cn=%04d,ou=%s,ou=DataSources,dc=ashby,dc=isdc,dc=unige,dc=ch\n",$self->{revnum},$self->{host});
    $ldif .= sprintf("changetype: modify\n");
    $ldif .= sprintf("replace: dsStatus\n");
    $ldif .= sprintf("dsStatus: 0\n");
    return $ldif;
}

use strict;
use warnings;
use Path::Class::File;

# Scan the triggers to extract dataset info and generate
# an LDIF entry to update the LDAP database. Note that
# we scan the input trigger dir and not the completed triggers
# as we want all triggers, not just those which have been merged

# Where to find the triggers:
use constant DS_JOB_TRIGGER_DIR => $ENV{PIX_HOME}."/job/input/triggers";
use constant DS_JOB_COMPLETE => 0;

# Glob all triggers, read each one and  extract the node, revolution and instrument:
my (@triggers) = glob(DS_JOB_TRIGGER_DIR."/*.trigger");

foreach my $trigger (@triggers) {
    my $file = Path::Class::File->new( $trigger ) || die "$0: Unable to create File object from $trigger: $!\n";
    my $content = $file->slurp( chomp => 1 );
    
    if (my ($revnum,$instrument,$url) = ($content =~ /^(\d\d\d\d) (.*?) (.*?)$/)) {
	# Split the URL into node and path parts:
	my ($host,$sourcepath) = split(':',$url);
	my $dsentry = Dataset->new( { host => $host, revnum => $revnum, instrument => $instrument } );
	print $dsentry->ldif,"\n";
    }
}
