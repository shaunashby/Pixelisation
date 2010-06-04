#!/opt/local/bin/perl -T

use Test::More tests => 5;

use PX::Status::Trigger;
use Pixelisation::Config qw(:all);

# Test export trigger completed:
my $export_trig = PX::Status::Trigger->new( { path => 't/triggers/pxe.trigger', type => 'create' } );

can_ok($export_trig,'ldif');

# Check the entries in the export trigger:
ok(ref($export_trig->ldif) eq 'PX::Status::LDAP::LDIF',"Export trigger object has LDIF attribute.");

my $eldif = $export_trig->ldif;

# Checkthe individual entries:
map {
    ok($_->cn eq 9999,"LDIF entry CN for export trigger is correct.");
    ok($_->keyword eq 'dsStatus',"LDIF entry keyword for export trigger is correct.");
    ok($_->value eq 0,"LDIF entry value for export trigger is correct.");
} @{ $eldif->entries };

$eldif->write(PX_DEFAULT_LDAP_OUTPUT_DIR."/testex.ldif");
