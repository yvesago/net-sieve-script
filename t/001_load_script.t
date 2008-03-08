# -*- perl -*-

# t/001_load.t - check module loading and create testing directory

use Test::More tests => 9;
use strict;

use lib qw(lib);

BEGIN { use_ok( 'NET::Sieve::Script' ); }

my $test_script='require "fileinto";
# Place all these in the "Test" folder
if header :contains "Subject" "[Test]" {
       fileinto "Test";
}';

my $object = NET::Sieve::Script->new ();
isa_ok ($object, 'NET::Sieve::Script');

my $object = NET::Sieve::Script->new ($test_script);
isa_ok ($object, 'NET::Sieve::Script');


is ($object->raw, $test_script, "raw script");
#print length($object->raw);

my $test_script2='require ["fileinto","reject","vacation","imapflags","relational","comparator-i;ascii-numeric","regex","notify"];
if header :contains "Received" "compilerlist@example.com"
{
  fileinto "mlists.compiler";
#  stop;
}
if header :regex :comparator "i;ascii-casemap" "Subject" "^Release notice:"
{
  fileinto "releases";
  stop;
}
if allof (header :regex :comparator "i;ascii-casemap" "Subject" "^Output file listing from [a-z]*backup$",
          header :regex :comparator "i;ascii-casemap" "From" "^BackupUser")
{
  fileinto "Backup listings";
  stop;
}
if header :is "Subject" "Daily virus scan reminder"
{
  discard;
  stop;
}';

my $test_script3 = '
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

$object->raw($test_script3);

is ($object->raw, $test_script3, "set raw script");

use_ok( 'NET::Sieve::Script::Rule' );
use_ok( 'NET::Sieve::Script::Condition' );
use_ok( 'NET::Sieve::Script::Action' );


my $res_script;
#    print $script->raw."\n";
#    print $script->parse_ok."\n";
    foreach my $rule ($object->rules()) {
      print "\n=rule:".$rule->priority."\n";
      print $rule->write;
      $res_script .= $rule->write;
    }

print "\n";

is ($object->_strip,'require ["fileinto", "reject"]; '. $object->_strip($res_script), "");

#TODO test $object->swap_rules(1,5);
#TODO test $object->remove_rule(3);
#TODO test $object->del_rule(3);
