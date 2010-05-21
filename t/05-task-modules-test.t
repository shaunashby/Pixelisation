#!/opt/local/bin/perl -T

use Test::More tests => 5;

use PX::Export::Trigger;

use Task::Payload;
use Task::Queue;
use Task::Queue::Item;

my $trig = PX::Export::Trigger->new( { path => 't/triggers/pxe.trigger', type => 'create' } );
my $task_payload = Task::Payload->new($trig);
my $task_queue = Task::Queue->new;
ok(ref($task_queue) eq "Task::Queue","Task::Queue instantiation OK.");
ok($task_queue->_membership == 0,"Task::Queue is empty.");

my $test_id = 1234;
my $task_queue_item = Task::Queue::Item->new($task_payload, $test_id);
ok(ref($task_queue_item) eq 'Task::Queue::Item',"Task::Queue::Item instantiation OK.");
ok($task_queue_item->id == 1234,"Checking ID of Task::Queue::Item.");
ok($task_queue_item->status == 9999,"Checking default status of Task::Queue::Item.");
