
=head1 DESCRIPTION

Эта функция должна принять на вход арифметическое выражение,
а на выходе дать ссылку на массив, состоящий из отдельных токенов.
Токен - это отдельная логическая часть выражения: число, скобка или арифметическая операция
В случае ошибки в выражении функция должна вызывать die с сообщением об ошибке

Знаки '-' и '+' в первой позиции, или после другой арифметической операции стоит воспринимать
как унарные и можно записывать как "U-" и "U+"

Стоит заметить, что после унарного оператора нельзя использовать бинарные операторы
Например последовательность 1 + - / 2 невалидна. Бинарный оператор / идёт после использования унарного "-"
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
=cut

use 5.010;
use strict;
use warnings;
use diagnostics;

BEGIN {
    if ( $] < 5.018 ) {

        package experimental;
        use warnings::register;
    }
}
no warnings 'experimental';

sub tokenize {
    chomp( my $expr = shift );
    my @res;
    my $type  = "sign";
    my $count = 0;

    if ( $expr =~ /\d+\.\d+\.+|[eE][eE]+|\(\D[-]+\D\)|^\D+$/ ) { die('Nan') }
    if ( $expr =~ /^\)|^[a-zA-Z)]+/ ) { die('Nan') }

    $expr =~ s/(\s+)//g;

    foreach ( split //, $expr ) {

        if ( $_ =~ m/\d+|\.|[eE]/ ) {
            $type = "num";
            if ( defined $res[$count] ) {
                $res[$count] = $res[$count] . $_;
            }
            else { $res[$count] = $_ }
        }

        elsif ( $_ =~ m/[+-]/
            and defined $res[$count]
            and $res[$count] =~ m/.*[eE]$/ )

        {

            if ( defined $res[$count] ) {
                $res[$count] = $res[$count] . $_;
            }
            else { $res[$count] = $_ }
        }

        else {

            $count++ if $type ne "sign";

            if ( ( $_ eq '-' and $count < 1 ) or ( $_ eq '+' and $count < 1 ) )
            {
                $_ = "U" . $_;
            }
            if (   ( $_ eq '-' and $type eq "sign" )
                or ( $_ eq '+' and $type eq "sign" ) )
            {
                $_ = "U" . $_;
            }

            $res[$count] = $_;
            $type = "sign";
            $count++;

        }

    }

    return \@res;

}

1;
