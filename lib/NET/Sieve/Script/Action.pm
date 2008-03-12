package NET::Sieve::Script::Action;
use strict;
use base qw(Class::Accessor::Fast);

__PACKAGE__->mk_accessors(qw(action command param));

sub new
{
    my ($class, $init) = @_;

    my $self = bless ({}, ref ($class) || $class);

	my @MATCH = qw(\s?((\".*?\"|(.*)?)));

    my ($command, $param) = $init =~ m/(keep|discard|redirect|stop|reject|fileinto)@MATCH?/sgi;

    # RFC 5230
 #Usage:   vacation [":days" number] [":subject" string]
 #                    [":from" string] [":addresses" string-list]
 #                    [":mime"] [":handle" string] <reason: string>
 #TODO make object vacation
    if ( $init =~ m/vacation (.*")/sgi ) {
        $command = 'vacation';
        $param = $1;
    };

    $self->command(lc($command)) if $command;
    $self->param($param) if $param ;

    return $self;
}

=head1 NAME

NET::Sieve::Script::Action - parse and write actions in sieve scripts

=head1 SYNOPSIS

  use NET::Sieve::Script::Action;

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
