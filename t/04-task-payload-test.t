#!/opt/local/bin/perl -T

use Test::More tests => 7;

use PX::Export::Trigger;
use Task::Payload;

my $trig = PX::Export::Trigger->new( { path => 't/triggers/pxe.trigger', type => 'create' } );
my $payload = Task::Payload->new($trig);

ok(ref($payload) eq 'Task::Payload',"Instance creation OK.");
ok($payload->node eq "host","Node obtained from trigger payload.");
ok($payload->url eq "host:/path/to/data","Host obtained from trigger payload.");
ok($payload->source_path eq "/path/to/data","Host obtained from trigger payload.");
ok($payload->revnum == 9999,"Rev num obtained from trigger payload.");
ok($payload->instrument eq "testi","Instrument obtained from trigger payload.");
ok($payload->trigger_path eq "t/triggers/pxe.trigger","Path to export input trigger payload.");
