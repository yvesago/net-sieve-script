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

__PACKAGE__->mk_accessors(qw(raw rules require max_priority));

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
    my @LISTS = qw((\[.*?\]|".*?"));

    if ($param) {
        $self->raw($param); 
        $self->require($1) if ( $param =~ m/require @LISTS;/si );
        $self->read_rules();
    }

    return $self;
}

=head2 write_rules

 Purpose : write script, ie require and rules 
 Return  : set current require
 return rules ordered by priority in text format

=cut

sub write_rules {
    my $self = shift;
    my $text;
	my %require = ();

    foreach my $rule ( sort { $a->priority() <=> $b->priority() } @{$self->rules()} ) {
      $text .= $rule->write."\n";
	  foreach my $req ($rule->require()) {
	      $require{$req->[0]} = 1;
	  }
    }

#TODO keep original require if current if include for test parsing
    my $require_line;
    my $count;
    foreach my $req (sort keys %require) {
	    next if(!$req);
	    $require_line .= ', "'.$req.'"';
	    $count++;
    };
    $require_line =~ s/^, //;
    $require_line = '['.$require_line.']' if ($count > 1);

	$self->require($require_line);

    $require_line = "require $require_line;\n" if $require_line;

    return $require_line.$text;
}

=head2 read_rules

Read rules from raw or from $text_rules if set
set ->rules()
Return 1 on success;

=cut

sub read_rules
{
    my $self = shift;
    my $text_rules = shift || $self->raw();

    my @LISTS = qw((\[.*?\]|".*?"));
    
    $self->require($1) if ( $text_rules =~ m/require @LISTS;/si );

    #read rules from raw or from $text_rules if set
    my $script_raw = $self->_strip($text_rules);

    my @Rules;

    my $order;
    while ($script_raw =~m/(if|else|elsif) (.*?){(.*?)}([\s;]?)/isg) {
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

    $self->rules(\@Rules);
	$self->max_priority($order);

    return 1;
}

=head2 swap_rules

swap priority, take care of if/else/elsif

=cut

sub swap_rules
{
    my $self = shift;
    my $swap1 = shift;
    my $swap2 = shift;
    my ($pr1,$pr2);

    return 0 if $swap1 == $swap2;
    return 0 if $swap1<=0 || $swap2<=0;
    return 0 if not  defined $self->rules;
    return 0 if $swap1 > $self->max_priority || $swap2 > $self->max_priority;


    foreach my $rule (@{$self->rules}) {
        $pr2 = $rule if ($rule->priority == $swap1 );
        $pr1 = $rule if ($rule->priority == $swap2 );
    }
    
    my $mem_pr2 = $pr2->priority();
    $pr2->priority($pr1->priority());
    $pr1->priority($mem_pr2);

    return 1;
}

=head2 delete_rule

 delete rule and change priority
 delete rule take care for 'if' test

 if deleted is 'if'
  delete next if next is 'else'
  change next in 'if' next is 'elsif'

 Returns : 1 on success, 0 on error

=cut

sub delete_rule
{
    my $self = shift;
    my $id = shift;
    my $deleted = 0;
    my @Rules =  defined $self->rules?@{$self->rules}:();
    my @NewRules = ();
    my $order = 0;
    
    for ( my $i = 0; $i < scalar(@Rules); $i++ ) {
        my $rule = $Rules[$i];
        my $next=$i+1;
        if ($rule->priority == $id) {
            $deleted = 1;
            if ( defined $Rules[$next] && $rule->alternate eq 'if') {
                $Rules[$next]->alternate('if') 
                    if ($Rules[$next]->alternate eq 'elsif' );

                if ($Rules[$next]->alternate eq 'else' ) {
                    $i++;
                    $rule = $Rules[$i];
                }
            }
        }
        else {
            ++$order;
            $rule->priority($order);
            push @NewRules, $rule;
        }
    }

    $self->max_priority($order);
    $self->rules(\@NewRules);
    
    return $deleted;
}

=head2 add_rule

 Purpose  : add a rule in end of script
 Returns  : priority on success, 0 on error
 Argument : NET::Sieve::Script::Rule object

=cut

sub add_rule
{
    my $self = shift;
    my $rule = shift;

    return 0 if ref($rule) ne 'NET::Sieve::Script::Rule';

    my $order = $self->max_priority();
    my @Rules =  defined $self->rules?@{$self->rules}:();

    ++$order;
    $rule->priority($order);
    push @Rules, $rule;

    $self->max_priority($order);
    $self->rules(\@Rules);

    return $order;
}

# private function _strip
#  strip a string or strip raw
#  return a string
# usefull for parsing or test

sub _strip {
    my $self = shift;
    my $script_raw = shift || $self->raw();

    $script_raw =~ s/\#.*//g;      # hash-comment
    $script_raw =~ s!/\*.*.\*/!!g; # bracket-comment
    $script_raw =~ s/\t/ /g;  # white-space
    $script_raw =~ s/\s+/ /g; # white-space
    $script_raw =~ s/\(\s+/\(/g; #  remove white-space after ( 
    $script_raw =~ s/\s+\)/\)/g; # remove white-space before )
    $script_raw =~ s/\[\s+/\[/g; #  remove white-space after [ 
    $script_raw =~ s/\s+\]/\]/g; # remove white-space before ]
    $script_raw =~ s/^\s+//;
    $script_raw =~ s/\s+$//;
    $script_raw =~ s/","/", "/g;
#TODO: to remove write_rules will set require
    #$script_raw =~ s/require.*?["\]];\s+//sgi; #remove require

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

