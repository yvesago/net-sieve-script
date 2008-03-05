# -*- perl -*-

# t/001_load.t - check module loading and create testing directory

use Test::More tests => 9;
use strict;

use lib qw(lib);

BEGIN { use_ok( 'NET::Sieve::Script' ); }

my $object = NET::Sieve::Script->new (name => "test");
isa_ok ($object, 'NET::Sieve::Script');

is ($object->name,'test',"name set");
$object->status('ACTIVE');
is ($object->status,'ACTIVE',"active status set");
$object->status('');
is ($object->status,'',"unactive status set");

my $test_script='require "fileinto";
# Place all these in the "Test" folder
if header :contains "Subject" "[Test]" {
       fileinto "Test";
}';

$object->raw($test_script);
#print $object->raw;
is ($object->raw, $test_script, "raw script");
#print length($object->raw);

my $test_script2='require ["fileinto","reject","vacation","imapflags","relational","comparator-i;ascii-numeric","regex","notify"];
if header :contains "Received" "compilerlist@example.com"
{
  fileinto "mlists.compiler";
  stop;
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

use_ok( 'NET::Sieve::Script::Rule' );
use_ok( 'NET::Sieve::Script::Condition' );
use_ok( 'NET::Sieve::Script::Action' );


    print $object->name."\n";
    print $object->status."\n";
#    print $script->raw."\n";
#    print $script->parse_ok."\n";
#    $object->rules();
    foreach my $rule (@{$object->rules}) {
      print "\n=rule:".$rule->priority.' '.$rule->alternate."\n";

      print "==conditions\n";
      my $condition = $rule->conditions();
      print $condition->not.' '.$condition->test."\n";
      print "   ".$condition->key_list."\n";

      print "==actions\n";
      my @commands = @{$rule->actions()};
      foreach my $command (@commands) {
          print $command->command.' '.$command->param."\n";
      }
#      my @conditions = @{$rule->conditions()};
#      foreach my $condition (@conditions) {
#        print $condition->cond_type."\n"; #AND OR / allof anyof 
#        print  $condition->header.' '.$condition->field.' '.
#               $condition->test.' '.$condition->param."\n";
#      }
#    print $script->action->type." ".$script->action->param."\n";
     #print $script->more_action."\n";
    }
