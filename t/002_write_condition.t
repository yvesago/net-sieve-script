use Test::More tests => 16;
use strict;

use lib qw(lib);

BEGIN {
    use_ok( 'NET::Sieve::Script::Rule' );
    use_ok( 'NET::Sieve::Script::Condition');
}

my $rule = NET::Sieve::Script::Rule->new(
#        test_list => 'anyof (header :contains "Subject" "[Test]",header :contains "Subject" "[Test2]")' ,
        );


ok ($rule->add_condition('header :contains "Subject" "[Test]"'), "add rule condition by string");
print $rule->add_condition('anyof (header :contains "Subject" "[Test]",header :contains "Subject" "[Test2]")')."\n\n";

my $cond = NET::Sieve::Script::Condition->new('header');
$cond->match_type(':contains');
#$cond->test('header ');
$cond->key_list('"[Test]"');
$cond->header_list('"Subject"');
ok($rule->add_condition($cond), "add rule condition by object");

#print $rule->add_condition('header :contains "Subject" "[Test]"');

#$rule->add_action('fileinto "Test1"');
#isa_ok($rule->find_action(1),'NET::Sieve::Script::Condition');
#is( $rule->find_action(5), 0, "test error find action 5 ");

#print $rule->write_condition."\n\n";

use Data::Dumper;

#delete $rule->conditions->Conds->{2};

print Dumper $rule->conditions;
#print Dumper $rule->conditions->AllConds->{2};
#print Dumper $rule->conditions->condition->[2];

#print $rule->conditions->id."--\n\n";

print $rule->write_condition."\n\n";
