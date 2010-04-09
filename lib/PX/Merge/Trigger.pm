package PX::Merge::Trigger;
use Moose;
use namespace::clean -except => 'meta';
use Path::Class::File;
use PX::Merge::Input;

extends 'File::ChangeNotify::Event';

has 'inputs' => (
    is => 'ro',
    isa => 'ArrayRef[PX::Merge:::Input]',
    default => sub { [] }
    );

sub BUILD() {
    my ($self, $options) = @_;
    # Decode path and extract information from the contents:
    if (exists($options->{path})) {
	my $file = Path::Class::File->new( $options->{path} ) || die __PACKAGE__.": Can't create File object for path. ".$!."\n";
	my $inputs = [];
	do {
	    # Strip out information from trigger file. We want the ID of the task, the rev. num.,
	    # instrument and the input directory. We store this in a PX::Merge::Input object:
	    my ($id,$revnum,$instrument,$path) = split(/:/,$_);
	    push(@$inputs, PX::Merge::Input->new(
		     {
			 id         => $id,
			 revnum     => $revnum,
			 instrument => $instrument,
			 path       => $path
		     }
		 ));
	} for $file->slurp( chomp => 1 );
	# Store the inputs:
	$self->{inputs} = $inputs;
    }
    return $self;
}

no Moose;

__PACKAGE__->meta()->make_immutable();

1;

__END__
