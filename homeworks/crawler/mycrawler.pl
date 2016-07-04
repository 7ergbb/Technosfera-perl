#!/usr/bin/env perl
use 5.010;
use strict;
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
my @urls = $url;
my %seen;
my $url_count = 0;
my $url = shift @urls;
	if (exists $seen{$url}) next;
	my $cv = AnyEvent->condvar;
	$cv->begin;
	http_get $url,
     sub  {
     	my ($href) = @_;
     	my $size = length $html;
     	    $seen{$url};
     	    $count+=1;



     };

