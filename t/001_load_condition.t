# -*- perl -*-

# t/001_load.t - check module loading and create testing directory

use Test::More tests => 11;
use strict;

use lib qw(lib);

BEGIN { use_ok( 'NET::Sieve::Script::Condition' ); }

my $bad_string = 'header :contains :comparator "i;octet" "i;octet" "Subject" "MAKE MONEY FAST"';

my @strings = (
'header :comparator "i;octet" :contains "Subject" "MAKE MONEY FAST"',
'header :contains "x-attached" [".exe",".bat",".js"]',
'not address :localpart :is "X-Delivered-To" ["address1", "address2", "address3"]',
'allof ( address :domain :is "X-Delivered-To" "mydomain.info", not address :localpart :is "X-Delivered-To" ["address1", "address2", "address3"] )',
'allof ( address :is "X-Delivered-To" "mydomain.info", not address :localpart :is "X-Delivered-To" ["address1", "address2", "address3"] )',
'header :contains ["from","cc"] "from-begin@begin.fr"',
'header :contains ["from","cc"] [ "from-begin@begin.fr", "sex.com newsletter"]',
'header :comparator "i;ascii-casemap" :matches "Subject" "^Output file listing from [a-z]*backup$"',
'size :over 1M'
);

isnt (NET::Sieve::Script::Condition->new($bad_string)->write,$bad_string,'bad string not RFC 5228');

foreach my $string (@strings) {

    $string =~ s/","/", "/g;
    $string =~ s/\[\s+"/\["/g;
    $string =~ s/"\s+]/"\]/g;

    my $cond = NET::Sieve::Script::Condition->new($string);
    my $resp = $cond->write;

    $resp =~ s/[\n\r]//g;
    $resp =~ s/\s+/ /g;
    $resp =~ s/^\s+//;
    $resp =~ s/\s+$//;

    is ($resp,$string,'test string');
};

my $s1 = 'allof ( 
    address :is "X-Delivered-To" "mydomain.info", 
    not address :localpart :is "X-Delivered-To" ["address1", "address2", "address3"], 
        allof ( header :contains "Subject" "Test", header :contains "Subject" "Test2" )
   )';

my $s2 = 'allof (
 anyof ( 
    header :contains ["From","Sender","Resent-from","Resent-sender","Return-path"] "xxx.com"
 ),
 anyof ( 
        allof (
          not header :matches ["Subject"," Keywords"] ["POSTMASTER-AUTO-FW:", "postmaster-auto-fw:"],
          header :matches ["Subject"," Keywords"] "*"
        ),
        true
        )
 )';

my $s3 ='anyof ( 
  header :contains ["From","Sender","Resent-from","Resent-sender","Return-path"] "xxx.com",
  header :contains ["Return-path"] "xxx.com"
  ),
allof (
  not header :matches ["Subject"," Keywords"] ["POSTMASTER-AUTO-FW:", "postmaster-auto-fw:"],
  header :matches ["Subject"," Keywords"] "*"
  )';


my $cond = NET::Sieve::Script::Condition->new($s3);
#print $cond->write;
