package Local::JSONParser;

use strict;
use base qw(Exporter);
use Data::Dumper;
use DDP;
our @EXPORT_OK = qw( parse_json );
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
    
       print "\nвот что пришло".$source."\n";

    if ( $source=~ m/^(\s*|null|true|false|([-+]?\d*[,\.]?\d+(?:[eE][-+]?\d+)?))$/ )
    {
        return $source;
    } # числа, null, true, false, пробел

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
        return $source;
    }

    if ( $source =~ /^{(.*)}(?=\,|$)/s ) { return splitObj($1); }
    if ( $source =~ /^\[(.*)\]/s )  { return splitArr($1) }

     return "Error";
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
               $key = deleteEmpty($key);
            if ( $key =~ /\"(?:\\.|[^\"])*+\"/ ) {
                $key =~ s/^\"//;
                $key =~ s/\"$//;
            }
            $hash{$key} = checkString($value);
        }
        elsif ( defined( $+{object} ) ) {
            %hash = splitObj( $+{object} );
        }
        elsif ( defined( $+{arr} ) ) {
            %hash = splitArr( $+{arr} );
        }
    }
 

    return \%hash;
}

sub splitArr {
    my $string = shift;
       $string = deleteEmpty($string);
       $string =~ s/^\[//;
       $string =~ s/\]$//;
    
    my @array;

    while ( $string
        =~ /((?<object>\{.*\}(?=\,|$)))|((?<arr>\[.*\](?=\,$)))|((^|\,)(?<value>($string|\w+)(?=\,|$)))/gxsm
        )
    {
        if ( defined( $+{value} ) ) { push @array, checkString( $+{value})}
        elsif ( defined( $+{object} ) ) {push @array, checkString( $+{object}  )}
        elsif ( defined( $+{arr} ) ) {push @array, checkString( $+{arr}  )}
    }

    return \@array;
}

1;
