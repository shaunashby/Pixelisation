package PX::Export::Trigger;
use Moose;
use namespace::clean -except => 'meta';
use Path::Class::File;

use constant NULL_URL => 'file:/dev/null';

extends 'File::ChangeNotify::Event';

has 'node' => (
    is => 'ro',
    isa => 'Str',
    init_arg => undef
    );

has 'url' => (
    is => 'ro',
    isa => 'Str',
    default => sub { NULL_URL },
    init_arg => undef
    );

has 'source_path' => (
    is => 'ro',
    isa => 'Str',
    init_arg => undef
    );

has 'revnum' => (
    is => 'ro',
    isa => 'Int',
    default => sub { 999999 },
    init_arg => undef
    );

has 'instrument' => (
    is => 'ro',
    isa => 'Str',
    default => sub { 'NONE' },
    init_arg => undef
    );

sub BUILD() {
    my ($self, $options) = @_;
    # Decode path and extract information from the contents:
    if (exists($options->{path})) {
	my $file = Path::Class::File->new( $options->{path} ) || die __PACKAGE__.": Can't create File object for path. ".$!."\n";
	do {
	    # Strip out information from payload:
	    if (my ($rev,$inst,$url) = ($_ =~ /^(\d\d\d\d) (.*?) (.*?)$/)) {
		# Split the URL into node and path parts:
		my ($node,$sourcepath) = split(':',$url);
		$self->{node} = $node;
		$self->{url} = $url;
		$self->{source_path} = $sourcepath;
		$self->{revnum} = $rev;
		$self->{instrument} = $inst;
	    }
	} for $file->slurp( chomp => 1 );
    }
    return $self;
}

no Moose;

__PACKAGE__->meta()->make_immutable();

1;

__END__
