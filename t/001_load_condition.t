# -*- perl -*-

# t/001_load.t - check module loading and create testing directory

use Test::More tests => 1;
use strict;

use lib qw(lib);

BEGIN { use_ok( 'NET::Sieve::Script::Condition' ); }

#my $string = 'header :contains :comparator "i;octet" "Subject" "MAKE MONEY FAST"';
my @strings = (
'header :contains :comparator "i;octet" "Subject" "MAKE MONEY FAST"',
'header :contains "x-attached" [".exe",".bat",".js"]',
'not address :localpart :is "X-Delivered-To" ["address1", "address2", "address3"]',
'allof ( address :domain :is "X-Delivered-To" "mydomain.info", not address :localpart :is "X-Delivered-To" ["address1", "address2", "address3"])',
'header :contains ["from","cc"] "from-begin@begin.fr"',
'header :contains ["from","cc"] [ "from-begin@begin.fr", "sex.com newsletter"]',
);

my $s='"mydomain.info", not address :localpart :is ["from","cc"] ["address1", "address2", "address3"], mydomain.info"';

#$s=~s/",\s?"/" "/g;
$_=$s;
#substr($_,index$_,'[')=~y/,//d;
1 while s/(\[[^\]]+?)",\s*/$1" /;
print $_."\n";
#exit ;
#use Data::Dumper;

foreach my $string (@strings) {
    print "\n=>".$string."\n";
    my $cond = NET::Sieve::Script::Condition->new($string);

    print $cond->not.' '.$cond->test."\n";

    if (defined $cond->condition() ) {
        foreach my $sub_cond (@{$cond->condition()}) {
            print $sub_cond->not.' '.$sub_cond->test."\n";
            print "  __".$sub_cond->header_list."__".$sub_cond->key_list."__\n";
        } 
    } else {
        print "  __".$cond->header_list."__".$cond->key_list."__\n";
    }
    
};
