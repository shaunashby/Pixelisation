package PXMerge::Trigger;
use Moose;
use namespace::clean -except => 'meta';
use Path::Class::File;

extends 'File::ChangeNotify::Event';

has 'inputs' => (
    is => 'ro',
    isa => 'ArrayRef',
    default => sub { [] }
    );

sub BUILD() {
    my ($self, $options) = @_;
    # Decode path and extract information from the contents:
    if (exists($options->{path})) {
	my $file = Path::Class::File->new( $options->{path} ) || die __PACKAGE__.": Can't create File object for path. ".$!."\n";
	my $inputs = [];
	do {
	    # Strip out information from trigger file. Start with just the
	    # list of input directories which contain the pixel data to
	    # be merged:
	    push(@$inputs,$_);
# 	    if (my ($rev,$inst,$url) = ($_ =~ /^(\d\d\d\d) (.*?) (.*?)$/)) {
# 		# Split the URL into node and path parts:
# 		my ($node,$sourcepath) = split(':',$url);
# 		$self->{node} = $node;
# 		$self->{url} = $url;
# 		$self->{source_path} = $sourcepath;
# 		$self->{revnum} = $rev;
# 		$self->{instrument} = $inst;
# 	    }
	    
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
