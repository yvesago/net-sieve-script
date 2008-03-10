use Test::More tests => 33;
use strict;

use lib qw(lib);

BEGIN {
    use_ok( 'NET::Sieve::Script');
    use_ok( 'NET::Sieve::Script::Rule' ); 
}

my $script = NET::Sieve::Script->new();

# register 3 rules
my @Rules = ();
for my $i (1..3) {
    $Rules[$i] = NET::Sieve::Script::Rule->new(
        test_list => 'header :contains "Subject" "[Test'.$i.']"' ,
        block => 'fileinto "Test'.$i.'"; stop;'
        );
    ok ($script->add_rule($Rules[$i]), "add rule $i");
}

#print $script->write_rules;
isa_ok($script->find_rule(2),'NET::Sieve::Script::Rule');

ok ($script->swap_rules(3,2),"swap rules 3,2");
is ($script->swap_rules(4,2),0,"test error on swap rules");
is ($script->swap_rules(3,0),0,"test error on swap rules");
is ($script->swap_rules(3,3),0,"test error on swap rules");


is ($script->delete_rule(5),0,"test error on delete rule");
ok ($script->delete_rule(2),"delete rule 2");
ok ($script->delete_rule(1),"delete rule 1");
ok ($script->delete_rule(1),"delete rule 1");
is ($script->max_priority,0, "no more rules");

is ($script->add_rule(5),0,"test error on add rule");

# register 6 rules with else, elsif
for my $i (1..6) {
    my $ctrl = 'if' ;
   $ctrl = 'else' if $i == 5;
   $ctrl = 'elsif' if ( $i == 3 || $i == 4 );
    $Rules[$i] = NET::Sieve::Script::Rule->new(
        ctrl => $ctrl,
        block => 'fileinto "Test'.$i.'"; stop;',
        test_list => ($i != 5)?'header :contains "Subject" "[Test'.$i.']"' :''
        );
    ok ($script->add_rule($Rules[$i]), "add complex rule $i");
   }
ok ($script->delete_rule(2),"delete rule 2");
is ($script->max_priority,5,"5 rules");
ok ($script->delete_rule(3),"delete rule 3");
is ($script->max_priority,4,"4 rules");
ok ($script->delete_rule(2),"delete rule 2 and 3, rule 'if' with 'else' ");
is ($script->max_priority,2,"2 rules");

# add else rule
my $else_rule = NET::Sieve::Script::Rule->new(
    ctrl => 'else',
    block => 'reject; stop;'
    );
ok ($script->add_rule($else_rule),"add else rule");
is ($script->max_priority,3,"3 rules");
ok ($script->delete_rule(1),"delete rule 1");
ok ($script->delete_rule(1),"delete rule 1 and 2, rule 'if' with 'else' ");
is ($script->max_priority,0,"no more rule");

#print "======\n";
#print $Rules[3]->write."\n";
#print "======\n";
#print $script->write_rules;
