use Test::More tests => 8;
use strict;

use lib qw(lib);

BEGIN { use_ok( 'NET::Sieve::Script::Action' ); }

my $command = ' fileinto "INBOX.spam" ';

my $action = NET::Sieve::Script::Action->new($command);

is ( $action->command, 'fileinto', "command fileinto");
is ( $action->param, '"INBOX.spam"', "param INBOX.spam");

$action = NET::Sieve::Script::Action->new('stop');
is ( $action->command, 'stop', "command stop");

$action = NET::Sieve::Script::Action->new('redirect "bart@example.edu"');
is ( $action->command, 'redirect', "command redirect");
is ( $action->param, '"bart@example.edu"', 'param bart@example.edu');

$action = NET::Sieve::Script::Action->new('nimp "bart@example.edu"');
is ( $action->command, undef, "undef for command nimp");

my $multi_line_param = 'text: some text 
on multi-line 
.';

my $command2 = ' reject '.$multi_line_param; 
my $action2 = NET::Sieve::Script::Action->new($command2);
is ( $action2->param, $multi_line_param , "match mult-line param");
