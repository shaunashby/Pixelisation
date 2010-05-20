#!perl -T

use Test::More tests => 15;

BEGIN {
	use_ok( 'Pixelisation::Config qw(:all)' );
}

diag( "Testing Pixelisation Config $Pixelisation::Config::VERSION, Perl $], $^X" );

ok(PIX_HOME =~ /Pixelisation/);
ok(TRIGGER_CHECK_INTERVAL == 300);
ok(MAX_POPULATION == 10);
ok(PXE_STAGING_DIR =~ /staging/);
ok(PXE_EXPORT_DIR =~ /export/);
ok(PXE_TRIGGER_DIR =~ /triggers/);
ok(PXE_COMPLETED_TRIGGER_DIR =~ /triggers.COMPLETED/);
ok(PXE_FAILED_TRIGGER_DIR =~ /triggers.FAILED/);
ok(PXM_TRIGGER_DIR =~ /triggers/);
ok(PXM_COMPLETED_TRIGGER_DIR =~ /triggers.COMPLETED/);
ok(PXM_FAILED_TRIGGER_DIR =~ /triggers.FAILED/);
ok(PIXEL_MERGE_EXE =~ /pixel_merge/);
ok(PFILES =~ /pfiles/);
ok(COMMONLOGFILE =~ /common/);
ok(PIXEL_ARCHIVE_DIR =~ /archive/);
