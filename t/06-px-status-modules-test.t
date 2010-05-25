#!/opt/local/bin/perl -T

use Test::More tests => 11;

use PX::Status::Trigger;

# Test export trigger completed:
my $export_trig = PX::Status::Trigger->new( { path => 't/triggers/pxe.trigger', type => 'create' } );
my $merge_trig = PX::Status::Trigger->new( { path => 't/triggers/pxm.trigger', type => 'create' } );

ok(ref($export_trig) eq 'PX::Status::Trigger',"Instantiation of export status trigger.");
ok(ref($merge_trig) eq 'PX::Status::Trigger',"Instantiation of merge status trigger.");

# Check ReportEntries:
ok(ref($export_trig->report_entries) eq "ARRAY","Export ReportEntries list is array ref.");
my $e_report = $export_trig->report_entries->[0];
ok(ref($e_report) eq 'PX::Status::ReportEntry::Export',"Export ReportEntry object type is correct.");

ok(ref($merge_trig->report_entries) eq "ARRAY","Merge ReportEntries list is array ref.");
my $m_report = $merge_trig->report_entries->[0];
ok(ref($m_report) eq 'PX::Status::ReportEntry::Merge',"Merge ReportEntry object type is correct.");

# Check that revnum and instrument are correct in the ReportEntry objects
ok($e_report->revnum == 9999,"Rev num obtained from export ReportEntry.");
ok($e_report->instrument eq "testi","Instrument obtained from export ReportEntry.");
ok($m_report->revnum == 9999,"Rev num obtained from merge ReportEntry.");
ok($m_report->instrument eq "testi","Instrument obtained from merge ReportEntry.");

# Extra info from Merge reports only (since we'll need the dir name to setup for cleaning after merge):
ok($m_report->inputdir eq "/path/to/data/A9E652E745804D608E583E710A548631","Path to merge input data.");
