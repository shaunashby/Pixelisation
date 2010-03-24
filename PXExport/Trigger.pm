package PXExport::Trigger;
use Moose;
use namespace::clean -except => 'meta';
use Path::Class::File;

extends 'File::ChangeNotify::Event';

has 'trigger_file' => (
    is => 'ro',
    isa => 'Path::Class::File',
    init_arg => undef,
    lazy_build => 1
    );

has 'payload' => (
    is => 'ro',
    isa => 'Str',
    init_arg => undef,
    lazy_build => 1
    );

## builders ##
sub _build_trigger_file() { return Path::Class::File->new( shift->{path} ) }

sub _build_payload() { return shift->trigger_file()->slurp  }

no Moose;

__PACKAGE__->meta()->make_immutable();

1;

__END__
