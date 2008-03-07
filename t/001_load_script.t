# -*- perl -*-

# t/001_load.t - check module loading and create testing directory

use Test::More tests => 8;
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

$object->raw($test_script2);

is ($object->raw, $test_script2, "set raw script");

use_ok( 'NET::Sieve::Script::Rule' );
use_ok( 'NET::Sieve::Script::Condition' );
use_ok( 'NET::Sieve::Script::Action' );

#exit;

#    print $script->raw."\n";
#    print $script->parse_ok."\n";
    foreach my $rule ($object->rules()) {
      print "\n=rule:".$rule->priority.' '.$rule->alternate."\n";

      print "==conditions\n";
      my $condition = $rule->conditions();
      print ' **'.$condition->write."\n";

      print "==actions\n";
     
	  foreach my $command ( @{$rule->actions()} ) {
          print ' >'.$command->command.' '.$command->param."\n";
      }
    
    }

