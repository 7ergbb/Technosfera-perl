package myapp::admin;
use Dancer2 appname => 'myapp';
 
prefix '/admin';
 
get '/' => sub {
    template 'login.tt';
};
 
 
1;

