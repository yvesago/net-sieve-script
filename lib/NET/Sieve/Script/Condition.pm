package NET::Sieve::Script::Condition;
use strict;
use base qw(Class::Accessor::Fast);

__PACKAGE__->mk_accessors(qw(test not condition key_list header_list address_part match_type comparator require));

my @FILO;

sub new
{
    my ($class, $param) = @_;

    my $self = bless ({}, ref ($class) || $class);
	my $require;

    my @ADDRESS_PART = qw((:all |:localpart |:domain ));
    #Syntax:   ":comparator" <comparator-name: string>
    my @COMPARATOR_NAME = qw(i;octet|i;ascii-casemap);
    # my @MATCH_TYPE = qw((:\w+ ));
	# regex expired draft will be removed
    my @MATCH_TYPE = qw((:is |:contains |:matches ));
    my @MATCH_SIZE = qw((:over |:under ));
    # match relationnal RFC 5231
	my @MATCH_REL = qw((:value ".." |:count ".." ));
    # match : <header-list: string-list> <key-list: string-list>
    my @LISTS = qw((\[.*?\]|".*?"));

    #my @header_list = qw(From To Cc Bcc Sender Resent-From Resent-To List-Id);

    $param =~ s/^\s+//;
    $param =~ s/\s+$//;
    $param =~ s/\t/ /g;
    $param =~ s/\s+/ /g;
    $param =~ s/[\r\n]//gs;

    return undef if 
        $param !~ m/^(not )?(address|enveloppe|header|size|allof|anyof|exists|false|true)(.*)/i;

    my $not = lc($1);
    my $test = lc($2);
    my $args = $3;

    $self->not($not);
    $self->test($test);

    $args =~ s/^\s+//g;
    $args =~ s/\s+$//g;
    $args =~ s/\s+([\(\)])\s+/$1/g;

    # substitute ',' separator by ' ' in string-list
    # to easy parse test-list
    # better :  
    1 while ($args =~ s/(\[[^\]]+?)",\s*/$1" /);
    #$args =~ s/",\s+"/" "/g;

    #recursiv search for anyof/allof conditions
    my @COND = $self->condition(); 
    while ( $args =~ s/(.*)\(([^\(].*?)\)(.*)/$1$3/s ) { 
        my $first = $1;
        my $last = $3;
        my $subs = $2;

        my @condition_list;
        my @condition_list_string = split ( ',', $subs );
        foreach my $sub_condition (@condition_list_string) {
            my $new_subs = NET::Sieve::Script::Condition->new($sub_condition);
            next if (!$new_subs);
            if ( $new_subs->test eq 'anyof' || $new_subs->test eq 'allof' ) {
                $new_subs->condition(pop @FILO);
            };
            (!$first && !$last) ? 
               push @COND, $new_subs : push @condition_list, $new_subs;
        }
    
        (!$first && !$last) ? 
            $self->condition(\@COND) : push @FILO, \@condition_list;

    };

    my ($address,$comparator,$match,$string,$key_list);
    # RFC Syntax : address [ADDRESS-PART] [COMPARATOR] [MATCH-TYPE]
    #             <header-list: string-list> <key-list: string-list>
    if ( $test eq 'address' ) {
      ($address,$comparator,$match,$string,$key_list) = $args =~ m/@ADDRESS_PART?(:comparator "(?:@COMPARATOR_NAME)" )?@MATCH_TYPE?@LISTS @LISTS$/gi;
    };
    # RFC Syntax : envelope [COMPARATOR] [ADDRESS-PART] [MATCH-TYPE]
    #             <envelope-part: string-list> <key-list: string-list>
    if ( $test eq 'envelope' ) {
      ($comparator,$address,$match,$string,$key_list) = $args =~ m/(:comparator "(?:@COMPARATOR_NAME)" )?@ADDRESS_PART?@MATCH_TYPE?@LISTS @LISTS$/gi;
    };
    # RFC Syntax : header [COMPARATOR] [MATCH-TYPE]
    #             <header-names: string-list> <key-list: string-list>
    if ( $test eq 'header' ) {
      # only for regex old draft
      ($match,$comparator,$string,$key_list) = $args =~ m/(:regex )?(:comparator "(?:@COMPARATOR_NAME)" )?@LISTS @LISTS$/gi;
      # RFC 5228 ! 
	  if (!$match) {
        ($comparator,$match,$string,$key_list) = $args =~ m/(:comparator "(?:@COMPARATOR_NAME)" )?@MATCH_TYPE?@LISTS @LISTS$/gi;
	  };
    };
    # RFC Syntax : size <":over" / ":under"> <limit: number>
    if ( $test eq 'size'  ) {
      ($match,$string) = $args =~ m/@MATCH_SIZE(.*)$/gi;
	};
    # find require
    if (lc($match) eq ':regex ') {
	  push @{$require}, 'regex';
	};
	$self->require($require);


    $self->address_part(lc($address));
    $self->match_type(lc($match));
    $self->comparator(lc($comparator));
    $self->header_list($string);
    $self->key_list($key_list);


    return $self;
}

=head2 write

 Purpose  : write rule conditions
 Return   : multi-line formated text

=cut

sub write {
    my $self = shift;
    my $recursiv_level = shift || 0;
    my $text_condition = "";

    $recursiv_level++;
    if (defined $self->condition() ) {
        $text_condition = ' ' x $recursiv_level;
        $text_condition .= $self->not.' ' if ($self->not);
        $text_condition .= $self->test." ( ";
        foreach my $sub_cond ( @{$self->condition()} ) {
            next if ! $sub_cond;
            if (defined $sub_cond->condition() ) {
                $text_condition .= "\n".(' ' x $recursiv_level).$sub_cond->write($recursiv_level).",\n";
                next;};
            $text_condition .= "\n".(' ' x $recursiv_level).'  '.  $sub_cond->_write_test().',';
        }
        $text_condition =~ s/,$//;
        $text_condition .= ' )';
    } 
    else {
        $text_condition = $self->_write_test();
    };

    return $text_condition;
}

# private method
# _write_test
# return single line text

sub _write_test {
    my $self = shift;
    my $line = $self->not.' '.$self->test.' ';
   
   my $comparator = ':comparator '.$self->comparator if ($self->comparator);
   
    if ( $self->test eq 'address' ) {
        $line .= $self->address_part.' '.$comparator.' '.$self->match_type;
    }
    elsif ( $self->test eq 'envelope' ) {
        $line .= $comparator.' '.$self->address_part.' '.$self->match_type;
    }
    elsif ( $self->test eq 'header' ) {
		if ($self->match_type eq ':regex ') {
            $line .= $self->match_type.' '.$self->comparator;
		}
		else {
            $line .= $self->comparator.' '.$self->match_type;
		}
	}
    elsif ( $self->test eq 'size' ) {
		$line .= $self->match_type;
	};
	

    $line.=' '.$self->header_list.' '.$self->key_list;

    $line =~ s/^\s+//;
    $line =~ s/\s+$//;
    $line =~ s/ +/ /g;
    # restore ", " in [ ]
    1 while ( $line =~ s/(\[[^\]]+?)" "/$1", "/);

    return $line;
}

=head2  add_subcondition

=cut

sub add_subcondition
{
    my $self = shift;
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
