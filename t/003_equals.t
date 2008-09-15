# -*- perl -*-

# t/003_equals.t - test equals methods

use Test::More tests => 15;
use strict;

use lib qw(lib);

BEGIN { use_ok( 'Net::Sieve::Script' ); }

my $test_script='require "fileinto";
# Place all these in the "Test" folder
if header :contains "Subject" "[Test] test" {
       fileinto "Test";
}';

my $test_script2='require "fileinto";
# same as 1, lower case condition action 
if Header :contains "subject" "[Test] test" {
    Fileinto "Test";
}';

my $test_script3='
# no require
if header :contains "Subject" "[Test] test" {
       fileinto "Test";
}';

my $test_script4='require "fileinto";
# other action
if header :contains "Subject" "[Test] test" {
       discard;
}';

my $test_script5='require "fileinto vacation";
# other require
if header :contains "Subject" "[Test] test" {
       fileinto "Test";
}';

my $test_script6='require "fileinto";
# other condition, lower case condition
if header :contains "Subject" "[test] test" {
       fileinto "Test";
}';

my $test_script7='
    # Example Sieve Filter
    require ["fileinto", "reject"];

    #
    if size :over 1M
            {
            reject text:
    Please do not send me large attachments.
    Put your file on a server and send me the URL.
    Thank you.
    .... Fred
    .
    ;
            stop;
            }
    #

    # Handle messages from known mailing lists
    # Move messages from IETF filter discussion list to filter folder
    #
    if header :is "Sender" "owner-ietf-mta-filters@imc.org"
            {
            fileinto "filter";  # move to "filter" folder
            }
    #
    # Keep all messages to or from people in my company
    #
    elsif address :domain :is ["From", "To"] "example.com"
            {
            keep;               # keep in "In" folder
            }

    #
    # Try and catch unsolicited email.  If a message is not to me,
    # or it contains a subject known to be spam, file it away.
    #
    elsif anyof (not address :all :contains
                   ["To", "Cc", "Bcc"] "me@example.com",
                 header :matches "subject"
                   ["*make*money*fast*", "*university*dipl*mas*"])
            {
            # If message header does not contain my address,
            # it s from a list.
            fileinto "spam";   # move to "spam" folder
            }
    else
            {
            # Move all other (non-company) mail to "personal"
            # folder.
            fileinto "personal";
            }
';

my $object = Net::Sieve::Script->new ();
isa_ok ($object, 'Net::Sieve::Script');

use_ok( 'Net::Sieve::Script::Rule' );
use_ok( 'Net::Sieve::Script::Condition' );
use_ok( 'Net::Sieve::Script::Action' );

$object = Net::Sieve::Script->new ($test_script);
isa_ok ($object, 'Net::Sieve::Script','load test_script');

ok($object->equals($object),"object equals object");

my $test_object = Net::Sieve::Script->new ($test_script2);
isa_ok ($test_object, 'Net::Sieve::Script','test_object');

ok($test_object->equals($object),"test_object equals object");
ok($object->equals($test_object),"object equals test_object");

$test_object = Net::Sieve::Script->new ($test_script3);
is($test_object->equals($object),0,"test_object3 not equals object");

$test_object = Net::Sieve::Script->new ($test_script4);
is($test_object->equals($object),0,"test_object4 not equals object");

$test_object = Net::Sieve::Script->new ($test_script5);
is($test_object->equals($object),0,"test_object5 not equals object");

$test_object = Net::Sieve::Script->new ($test_script6);
is($test_object->equals($object),0,"test_object6 not equals object");

$test_object = Net::Sieve::Script->new ($test_script7);
ok($test_object->equals($test_object),'complex object is equal to itself');

#open F, "t/loud.txt";
#my @test_loud = <F>;
#close F;

#print @test_loud;

#$object->raw(join "\n",@test_loud);
#$object->read_rules();
#print $object->write_script;
#is ($object->_strip,$object->_strip($object->write_script), "parse raw script3");

#print $object->write_script;

