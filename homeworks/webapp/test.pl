use strict;
use DBI;
use Data::Dumper;

my $dbh = DBI->connect("dbi:SQLite:dbname="."mywebapp") or die $DBI::errstr;
my $sql = 'SELECT user, pass,is_admin FROM user ;
my $sth = $dbh->prepare($sql) or die $dbh->errstr;
$sth->execute or die $sth->errstr;;
my $ref = $sth->fetchrow_hashref;

my ($key, $val) =  %$ref{'pass'};
print "$val \n"; 		

	 # 'user' => $sth->fetchrow_hashref('user'),
  #    'pass' => $sth->fetchrow_hashref('pass'),
	 # 'admin' => $sth->fetchrow_hashref('is_admin');

	 print Dumper$ref;

