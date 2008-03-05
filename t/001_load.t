# -*- perl -*-

# t/001_load.t - check module loading and create testing directory

use Test::More tests => 2;
use lib qw(lib);

BEGIN { use_ok( 'NET::Sieve::Script' ); }

my $object = NET::Sieve::Script->new (name => "test");
isa_ok ($object, 'NET::Sieve::Script');


