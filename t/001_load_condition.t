# -*- perl -*-

# t/001_load.t - check module loading and create testing directory

use Test::More tests => 11;
use strict;

use lib qw(lib);

BEGIN { use_ok( 'NET::Sieve::Script::Condition' ); }

my $bad_string = 'header :comparator "i;octet" :contains "i;octet" "Subject" "MAKE MONEY FAST"';

my @strings = (
'header :contains :comparator "i;octet" "Subject" "MAKE MONEY FAST"',
'header :contains "x-attached" [".exe",".bat",".js"]',
'not address :localpart :is "X-Delivered-To" ["address1", "address2", "address3"]',
'allof ( address :domain :is "X-Delivered-To" "mydomain.info", not address :localpart :is "X-Delivered-To" ["address1", "address2", "address3"] )',
'allof ( address :is "X-Delivered-To" "mydomain.info", not address :localpart :is "X-Delivered-To" ["address1", "address2", "address3"] )',
'header :contains ["from","cc"] "from-begin@begin.fr"',
'header :contains ["from","cc"] [ "from-begin@begin.fr", "sex.com newsletter"]',
'header :matches :comparator "i;ascii-casemap" "Subject" "^Output file listing from [a-z]*backup$"',
'size :over 1M'
);

isnt (NET::Sieve::Script::Condition->new($bad_string)->write,$bad_string,'bad string');

foreach my $string (@strings) {

    $string =~ s/","/", "/g;
    $string =~ s/\[\s+"/\["/g;
    $string =~ s/"\s+]/"\]/g;

    my $cond = NET::Sieve::Script::Condition->new($string);
    my $resp = $cond->write;

    $resp =~ s/[\n\r]//g;
    $resp =~ s/ +/ /g;
    $resp =~ s/^ +//;
    $resp =~ s/ +$//;

    is ($resp,$string,'test string');
};
