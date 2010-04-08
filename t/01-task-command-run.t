#!/opt/local/bin/perl
use lib ".";

use strict;
use warnings;

use Task::Command::PixelMerge;

my $cmd = Task::Command::PixelMerge->new(
    'Input' => "./Pixelisation/pix/export/71AD0CF4-7F94-4B88-81DB-E915A0F31132",
    'Output' => "./Pixelisation/pix/archive"
    );

$cmd->run;

if ($cmd->status) {
    map {
	chomp;
	print "YYY->".$_."\n";
    } @{$cmd->stderr};
} else {
    print "ARGS: ".join(" ",$cmd->cmd_args())."\n";

    if (grep($_ =~ /.*?: Merging of all pixel files is successfully finished/, @{$cmd->stdout})) {
	print "OK - command was 100% successful.\n";
    }
}
