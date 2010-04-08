#!perl -T

use Test::More tests => 6;

BEGIN {
    	use_ok( 'Pixelisation' );
	use_ok( 'PX::Merge::Trigger' );
	use_ok( 'PX::Merge::Input' );
	use_ok( 'PX::Export::Trigger' );
	use_ok( 'Task::Queue' );
	use_ok( 'Task::Queue::Item' );
	use_ok( 'Task::Sandbox' );
	use_ok( 'Task::Payload' );
	use_ok( 'Task::Command::PixelMerge' );
}

diag( "Testing Pixelisation $Pixelisation::VERSION, Perl $], $^X" );
