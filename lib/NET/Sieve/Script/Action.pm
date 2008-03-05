package NET::Sieve::Script::Action;
use strict;
use base qw(Class::Accessor::Fast);

__PACKAGE__->mk_accessors(qw(action command param));

sub new
{
    my ($class, $param) = @_;

    my $self = bless ({}, ref ($class) || $class);

    my ($command, $param) = $param =~ m/(keep|discard|redirect|stop|reject|fileinto)(?: \"(.*?)\")?/; 

    $self->command($command);
    $self->param($param);

    return $self;
}


return 1;
