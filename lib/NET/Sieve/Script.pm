package NET::Sieve::Script;
use strict;

=head1 

http://www.ietf.org/rfc/rfc3028.txt

=cut

BEGIN {
    use Exporter ();
    use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);
    $VERSION     = '0.01';
    @ISA         = qw(Exporter);
    #Give a hoot don't pollute, do not export more than needed by default
    @EXPORT      = qw();
    @EXPORT_OK   = qw();
    %EXPORT_TAGS = ();
}

use base qw(Class::Accessor::Fast);
use NET::Sieve::Script::Rule;
use NET::Sieve::Script::Condition;
use NET::Sieve::Script::Action;

__PACKAGE__->mk_accessors(qw(name status raw));

#################### subroutine header begin ####################

=head2 sample_function

 Usage     : How to use this function/method
 Purpose   : What it does
 Returns   : What it returns
 Argument  : What it wants to know
 Throws    : Exceptions and other anomolies
 Comment   : This is a sample subroutine header.
           : It is polite to include more pod and fewer comments.

See Also   : 

=cut

#################### subroutine header end ####################


sub new
{
    my ($class, %param) = @_;

    my $self = bless ({}, ref ($class) || $class);

    if (!$param{name}) {
        die "name parameter is mandatory!";
    };

    $self->name($param{name});
    $self->status($param{status});
    return $self;
}

sub rules
{
    my ($self, $action, $rule, $priority ) = @_;
    
    #read rules from raw
    my $script_raw = $self->raw();
    $script_raw =~ s/\#.*//g;      # hash-comment
    $script_raw =~ s!/\*.*.\*/!!g; # bracket-comment
    $script_raw =~ s/^require.*//gi;
    $script_raw =~ s/\t/ /g;  # white-space
    $script_raw =~ s/  +/ /g; # white-space
    $script_raw =~ s/^ //;
    $script_raw =~ s/ $//;
    #TODO better multi-line support : multi-line-dotstuff
    $script_raw =~ s/[\n\r]//g;

    my @Rules;

    my $order;
    while ($script_raw =~m/(if|else|elsif) (.*?){(.*?)}([\s;]?)/g) {
        my $ctrl = $1;
        my $test_list = $2;
        my $block = $3;

#        print "$order cond:".$2."\n";
#        print "$order act:".$3."\n";
        my $pRule = new NET::Sieve::Script::Rule;
        
        ++$order;
        $pRule->alternate(1) if ( $ctrl ne 'if' );
        $pRule->priority($order);

        my @Actions;
        my @commands = split( ';' , $block);
        foreach my $command (@commands) {
            push @Actions, NET::Sieve::Script::Action->new($command);
        };
        $pRule->actions(\@Actions);

        my $cond = NET::Sieve::Script::Condition->new($test_list);
        $pRule->conditions($cond);

        push @Rules, $pRule;
    };

return \@Rules;

# set rules
    if ( defined $rule ) {
        if ( $action eq 'add' ) { 
            print "add rule\n";
        } 
        elsif ( $action eq 'del' ) {
            print "remove rule\n";
        }
        elsif ( $action eq 'update' ) {
            print "update rule\n";
        };
    };



}

#################### main pod documentation begin ###################
## Below is the stub of documentation for your module. 
## You better edit it!


=head1 NAME

NET::Sieve::Script - Module abstract (<= 44 characters) goes here

=head1 SYNOPSIS

  use NET::Sieve::Script;
  blah blah blah


=head1 DESCRIPTION

Stub documentation for this module was created by ExtUtils::ModuleMaker.
It looks like the author of the extension was negligent enough
to leave the stub unedited.

Blah blah blah.


=head1 USAGE



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


=head1 SEE ALSO

perl(1).

=cut

#################### main pod documentation end ###################


1;
# The preceding line will help the module return a true value

