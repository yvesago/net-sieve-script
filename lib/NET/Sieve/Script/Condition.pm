package NET::Sieve::Script::Condition;
use strict;
use base qw(Class::Accessor::Fast);

__PACKAGE__->mk_accessors(qw(test not condition key_list header_list address_part match_type comparator));

sub new
{
    my ($class, $param) = @_;

    my $self = bless ({}, ref ($class) || $class);

    my @ADDRESS_PART = qw(:all |:localpart |:domain );
    #Syntax:   ":comparator" <comparator-name: string>
    my @COMPARATOR_NAME = qw(i;octet|i;ascii-casemap);
    my @MATCH_TYPE = qw(:is |:contains |:matches );
    # match : <header-list: string-list> <key-list: string-list>
    my @LISTS = qw((\[.*?\]|".*?"));

    my @header_list = qw(From To Cc Bcc Sender Resent-From Resent-To List-Id);

    $param =~ s/^ +//;
    $param =~ s/ +$//;

    return undef if 
        $param !~ m/^(not )?(address|enveloppe|header|size|allof|anyof|exists|false|true)(.*)/i;

    my $not = $1;
    my $test = $2;
    my $args = $3;

    $self->not($not);
    $self->test($test);

    $args =~ s/^ +//;
    $args =~ s/ +$//;

    # substitute ',' separator by ' ' in string-list
    # to easy parse test-list
    $args =~ s/",\s?"/" "/g;

    # recursiv search for more condtions
    if ( $args =~ m/^\((.*)\)$/ ) { 
        my @condition_list;
        my @condition_list_string = split ( ',', $1 );
        foreach my $sub_condition (@condition_list_string) {
#            print "\n====>".$sub_condition."\n";
            push @condition_list, NET::Sieve::Script::Condition->new($sub_condition);
        }
        $self->condition(\@condition_list);
    }

    my ($address,$comparator,$match,$string,$key_list);
    # RFC Syntax : address [ADDRESS-PART] [COMPARATOR] [MATCH-TYPE]
    #             <header-list: string-list> <key-list: string-list>
    if ( $test eq 'address' ) {
      ($address,$comparator,$match,$string,$key_list) = $args =~ m/(@ADDRESS_PART)?(:comparator "(?:@COMPARATOR_NAME)" )?(@MATCH_TYPE)?@LISTS @LISTS$/;
    };
    # RFC Syntax : envelope [COMPARATOR] [ADDRESS-PART] [MATCH-TYPE]
    #             <envelope-part: string-list> <key-list: string-list>
    if ( $test eq 'envelope' ) {
      ($comparator,$address,$match,$string,$key_list) = $args =~ m/(:comparator "(?:@COMPARATOR_NAME)" )?(@ADDRESS_PART)?(@MATCH_TYPE)?@LISTS @LISTS$/;
    };
    # RFC Syntax : header [COMPARATOR] [MATCH-TYPE]
    #             <header-names: string-list> <key-list: string-list>
    if ( $test eq 'header' ) {
      ($comparator,$match,$string,$key_list) = $args =~ m/(:comparator "(?:@COMPARATOR_NAME)" )?(@MATCH_TYPE)?@LISTS @LISTS$/gi;
    };
    # RFC Syntax : size <":over" / ":under"> <limit: number>
    #TODO match size

    $self->address_part($address);
    $self->match_type($match);
    $self->comparator($comparator);
    $self->header_list($string);
    $self->key_list($key_list);


    return $self;
}
=head1 NAME

NET::Sieve::Script::Condition - parse and write conditions in sieve scripts

=head1 SYNOPSIS

  use NET::Sieve::Script::Condition;

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
