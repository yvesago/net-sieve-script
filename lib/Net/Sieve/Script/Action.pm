package Net::Sieve::Script::Action;
use strict;
use warnings;

use base qw(Class::Accessor::Fast);

use vars qw($VERSION);

$VERSION = '0.06';

__PACKAGE__->mk_accessors(qw(command param));

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

Net::Sieve::Script::Action - parse and write actions in sieve scripts

=head1 SYNOPSIS

  use Net::Sieve::Script::Action;
  $action = Net::Sieve::Script::Action->new('redirect "bart@example.edu"');

or

  $action = Net::Sieve::Script::Action->new();
  $action->command('redirect');
  $action->param('"bart@example.edu"');


=head1 DESCRIPTION

Action object for L<Net::Sieve::Script>, with command and optional param.

Support RFC 5228, RFC 5230 (vacation), regex draft

=head1 METHODS

=head2 CONSTRUCTOR new

 Argument : "command param" string, 

parse valid commands from RFCs, param are not validate. 

=head2 command

read command : C<< $action->command() >>

set command  : C<< $action->command('stop') >> 

=head2 param

read param : C<< $action->param() >>

set param  : C<< $action->param(' :days 3 "I am away this week."') >>

=head1 AUTHOR

Yves Agostini - Univ Metz - <agostini@univ-metz.fr>

L<http://www.crium.univ-metz.fr>

=head1 COPYRIGHT

This program is free software; you can redistribute
it and/or modify it under the same terms as Perl itself.

The full text of the license can be found in the
LICENSE file included with this module.

=cut

return 1;
