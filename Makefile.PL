

use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME         => 'NET::Sieve::Script',
    VERSION_FROM => 'lib/NET/Sieve/Script.pm', # finds \$VERSION
    AUTHOR       => 'Yves Agostini (agostini@univ-metz.fr)',
    ABSTRACT     => 'Module abstract (<= 44 characters) goes here',
    PREREQ_PM    => {
                     'Test::Simple' => 0.44,
                    },
);