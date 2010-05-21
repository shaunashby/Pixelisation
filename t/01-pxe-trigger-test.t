#!/opt/local/bin/perl -T

use Test::More tests => 7;

use PX::Export::Trigger;

my $trig = PX::Export::Trigger->new( { path => 't/triggers/pxe.trigger', type => 'create' } );

ok(ref($trig) eq 'PX::Export::Trigger',"Instance creation OK.");
ok($trig->node eq "host","Node obtained from trigger file.");
ok($trig->url eq "host:/path/to/data","Host obtained from trigger file.");
ok($trig->source_path eq "/path/to/data","Host obtained from trigger file.");
ok($trig->revnum == 9999,"Rev num obtained from trigger file.");
ok($trig->instrument eq "testi","Instrument obtained from trigger file.");
ok($trig->path eq "t/triggers/pxe.trigger","Path to export input trigger file.");
