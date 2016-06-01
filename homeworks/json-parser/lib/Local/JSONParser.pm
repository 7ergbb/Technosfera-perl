package Local::JSONParser;

use strict;
use base qw(Exporter);
our @EXPORT = qw( parse_json );

sub parse_json {
    my $source = shift;
    my $str = checkString($source);
    return $str;
}

sub deleteEmpty {
    my $string = shift;
    # $string =~ s/\n//gm;
    $string =~ s/^\s+//;
    $string =~ s/\s+$//;
    return $string;
}

sub checkString #проверка на соответствие шаблону
{
    my $source = deleteEmpty(shift);
    
    if ( $source=~ m/^(\s*|null|true|false|([-+]?\d*[,\.]?\d+(?:[eE][-+]?\d+)?))$/ )
    {return $source;} # числа, null, true, false, пробел

    if ( $source =~ m/^\"(?:\\.|[^\"])*+\"$/ ) {
        for ($source) {
            s/^"|"$//g;
            s/\\u(\d{4})/chr(hex($1))/ge;
            s/\\f/\f/g;
            s/\\t/\t/g;
            s/\\r/\r/g;
            s/\\n/\n/g;
            s/\\(.)/$1/g;
            s/\\"/"/g;
        }
            return  $source;
    }

    if ( $source =~ /^{(.*)}(?=\,|$)/s ) { return splitObj($1); }
    if ( $source =~ /^\[(.*)\]/s )       { return splitArr($1) }
    else                                 {return die "Error"}
}

sub splitObj {
    my $string = shift;
    my %hash;
    $string = deleteEmpty($string);
    while ( $string
        =~ /((?<key>(\".+?\"|\w+?))(\s*)\:(?<value>(\"(?:\\.|[^\"])*+\"|\[.*\]|\{.*\}|.+?)(?=\,|$))(\,|$))/gxsm
        )
    {

        if ( defined( $+{key} ) and defined( $+{value} ) ) {
            my $key   = $+{key};
            my $value = $+{value};
            if ( $key =~ /\"(?:\\.|[^\"])*+\"/ ) {
                            $key =~ s/^\"//;
                            $key =~ s/\"$//;
            }
            $hash{$key} = checkString($value);
        }
        elsif ( ( $+{object} ) ) {%hash = splitObj( $+{object} )}
        elsif ( ( $+{arr} ) ) {%hash = splitArr( $+{arr} );}}
        if ($string ne '' and !%hash) {return die "Error: $_"}
        
        

    return \%hash;
}

sub splitArr {
    my $string = deleteEmpty(shift);
    my @array;
    while ( $string=~ /((?<object>\{.*\}(?=\,|$)))|((?<arr>\[.*\](?=\,$)))|(?<value>(\"(?:\\.|[^\"])*+\"|\w+)(?=\,|$))/gxsm)
    {
        if ( ( $+{value} ) ) { push @array, checkString( $+{value})}
        elsif ( ( $+{object} ) ) {push @array, checkString( $+{object}  )}
        elsif ( ( $+{arr} ) ) {push @array, checkString( $+{arr} )}
    }
       if ($string ne '' and !@array) {return die "Error: $_";}
    return \@array;
}

1;
