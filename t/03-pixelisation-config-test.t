#!/opt/local/bin/perl -T

use Test::More tests => 16;

BEGIN {
	use_ok( 'Pixelisation::Config' );
}

use Pixelisation::Config qw(:all);

diag( "Testing Pixelisation Config $Pixelisation::Config::VERSION, Perl $], $^X" );

ok( (PIX_HOME =~ m|Pixelisation/pix|) == 1,"Check constant PIX_HOME");
ok( (TRIGGER_CHECK_INTERVAL =~ /30/) == 1,"Check constant TRIGGER_CHECK_INTERVAL");
ok( (MAX_POPULATION =~ /2/) == 1,"Check constant MAX_POPULATION");
ok( (PXE_STAGING_DIR =~ /staging/) == 1,"Check constant PXE_STAGING_DIR");
ok( (PXE_EXPORT_DIR =~ /export/) == 1,"Check constant PXE_EXPORT_DIR");
ok( (PXE_TRIGGER_DIR =~ /triggers/) == 1,"Check constant PXE_TRIGGER_DIR");
ok( (PXE_COMPLETED_TRIGGER_DIR =~ /triggers.COMPLETED/) == 1,"Check constant PXE_COMPLETED_TRIGGER_DIR ");
ok( (PXE_FAILED_TRIGGER_DIR =~ /triggers.FAILED/) == 1,"Check constant PXE_FAILED_TRIGGER_DIR");
ok( (PXM_TRIGGER_DIR =~ /triggers/) == 1,"Check constant PXM_TRIGGER_DIR");
ok( (PXM_COMPLETED_TRIGGER_DIR =~ /triggers.COMPLETED/) == 1,"Check constant PXM_COMPLETED_TRIGGER_DIR");
ok( (PXM_FAILED_TRIGGER_DIR =~ /triggers.FAILED/) == 1,"Check constant PXM_FAILED_TRIGGER_DIR");
ok( (PIXEL_MERGE_EXE =~ /pixel_merge/) == 1,"Check constant PIXEL_MERGE_EXE");
ok( (PFILES =~ /pfiles/) == 1,"Check constant PFILES");
ok( (COMMONLOGFILE =~ /common/) == 1,"Check constant COMMONLOGFILE");
ok( (PIXEL_ARCHIVE_DIR =~ /archive/) == 1,"Check constant PIXEL_ARCHIVE_DIR");
