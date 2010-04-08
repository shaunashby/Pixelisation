use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'Pixelisation',
    AUTHOR              => 'Shaun Ashby <shaun.ashby@unige.ch>',
    VERSION_FROM        => 'lib/Pixelisation.pm',
    ABSTRACT_FROM       => 'lib/Pixelisation.pm',
    ($ExtUtils::MakeMaker::VERSION >= 6.3002
      ? ('LICENSE'=> 'perl')
      : ()),
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More' => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'Pixelisation-*' },
);
