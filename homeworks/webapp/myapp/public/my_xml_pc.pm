#!/usr/bin/env perl

use Frontier::Daemon;
use strict;
use DBI;
use Data::Dumper;
use warnings;
use HTTP::Headers;
use Encode;
use MIME::Base64;
use HTTP::Status;

use HTTP::Daemon; 


use FindBin;
require "$FindBin::Bin/../lib/evaluate.pl";
require "$FindBin::Bin/../lib/rpn.pl";



sub calc {
#     my $token = $server->request->header('Authorization');
#     if ($token =~ m{^\s*Basic\s*([^\s]+)}) {
# 	$token = decode_base64($1);
#     } else {
# 	return my $response = xml_response_fault("Authorization failed");
# }

    my ($input) = @_;
    my $rpn = rpn($input);
	my $value = evaluate($rpn);
    return $value;
}


 my $methods = {'sample.calc' => \&calc};
# my $server = Frontier::Daemon->new(LocalPort => 6000, methods => $methods)
     # or die "Couldn't start HTTP server: $!";

 my $server = HTTP::Daemon->new(LocalPort => 6000) or die; 
 my $coder = Frontier::RPC2->new;                                             

print "Contact URL: ", $server->url, "\n";                                          
while (my $connection = $server->accept) {                                                  
    while (my $request = $connection->get_request) {                                           
        print $request->as_string;
        unless( $request->header( 'Authorization' ) ) {                                                 
            $connection->send_response( make_challenge() )                                               
            }
        else {

            my $token = $request->header('Authorization');
            if ($token =~ m{^\s*Basic\s*([^\s]+)}) {
     	       $token = decode_base64($1);
               }
            $coder->serve($request->content,$methods);
            print"\n++++$token++++++++";
            $connection->send_response( make_response() )                                               
            }   
        }                                                                             
    $connection->close;                                                                   
    }  

sub make_challenge {
    my $response = HTTP::Response->new( 
        401 => 'Authorization Required',
        [ 'WWW-Authenticate' => 'Basic realm="Buster"' ],
         );
    }

sub make_response {
    my $response = HTTP::Response->new( 
        200 => 'Cool!',
        [ 'Content-type' => 'text/xml' ],
         );

    $response->message( 'Cool!' );
    }



