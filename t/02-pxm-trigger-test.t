#!/opt/local/bin/perl -T

use Test::More tests => 5;

use PX::Merge::Trigger;

my $trig = PX::Merge::Trigger->new( { path => 't/triggers/pxm.trigger', type => 'create' } );

ok(ref($trig) eq 'PX::Merge::Trigger',"Instance creation OK.");
ok(ref($trig->inputs) eq "ARRAY","Input list is array ref.");

my $inputs = $trig->inputs;
ok($#$inputs == 0,"Input array has only one entry.");

my $only_input = $inputs->[0];
ok("$only_input" eq "ID0001:REV9999:testi","Format of storing input data is correct.");
ok($only_input->path eq "/path/to/data","Path to merge input data.");
