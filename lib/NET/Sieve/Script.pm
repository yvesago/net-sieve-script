package NET::Sieve::Script;
use strict;

# http://www.ietf.org/rfc/rfc3028.txt

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

__PACKAGE__->mk_accessors(qw(raw));

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
    my ($class, $param) = @_;

    my $self = bless ({}, ref ($class) || $class);

    $self->raw($param);

    return $self;
}

sub rules
{
    my ($self, $action, $rule, $priority ) = @_;
    
    #read rules from raw
    my $script_raw = $self->_strip();

    my @Rules;

    my $order;
    while ($script_raw =~m/(if|else|elsif) (.*?){(.*?)}([\s;]?)/g) {
        my $ctrl = $1;
        my $test_list = $2;
        my $block = $3;

        ++$order;

        my $pRule = NET::Sieve::Script::Rule->new (
            ctrl => $ctrl,
            test_list => $test_list,
            block => $block,
            order => $order
            );
        
		# TODO break if more than 50 rules

        push @Rules, $pRule;
    };

return @Rules;

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

sub swap_rules
{
    my $self = shift;
    my $new = shift;
    my $old = shift;
}

# function _strip
#  strip a string or strip raw
#  return a string
# usefull for parsing or test

sub _strip {
	my $self = shift;
	my $script_raw = shift || $self->raw();

    $script_raw =~ s/\#.*//g;      # hash-comment
    $script_raw =~ s!/\*.*.\*/!!g; # bracket-comment
    $script_raw =~ s/^require.*//gi;
    $script_raw =~ s/\t/ /g;  # white-space
    $script_raw =~ s/\s+/ /g; # white-space
    $script_raw =~ s/\(\s+/\(/g; #  remove white-space after ( 
    $script_raw =~ s/\s+\)/\)/g; # remove white-space before )
    $script_raw =~ s/^\s+//;
    $script_raw =~ s/\s+$//;

	return $script_raw;
}

#################### main pod documentation begin ###################
## Below is the stub of documentation for your module. 
## You better edit it!


=head1 NAME

NET::Sieve::Script - parse and write sieve scripts

=head1 SYNOPSIS

  use NET::Sieve::Script;
  blah blah blah


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


=head1 SEE ALSO

L<NET::Sieve>

=cut

#################### main pod documentation end ###################


1;
# The preceding line will help the module return a true value

