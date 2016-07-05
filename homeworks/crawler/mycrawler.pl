#!/usr/bin/env perl
use 5.010;
use strict;
use AnyEvent;
use AnyEvent::HTTP;
use Getopt::Long;
use HTML::Parser;
use DDP;

 $AnyEvent::HTTP::MAX_PER_HOST = 100; 
my $url;
my $help;
my $count = 0;

GetOptions("url=s" => \$url, "h" => \$help);
if (defined $help) {
	print "пример ввода --url=https://mail.ru/ \n";
	exit;
}
if (!defined $url) {die "не введен адрес url"};
if ($url !~ /https?:\/\/(.*?)\..+/) {
	die "Неправильный синтаксис URL";
}
my $host = $1;
print "---------".$host."\n";
my @urls = $url;
my %seen;
my $url_count = 0;
p $host;
$| = 1;

while (@urls) {
       	
    my $link = shift @urls;
	   # print "I am looking at-".$link."\n"; 
	   next if exists $seen{$link};
	my $cv = AnyEvent->condvar;
	   $cv->begin;
	   http_get $link,
	            sub {
     	              
     	                  my ($html) = @_;
     	                  my $size = length $html;
			     	      	$seen{$link} = $size;
			     	      	$count+=1;
			     	       		while($html =~m/(.+?)(?<=href=")(.+?)(?=["│ ])/gi)
					         		{   	
							  	  		my $scratched  = $2; 
								  		if (substr ($scratched,0,4) eq "http") 
								         {  
								           $scratched =~m/^(http)s?\:\/\/(.+)/gi ;
								           my $thisurl = $2;
								           if ((index $thisurl, $host,0) eq 0 && !exists($seen{$scratched})) 
		                                     {
		                              	      push @urls, $scratched; 
		                              	      print "а есть ли оно в хеше".$seen{$scratched}."\n"; 
		                                     print "this - URL for host ".$host."----".$scratched."\n";
											 print $count."\n";
											 }	
					                      }
					                }
					    $cv->end;
					};
			
        				$cv->recv;
                        
}


