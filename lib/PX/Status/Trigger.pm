#____________________________________________________________________ 
# File: Trigger.pm
#____________________________________________________________________ 
#  
# Author: Shaun ASHBY <Shaun.Ashby@gmail.com>
# Update: 2010-05-25 12:58:04+0200
# Revision: $Id$ 
#
# Copyright: 2010 (C) Shaun ASHBY
#
#--------------------------------------------------------------------
package PX::Status::Trigger;
use Moose;
use namespace::clean -except => 'meta';
use Path::Class::File;

extends 'File::ChangeNotify::Event';

use PX::Status::ReportEntry::Export;
use PX::Status::ReportEntry::Merge;

use PX::Status::LDAP::Entry;
use PX::Status::LDAP::LDIF;

use Carp qw(croak);

has 'report_entries' => (
    is => 'ro',
    isa => 'ArrayRef[PX::Status::ReportEntry]',
    default => sub { [] }
    );

has 'ldif' => (
    is => 'ro',
    isa => 'PX::Status::LDAP::LDIF',
    default => sub { return PX::Status::LDAP::LDIF->new({ entries => [] }) },
    );

sub BUILD() {
    my ($self, $options) = @_;
    # Decode path and extract information from the contents:
    if (exists($options->{path})) {
	my $file = Path::Class::File->new( $options->{path} ) || die __PACKAGE__.": Can't create File object for path. ".$!."\n";
	my $reports = [];
	my $ldif_entries = [];
	do {
	    my ($revnum,$inst,$url,$id,$path);
	    # Strip out information from export trigger file. For this trigger type we will report simply
	    # that the job has completed and the data has been succesfully copied locally:
	    if ( ($revnum,$inst,$url) = ($_ =~ /^(\d\d\d\d) (.*?) (.*?)$/)) {
		push(@$reports, PX::Status::ReportEntry::Export->new(
			 {
			     revnum => $revnum,
			     instrument => $inst
			 }
		     ));
		# Create LDIF entries. After successful export, job has completed so dsStatus is 0:
		push(@$ldif_entries, PX::Status::LDAP::Entry->new( { cn => $revnum,
								     ou => uc($inst),
								     keyword => 'dsStatus',
								     value => 0 } ) );
	    } elsif ( ($id,$revnum,$inst,$path) = ( $_ =~ /(.*?):(.*?):(.*?):(.*?)$/)) {
		push(@$reports, PX::Status::ReportEntry::Merge->new(
			 {
			     revnum => $revnum,
			     instrument => $inst,
			     jobclass => 'merge',
			     inputdir => $path
			 }
		     ));
		# Create LDIF entries. After completed merge, dsComplete is TRUE:
		push(@$ldif_entries, PX::Status::LDAP::Entry->new( { cn => $revnum,
								     ou => uc($inst),
								     keyword => 'dsComplete',
								     value => 'TRUE' } ) );		
	    } else {
		croak("Unknown trigger format for trigger ".$options->{ path });
	    }
	} for $file->slurp( chomp => 1 );
	# Store the reports:
	$self->{report_entries} = $reports;
	# The LDIF file contents is per trigger (i.e., whether it's for a merge trigger where there are multiple entries, or for
	# an export trigger when there is just one, we write out one LDIF):
	$self->{ldif} = PX::Status::LDAP::LDIF->new( { entries => $ldif_entries });
    }
    return $self;
}

no Moose;

__PACKAGE__->meta()->make_immutable();

1;

__END__
