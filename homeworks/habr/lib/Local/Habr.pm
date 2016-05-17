package Local::Habr;

use strict;
use warnings;
use Config::YAML;
use FindBin '$Bin';
use Getopt::Long;
use HTTP::Request;
use Data::Dumper;
use DBI;
use DBD::SQLite;
use Cache::Memcached::Fast;
use LWP::UserAgent;
use Mojo::DOM;
use DDP;
use JSON::XS;
use Exporter 'import';
our @EXPORT = qw(out);
no warnings 'experimental';	

=encoding utf8

=head1 NAME

Local::Habr - habrahabr.ru crawler

=head1 VERSION

Version 1.00

=cut

our $VERSION = '1.00';

=head1 SYNOPSIS

=cut

our $config = Config::YAML->new( config => "$Bin/../conf.yaml" );
our $site = $config->{'site'}->[0];
our $mem_adr = $config->{'memcached'}->[0];
our $dbname = $config->{'dbase'}->[0];

our $db = DBI->connect_cached( "dbi:SQLite:dbname=$Bin/../$dbname" )or die $DBI::errstr;

our $memd = new Cache::Memcached::Fast({  
            servers         => [ $mem_adr],
            namespace       => 'haha',
            connect_timeout => 0.1
        });
 

##########################################################################
#user
##########################################################################
sub get_user_site {
	my ($site_user, $flag) = @_;
	 my $user;
	my $ua = LWP::UserAgent->new(
		agent => 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_2)', 
		timeout => 10);
    my $request = HTTP::Request->new(GET => "$site/users/$site_user");
    my $response = $ua->request($request);
		  # print $response->content;

	if ($response->is_success()) {
		$user = parse_site_user($response->content);
	} 
	else {  print "\n Нет пользователя - $site_user на $site";}
    
    my %user_data; 
       %user_data = %$user;
       %user_data = (%user_data, 'nick',  $site_user);
    
    # print Dumper \%user_data;

    if (!defined $flag){ msave_user(\%user_data)}
    dsave_user (\%user_data);  

    return \%user_data;
};
##########################################################################
sub msave_user {
	my $user = shift;
    my $key = $user->{nick};
	 $memd->set($key,$user); 

};

##########################################################################

sub dsave_user {
	my $user = shift;

	my $sql = 'select nic from User where nic=?'; # есть ли в БД уже такой  user
    my $sth = $db->prepare($sql) or die $db->errstr;
       $sth->execute($user);
    my @user_arr = $sth->fetchrow_array();
    my $user_in_db     = $user_arr[0];
   
     if (!defined $user_in_db){
	    my $sql = 'insert or replace into User (nic, karma, rating) values (?,?,?)';
	    my $sth = $db->prepare($sql) or die $db->errstr;
	       $sth->execute($user->{nick}, $user->{karma} , $user->{rating} ) or die $sth->errstr;
    }
};



##########################################################################
sub parse_site_user {

    my $user_content = shift;
    my $dom          = Mojo::DOM->new($user_content);
    my $user_karma = $dom->at('div[class="voting-wjt__counter-score js-karma_num"]');
    if ( !defined $user_karma ) { $user_karma = -999 }    #read-only user
    else {
        $user_karma = $user_karma->text;
    }
    $user_karma =~ s/,/\./;

    my $user_rating = $dom->at('div[class="statistic__value statistic__value_magenta"]');
    if ( !defined $user_rating ) { $user_rating = -999 }    #read-only user
    else {
        $user_rating = $user_rating->text;
    }
    $user_rating =~ s/,/\./;

    my %hash = ( 'karma', $user_karma, 'rating', $user_rating );

    return \%hash;
}

##########################################################################
 
sub get_user {
    my ($nick, $flag) = @_;
    my $user = $memd->get($nick);    # ищем в memca...
    if ( defined $user ) {
        return $user
    }
    else {
        $user = $db->selectrow_hashref('select nic, karma, rating from User where nic = ?', undef, $nick );
        if ( !defined $user and !defined $flag ) {
        	print "\n Такого пользователя нет в БД и memcached. Выполните запрос с параметорм --refresh \n";
        
        }
        if (!defined $user and defined $flag ){ $user = get_user_site($nick) }
        
        return $user;

    }
}

##########################################################################
#post
##########################################################################
sub get_post_site {
	my $post_id = shift;
	my $post;
	my $ua = LWP::UserAgent->new(
		agent => 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_2)', 
		timeout => 10);
    my $request = HTTP::Request->new(GET => "$site/post/$post_id");
    my $response = $ua->request($request);
		  # print $response->content;

	if ($response->is_success()) {

		$post = parse_site_post($response->content);
	} 
	else {  print "\n Нет поста с id - $post_id на $site";}

	my %post_data = %$post;
	   %post_data =(%post_data, 'id', $post_id);
     
    dsave_post (\%post_data);

    return \%post_data;
    
};

##########################################################################
#автор, тема, общий рейтинг, количество просмотров, количество звезд.

sub parse_site_post{
     my $post_content = shift;
     my $dom          = Mojo::DOM->new($post_content);

     my $author = $dom->at('div[class="author-info__username"]');

        $author = $author->at('a["href"]');
    if (!defined $author){
        $author = $dom->at('div[class="post-type"]');
		$author = $author->at('a["href"]');
		if ($author =~ m/users\/([^\/]*)\" title="\W+/ ){
			$author=$1;
		}

    }   
      

	if ($author =~ m/users\/([^\/]*+)\// ) {
		$author = $1;

	}
	elsif ($author =~ m/(company)\/*\//) {             #если пост комании 
		$author = $dom->at('div[class="post-type"]');
		$author = $author->at('a["href"]');
		if ($author =~ m/users\/([^\/]*)\" title="\W+/ ){
			$author=$1;
		}
	}
    my $post_name = $dom->at("title")->text;
    my $post_rating = $dom->at('span[class="voting-wjt__counter-score js-score"]');
        if ( !defined $post_rating) {$post_rating = 0}
        else {$post_rating=$post_rating->text};

    my $views = $dom->at('div[class="views-count_post"]')->text;
       $views =~ s/,/\./;
	   $views =~ s/k/e\+3/; 
	   $views = 0+ $views;
     
    my $stars = $dom->at('span[class="favorite-wjt__counter js-favs_count"]')->text;
    my $coments_num = $dom->at('span[id="comments_count"]')->text;
    my $owner_coments = $dom->at('div[class="info comments-list__item comment-item is_topic_starter "]');
       if ( defined $owner_coments) {$owner_coments = 1}
           else { $owner_coments = 0};
    my %commenter;
    my $commenters_all = $dom->find('span[class="comment-item__user-info"]');
    my $count= scalar(@$commenters_all)-1;
       for (0..$count) {
		  my $nick = $commenters_all->[$_]->attr("data-user-login");
		  $commenter{$nick} = ":)";
	    };
	my %parse_post = ('author', $author, 'post_name', $post_name, 'post_rating', $post_rating, 'views', $views, 'stars', $stars,
	'coments_num', $coments_num, 'commenters', \%commenter, 'owner_coments', $owner_coments  );
	
	return  \%parse_post;


};

##########################################################################
sub dsave_post {
	my $arg = shift;
	my %post = %$arg;
    my $user = $post{author};
      
    get_user_site($user); # добавляем, если нет, автора в таблицу 

    my $user_id = $db->selectrow_hashref('select id from User where nic = ?', undef, $user ); # получаем id  пользователя 


    
    ### добавляем данные поста в БД
    my $sql = 'insert or replace into Post(id, author_id, post_name, post_rating, views, stars, owner_coments, coments_num)
                values (?,?,?,?,?,?,?,?)';    
	my $sth = $db->prepare($sql) or die $db->errstr;
	   $sth->execute($post{id}, $$user_id{id}, $post{post_name}, $post{post_rating}, $post{views},
	    $post{stars}, $post{owner_coments}, $post{coments_num} ) or die $sth->errstr;
    
    ### добавляем данные о пользователях комментирующих этот пост 
    
		my @commenters = keys $post{commenters};

        $sth = $db->prepare( qq(insert or replace into Comments (post_id, user_id ) values ($post{id}, ?)));
		# $sth = $db->prepare( qq(insert or replace into Comments (post_id, user_id ) values ($post{id}, ?)));
		$db->prepare("BEGIN IMMEDIATE TRANSACTION")->execute;  #одна транзакция для всех  insert-ов  коментаторов
		foreach(@commenters){                                  # иначе, будет очень долго писать в БД
          get_user_site($_,1);
          my $id = $db->selectrow_hashref('select id from User where nic = ?', undef,$_);
          $sth->execute($$id{id});      
		} 
		$db->prepare("COMMIT TRANSACTION")->execute;
};
##########################################################################
sub get_post {
 my ($post_id, $flag) = @_;
 my $post = $db->selectrow_hashref('select author_id, post_name, post_rating, views, stars, coments_num
 	                                from Post where id=?', undef, $post_id);
if (!defined $post and defined $flag){ 
	$post = get_post_site($post_id);
};
if (!defined $post and !defined $flag) {
	print "\n В базе нет поста, с таким ID. Выполните команду с параметром --refresh\n ";
    # my %z =('0',0);
	%$post = (0,0);
}
return $post;
};
##########################################################################
sub get_post_author {
 my ($post_id, $flag) = @_;
 my $post;
 if (defined $flag) {$post = get_post($post_id,1)}  
 else {$post = get_post($post_id)};
 my $author = $$post{author_id};
 my $user = $db->selectrow_hashref('select nic, karma, rating from User where id = ?', undef, $author );
 if ( !defined $user) {
        	print "\n Такого пользователя нет в БД и memcached. Выполните запрос с параметорм --refresh \n";
        	%$user = (0,0); 
        }
 return $user;
};




##########################################################################
sub get_commenters {
my ($post_id, $flag) = @_;

	if ( defined $flag){
	my $post = get_post ($post_id, 1); # обновим ин-ю о посте,если установлен флаг в агрументах ф-ии
	}

	my $post_commenters = $db->selectall_arrayref("select distinct User.nic as nic, User.karma as karma, User.rating as rating
		from User JOIN Comments ON (Comments.post_id=$post_id  and Comments.user_id=User.id)",{Slice => {} });
    if (!defined @$post_commenters[0]) {print "\n В базе нет поста, с таким ID. Выполните команду с параметром --refresh\n "}	 
	return $post_commenters;
};

##########################################################################
sub get_self_commentors {
my $self_commentors = $db->selectall_arrayref("select distinct User.nic as nic, User.karma as karma, User.rating as rating
		from User JOIN Post ON (User.id=Post.author_id  and  Post.owner_coments =1)",{Slice => {} }); 
# print Dumper $self_commentors;
return $self_commentors;
};

##########################################################################
sub get_desert_posts {
    my $n = shift;
	my $desert_post = $db->selectall_arrayref( "SELECT User.nic AS nic, Post.post_name AS post_name, Post.post_rating AS post_rating,
												Post.views AS views, Post.stars AS stars FROM Post JOIN User on 
												(User.id=Post.author_id and Post.coments_num <$n)", { Slice => {} });
	# print Dumper $desert_post;
	return $desert_post;
};

##########################################################################адок:)
sub out {
    my $arg = shift;
    my %options;
    $options{format} = 'json';    # по умолчанию формат  json
    if ( $arg eq 'self_commentors' ) {
        GetOptions( \%options, 'format=s', 'refresh' );
        my $self_commentors = get_self_commentors();
        for my $hash (@$self_commentors)
        {    #так как ссылка на массив
            if ( $options{format} eq 'json' ) {
                my %out      = %$hash;
                my $json     = JSON::XS->new;
                my $json_out = $json->encode( \%out );
                print "\n$json_out\n";
            }
            if ( $options{format} eq 'ddp' ) {
                p $hash;
            }
        }

    }

    if ( $arg eq 'desert_posts' ) {

        GetOptions( \%options, 'n=s', 'format=s', 'refresh' );
        my $desert_posts = get_desert_posts( $options{n} );
        for my $hash (@$desert_posts) {
            if ( $options{format} eq 'json' ) {
                my %out      = %$hash;
                my $json     = JSON::XS->new;
                my $json_out = $json->encode( \%out );
                print "\n$json_out\n";
            }
            if ( $options{format} eq 'ddp' ) {
                p $hash;
            }
        }

    }
    
    if ( $arg eq 'commenters' ){
        GetOptions( \%options, 'post=s', 'format=s', 'refresh' );
        my $commenters;
        if ( $options{refresh} ) {$commenters = get_commenters($options{post},1)}
        else {$commenters = get_commenters($options{post})}
        for my $hash (@$commenters) {
            if ( $options{format} eq 'json' ) {
                my %out      = %$hash;
                my $json     = JSON::XS->new;
                my $json_out = $json->encode( \%out );
                print "\n$json_out\n";
            }
            if ( $options{format} eq 'ddp' ) {
                p $hash;
            }
        }
    }
    if ( $arg eq 'post' ){
       GetOptions(\%options, 'id=s', 'format=s', 'refresh');
		my $post;
		if ( $options{refresh} ){$post = get_post($options{id},1)}
		else {$post = get_post($options{id})}
		for my $hash ($post){
             if ( $options{format} eq 'json' ) {
                my %out      = %$hash;
                my $json     = JSON::XS->new;
                my $json_out = $json->encode( \%out );
                print "\n$json_out\n";
            }
            if ( $options{format} eq 'ddp' ) {
                p $hash;
            }

		}


    }
    if ($arg eq 'user') {
		GetOptions(\%options, 'name=s', 'post=s', 'format=s', 'refresh');
		my $user;
		if (defined $options{name}) {
			if ($options{refresh}) { $user = get_user($options{name},1); }
			else {$user = get_user($options{name});}
		      for my $hash ($user){
                if ( $options{format} eq 'json' ) {
                my %out      = %$hash;
                my $json     = JSON::XS->new;
                my $json_out = $json->encode( \%out );
                print "\n$json_out\n";
            }
            if ( $options{format} eq 'ddp' ) {
                p $hash;
            }
		  }
		}
        if (defined $options{post}){
            GetOptions(\%options, 'post=s', 'format=s', 'refresh');
		    my $user;
		    if ( $options{refresh} ){$user = get_post_author($options{post},1)}
		    else {$user = get_post_author($options{post})}
                  for my $hash ($user){
	                if ( $options{format} eq 'json' ) {
	                my %out      = %$hash;
	                my $json     = JSON::XS->new;
	                my $json_out = $json->encode( \%out );
	                print "\n$json_out\n";
            }
            if ( $options{format} eq 'ddp' ) {
                p $hash;
            }
		  }



        }
    }

}


##########################################################################

1;
