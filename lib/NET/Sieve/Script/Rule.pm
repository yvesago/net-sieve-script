package NET::Sieve::Script::Rule;
use strict;
use base qw(Class::Accessor::Fast);

__PACKAGE__->mk_accessors(qw(alternate conditions actions priority));

sub new
{
    my ($class, %param) = @_;

    my $self = bless ({}, ref ($class) || $class);

    #if (!$param{conditions}) {
    #    die "condition is mandatory!";
    #};

#    $self->name($param{name});
#    $self->status($param{status});
    return $self;
}

return 1;

