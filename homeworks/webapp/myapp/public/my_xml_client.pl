use Frontier::Client;
use HTTP::Request;
use LWP::UserAgent;
use LWP;

         my $token ='rrererererererer';
         my $server_url = 'http://127.0.0.1:6000/RPC2';
         # my $server_url = 'http://127.0.0.1:7000/'
         my $ua = LWP::UserAgent->new('Mozila');
         my $req = HTTP::Request->new(GET => "$server_url" );                       
		    $req->authorization_basic('token', $token);                                  
		 my $res = $ua->request($req);
		 print $res->content;


# $ua = LWP::UserAgent->new();
# $req = HTTP::Request->new(GET => "$url" );

# #when these values are hardcoded the autorization is ok 
# $req->authorization_basic('T1isUserok','AnyPa223d');

# #when I use these same values as parms this same code fails

#  $req->authorization_basic($user,$passwd);

# ##continue

# $req->header('Accept', => 'text/html');

# $response = $ua->request($req);


# print $response->content;







# my $ua = LWP::UserAgent->new('Mozilla');                                        
# $ua->credentials("127.0.0.1:7000", "realm-name", 'user_name', 'some_pass');                       
# my $res = $ua->get('http://127.0.0.1:7000/');                  

# print $res->content;


# # Make an object to represent the XML-RPC server.
# $server_url = 'http://127.0.0.1:6000/RPC2';
# $server = Frontier::Client->new(url => $server_url);
# if ($server) {
#                 print www;
#         }
#  else {print lllllllll;}   


# # Call the remote server and get our result.
# my $result = $server->call('sample.calc', '(200)*4');

#  else {print lllllllll;}       
# my $dat = $result->{'calc'};


# print "Result is : $result";
