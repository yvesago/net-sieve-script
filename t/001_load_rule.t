use Test::More tests => 1;
use strict;

use lib qw(lib);

BEGIN { use_ok( 'NET::Sieve::Script::Rule' ); }

my $command = ' fileinto "INBOX.spam" ';

my $rule = NET::Sieve::Script::Rule->new(
    ctrl => 'if',
    block => 'fileinto "spam"; stop;',
    test_list => 'anyof (not address :all :contains ["To", "Cc", "Bcc"] "me@example.com", header :matches "subject" ["*make*money*fast*", "*university*dipl*mas*"])',
    order => 1
    );

print $rule->write_action."\n";
print $rule->write_condition."\n";
print "======\n";
print $rule->write."\n";
