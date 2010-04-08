package MooseX::Role::Cmd::Meta::Attribute::Trait::PIL;

use Moose::Role;
use Moose::Util::TypeConstraints;

with 'MooseX::Role::Cmd::Meta::Attribute::Trait';

# Provide accessors for additional features in the PIL command trait:
has 'cmdopt_separator' => (
    is => 'rw',
    isa => 'Str',
    predicate => 'has_cmdopt_separator',
    default => sub { '=' }
    );

no Moose::Role;

# Register the implementation shortcut:
package Moose::Meta::Attribute::Custom::Trait::CmdOptWithSeparator;
sub register_implementation { 'MooseX::Role::Cmd::Meta::Attribute::Trait::PIL' }

1;
