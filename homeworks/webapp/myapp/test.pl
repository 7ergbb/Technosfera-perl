use strict;
use DBI;
use Data::Dumper;
use warnings;
 
use threads;

my $dbh = DBI->connect("dbi:SQLite:dbname="."../mywebapp") or die $DBI::errstr;
my $sql = 'SELECT * FROM user';
my $sth = $dbh->prepare($sql) or die $dbh->errstr;
 $sth->execute or die $sth->errstr;;
 # my $ref = $sth->fetchrow_hashref;
  

 
#  my $val =  %$ref{'pass'};
# print "323232323   -----    $val \n"; 		
#  # 'user' => $sth->fetchrow_hashref('user'),
#  # 'pass' => $sth->fetchrow_hashref('pass'),
#  # 'admin' => $sth->fetchrow_hashref('is_admin');
#  	 print Dumper $ref;  
#    my ($user, $pass, $admin);
#    $sth->bind_col(1,\$user, undef);
#    $sth->bind_col(2,\$pass, undef);
#    $sth->bind_col(3,\$admin, undef);
#    # Теперь $name и $date привязаны к соответствующим полям выходных данных

#    $sth->execute;
#   while ($sth->fetch) {
  
#  };
#  print "$user \  $pass   \ $admin";


# my $table = $sth -> fetchall_arrayref or die "$sth -> errstr\n";
# my($i, $j);
# for $i ( 0 .. $#{$table} ) { for $j ( 0 .. $#{$table -> [$i]} )  {
# print "$table->[$i][$j]\t";
# }
# print "\n";
# }

my $ref = $sth->fetchall_arrayref;
print "Number of rows returned is ", 0 + @{$ref}, "\n";
foreach my $r (@{$ref})
{
    print join(", ", @{$r}), "\n";
}



# my $table = $sth -> fetchall_arrayref or die "$sth -> errstr\n";
# my($i, $j);

# for $i ( 0 .. $#{$table}) {  for $j ( 0 .. $#{$table -> [$i]} )  
# {
# print "$table->[$i][$j]\t";
# }
# print "\n";
# }

print "\n";
my $sql1  = 'SELECT rey FROM rey';
            my $sth1  = $dbh->prepare($sql1) or die $dbh->errstr;
               $sth1->execute;
            my @rey_arr = $sth1->fetchrow_array();
            my $rey = $rey_arr[0];
print "rey - $rey\n";
 
