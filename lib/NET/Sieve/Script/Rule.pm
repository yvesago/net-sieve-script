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

=head1 NAME

NET::Sieve::Script::Rule - parse and write rules in sieve scripts

=head1 SYNOPSIS

  use NET::Sieve::Script::Rule;

=head1 DESCRIPTION

B<WARNING!!! This module is still in early alpha stage. It is recommended
that you use it only for testing.>

http://www.ietf.org/rfc/rfc3028.txt

=head1 CONSTRUCTOR

=head2 new

=head1 METHODS

=head1 BUGS

=head1 SUPPORT

=head1 AUTHOR

    Yves Agostini
    CPAN ID: YVESAGO
    Univ Metz
    agostini@univ-metz.fr
    http://www.crium.univ-metz.fr

=head1 COPYRIGHT

This program is free software; you can redistribute
it and/or modify it under the same terms as Perl itself.

The full text of the license can be found in the
LICENSE file included with this module.

=cut

return 1;

