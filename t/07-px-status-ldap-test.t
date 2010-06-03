#!/opt/local/bin/perl -T

use Test::More tests => 10;

use PX::Status::Trigger;

# Test export trigger completed:
my $export_trig = PX::Status::Trigger->new( { path => 't/triggers/pxe.trigger', type => 'create' } );
my $merge_trig = PX::Status::Trigger->new( { path => 't/triggers/pxm.trigger', type => 'create' } );

can_ok($export_trig,'ldif');
can_ok($merge_trig,'ldif');

# Check the entries in the export trigger:
ok(ref($export_trig->ldif) eq 'PX::Status::LDAP::LDIF',"Export trigger object has LDIF attribute.");
my $eldif = $export_trig->ldif;

# Checkthe individual entries:
map {
    ok($_->cn eq 9999,"LDIF entry CN for export trigger is correct.");
    ok($_->keyword eq 'dsStatus',"LDIF entry keyword for export trigger is correct.");
    ok($_->value eq 0,"LDIF entry value for export trigger is correct.");
} @{ $eldif->entries };

# Check the entries in the merge trigger:
ok(ref($merge_trig->ldif) eq 'PX::Status::LDAP::LDIF',"Merge trigger object has LDIF attribute.");
my $mldif = $merge_trig->ldif;

# Checkthe individual entries:
map {
    ok($_->cn eq 9999,"LDIF entry CN for merge trigger is correct.");
    ok($_->keyword eq 'dsComplete',"LDIF entry keyword for merge trigger is correct.");
    ok($_->value eq 'TRUE',"LDIF value keyword for merge trigger is correct.");
} @{ $mldif->entries };
