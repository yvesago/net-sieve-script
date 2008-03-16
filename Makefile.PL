

use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME         => 'Net::Sieve::Script',
    VERSION_FROM => 'lib/Net/Sieve/Script.pm', # finds \$VERSION
    AUTHOR       => 'Yves Agostini (agostini@univ-metz.fr)',
    ABSTRACT     => 'Parse and write Sieve scripts',
    PREREQ_PM    => {
					 'Test::More' => 0.1,
                     'Class::Accessor::Fast' => 0.30,
                    },
);
