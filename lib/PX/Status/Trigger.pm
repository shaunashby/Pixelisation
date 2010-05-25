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

use Carp qw(croak);

has 'report_entries' => (
    is => 'ro',
    isa => 'ArrayRef[PX::Status::ReportEntry]',
    default => sub { [] }
    );

sub BUILD() {
    my ($self, $options) = @_;
    # Decode path and extract information from the contents:
    if (exists($options->{path})) {
	my $file = Path::Class::File->new( $options->{path} ) || die __PACKAGE__.": Can't create File object for path. ".$!."\n";
	my $reports = [];
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
	    } elsif ( ($id,$revnum,$inst,$path) = ( $_ =~ /(.*?):(.*?):(.*?):(.*?)$/)) {
		push(@$reports, PX::Status::ReportEntry::Merge->new(
			 {
			     revnum => $revnum,
			     instrument => $inst,
			     jobclass => 'merge',
			     inputdir => $path
			 }
		     ));
	    } else {
		croak("Unknown trigger format for trigger ".$options->{ path });
	    }
	} for $file->slurp( chomp => 1 );
	# Store the reports:
	$self->{report_entries} = $reports;
    }
    return $self;
}

no Moose;

__PACKAGE__->meta()->make_immutable();

1;

__END__
