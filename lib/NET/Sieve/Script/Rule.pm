package NET::Sieve::Script::Rule;
use strict;
use base qw(Class::Accessor::Fast);
use  NET::Sieve::Script::Action;
use NET::Sieve::Script::Condition;

__PACKAGE__->mk_accessors(qw(alternate conditions actions priority));

sub new
{
    my ($class, %param) = @_;

    my $self = bless ({}, ref ($class) || $class);


        $self->alternate($param{ctrl});
        $self->priority($param{order});

        my @Actions;
        my @commands = split( ';' , $param{block});
        foreach my $command (@commands) {
            push @Actions, NET::Sieve::Script::Action->new($command);
        };  
        $self->actions(\@Actions);

        my $cond = NET::Sieve::Script::Condition->new($param{test_list});
        $self->conditions($cond);


    return $self;
}

sub write
{
    my $self = shift;

    return $self->alternate.' '.
            $self->write_condition."\n".
            '    {'.
            "\n".$self->write_action.
            '    }';
}

sub write_condition
{
    my $self = shift;

    return undef if ! $self->conditions;
    return $self->conditions->write();
}

sub write_action
{
    my $self = shift;

    my $actions;

    foreach my $command ( @{$self->actions()} ) {
            $actions .= '    '.$command->command;
            $actions .= ' "'.$command->param.'"' if ($command->param);
            $actions .= ";\n";
    }

    return $actions;
}

=head1 NAME

NET::Sieve::Script::Rule - parse and write rules in sieve scripts

=head1 SYNOPSIS

  use NET::Sieve::Script::Rule;
        my $pRule = NET::Sieve::Script::Rule->new (
            ctrl => $ctrl,
            test_list => $test_list,
            block => $block,
            order => $order
            );


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

