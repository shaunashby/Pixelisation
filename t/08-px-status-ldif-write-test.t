#!/opt/local/bin/perl -T

use Test::More tests => 5;

use PX::Status::Trigger;
use Pixelisation::Config qw(:all);

# Test export trigger completed:
my $merge_trig = PX::Status::Trigger->new( { path => 't/triggers/pxm.trigger', type => 'create' } );

can_ok($merge_trig,'ldif');

# Check the entries in the merge trigger:
ok(ref($merge_trig->ldif) eq 'PX::Status::LDAP::LDIF',"Merge trigger object has LDIF attribute.");

my $mldif = $merge_trig->ldif;

# Checkthe individual entries:
map {
    ok($_->cn eq 9999,"LDIF entry CN for merge trigger is correct.");
    ok($_->keyword eq 'dsComplete',"LDIF entry keyword for merge trigger is correct.");
    ok($_->value eq 'TRUE',"LDIF value keyword for merge trigger is correct.");
} $mldif->entries->[0];

$mldif->write(PX_DEFAULT_LDAP_OUTPUT_DIR."/testme.ldif");
