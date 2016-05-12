        package myapp;
        use Dancer2;
        use DBI;
        use DBD::SQLite;
        use Dancer2::Plugin::Passphrase;
        use Template;
        use Frontier::Client;
        use utf8;
        use HTTP::Request;
        use HTTP::Response;
        our $VERSION = '0.1';

        set 'template' => 'template_toolkit';
        set 'session'  => 'Simple';
        set 'logger'   => 'console';
        set 'log'      => 'debug';
        set 'charset'  => 'UTF-8';

        prefix undef;

        get '/' => sub {
            if ( session('logged_in') or session('admin_in') ) {
                template 'index';
            }
            else { redirect('/login') }
        };

        get '/reg' => sub {
            template 'reg.tt';
        };

        ################################################################################################

        post '/reg' => sub {

            my $user = body_parameters->get('user');
            my $pass = passphrase( body_parameters->get('pass') )
                ->generate;    # хэш пароля в RFC 2307
            $pass = $pass->rfc2307()
                ;    # убираем все лишнее из хэша
            my $fio   = body_parameters->get('fio');
            my $link  = body_parameters->get('url_link');
            my $admin = 0;
            my $xml_rpc_token
                = passphrase->generate_random;   # генерими токен

            my $db = connect_db();

            my $sql
                = 'insert into user (user, pass, fio, url_link, token, is_admin, lim) values (?,?,?,?,?,?,?)';
            my $sth = $db->prepare($sql) or die $db->errstr;

            $sth->execute( $user, $pass, $fio, $link, $xml_rpc_token, $admin,
                get_rey() )
                or die $sth->errstr;

            redirect '/login';

        };

        ################################################################################################

        get '/login' => sub {
            template 'login.tt';
        };

        ################################################################################################

        post '/login' => sub {

            my $user_value = body_parameters->get('user');
            my $pass_value = body_parameters->get('pass');

            my $db  = connect_db();
            my $sql = 'SELECT user, pass,is_admin FROM user WHERE user =?';
            my $sth = $db->prepare($sql) or die $db->errstr;

            $sth->execute($user_value) or die $sth->errstr;
            my ( $user, $pass, $admin );
            $sth->bind_col( 1, \$user,  undef );
            $sth->bind_col( 2, \$pass,  undef );
            $sth->bind_col( 3, \$admin, undef );

# Теперь $user и $pass, $admin -  привязаны к соответствующим полям выходных данных
            $sth->execute;
            while ( $sth->fetch ) { }
            if (    $user
                and passphrase($pass_value)->matches($pass)
                and $admin != 1 )
            {
                session 'logged_in' => true;
                session username    => $user;
                template 'index.tt', { 'user' => session('username'), };
            }

            elsif ( $user
                and passphrase($pass_value)->matches($pass)
                and $admin == 1 )
            {
                session 'admin_in' => true;
                session username   => $user;
                template 'index.tt', { 'user' => session('username'), };
            }

            elsif ( !$user ) { redirect '/login'; }

        };

        ################################################################################################

        get '/token' => sub {

            access_check();

            my $user = session('username');
            my $db   = connect_db();
            my $sql  = 'SELECT token FROM user WHERE user =?';
            my $sth  = $db->prepare($sql) or die $db->errstr;
            my $token;
            $sth->execute($user) or die $sth->errstr;
            $sth->bind_col( 1, \$token, undef );
            $sth->execute;
            while ( $sth->fetch ) { }
            template 'mytoken.tt', { 'token' => $token, };
        };

        ################################################################################################

        post '/token' => sub {

            my $user      = session('username');
            my $new_token = passphrase
                ->generate_random;    # генерими new токен
            my $db  = connect_db();
            my $sql = 'UPDATE user SET token=? WHERE user=?';
            my $sth = $db->prepare($sql) or die $db->errstr;
            $sth->execute( $new_token, $user ) or die $sth->errstr;
            redirect '/token';
        };

        ################################################################################################

        get '/edit' => sub {

            access_check();

            my $user = session('username');
            my $db   = connect_db();
            my $sql  = 'SELECT * FROM user WHERE user =?';
            my $sth  = $db->prepare($sql) or die $db->errstr;
            $sth->execute($user) or die $sth->errstr;
            my $ref  = $sth->fetchrow_hashref;
            my $pass = %$ref{'pass'};
            my $fio  = %$ref{'fio'};
            my $url  = %$ref{'url_link'};

            template 'edit.tt',
                {
                'user'     => $user,
                'pass'     => $pass,
                'fio'      => $fio,
                'url_link' => $url,
                };
        };

        ################################################################################################

        post '/edit' => sub {
            my $user = session('username');
            my $fio  = body_parameters->get('fio');
            my $link = body_parameters->get('url_link');

            my $db  = connect_db();
            my $sql = 'UPDATE user SET fio=?, url_link=? WHERE user=?';
            my $sth = $db->prepare($sql) or die $db->errstr;
            $sth->execute( $fio, $link, $user ) or die $sth->errstr;
            $sth->finish;
            redirect '/edit';

        };

        ################################################################################################

        any '/logout' => sub {
            app->destroy_session;
            redirect '/login';

        };

        ################################################################################################

        post '/pass' => sub {
            my $user     = session('username');
            my $new_pass = passphrase( body_parameters->get('pass') )
                ->generate;    # хэш пароля в RFC 2307
            $new_pass = $new_pass->rfc2307();    # убираем все лишнее из хэша

            my $db  = connect_db();
            my $sql = 'UPDATE user SET pass=?  WHERE user=?';
            my $sth = $db->prepare($sql) or die $db->errstr;
            $sth->execute( $new_pass, $user ) or die $sth->errstr;
            $sth->finish;
            redirect '/edit';

        };

        ################################################################################################

        post '/del/:name' => sub {
            my $user = params->{name};
            my $db   = connect_db();
            my $sql  = 'DELETE FROM user WHERE user=?';
            my $sth  = $db->prepare($sql) or die $db->errstr;
            $sth->execute($user) or die $sth->errstr;
            $sth->finish;
            if ( session('admin_in') ) {
                redirect '/usersdell';
            }
            else {
                app->destroy_session;
                redirect '/login';
            }

        };

        ################################################################################################

        get '/allusers' => sub {

            my $db = connect_db();
            my @vars;
            my $sql = 'SELECT user,fio, url_link, token,lim FROM user';
            my $sth = $db->prepare($sql) or die $db->errstr;
            $sth->execute() or die $sth->errstr;
            my $allusers = $sth->fetchall_arrayref;

            template 'allusers.tt', { 'allusers' => $allusers, };

        };

        ################################################################################################

        get '/usersdell' => sub {

            if ( !session('admin_in') ) {
                redirect '/';
            }

            my $db = connect_db();
            my @users_arr;
            my $sql = 'SELECT user FROM user';
            my $sth = $db->prepare($sql) or die $db->errstr;
            $sth->execute() or die $sth->errstr;
            while ( my @user = $sth->fetchrow_array ) {
                push @users_arr, @user;
            }

            template 'usersdell.tt', { 'users' => \@users_arr, };

        };

        ################################################################################################

        get '/rey' => sub {

            if ( !session('admin_in') ) {
                redirect '/';
            }
            my $rey = get_rey();
            template 'rey.tt', { 'rey' => $rey, }

        };

        ################################################################################################

        post '/rey' => sub {
            if ( !session('admin_in') ) {
                redirect '/';
            }
            my $new_rey = body_parameters->get('rey');

            my $db = connect_db();

            # обновляем рейт
            my $sql = 'UPDATE rey SET rey=?';
            my $sth = $db->prepare($sql) or die $db->errstr;
            $sth->execute($new_rey) or die $sth->errstr;
            my $success
                = '<div class="alert alert-success">рей-лимит обновлен</div>';

# обновляем рейт-лимит для каждого пользователя

            my $update_sql = 'UPDATE user SET lim=?';
            $sth = $db->prepare($update_sql);
            $sth->execute($new_rey);

            template 'rey.tt',
                {
                'success' => $success,
                'rey'     => $new_rey,
                };

        };

        ################################################################################################
        #  XML RPC  клиент
        ################################################################################################
        ######## отображение страницы с отправкой выражений для калькулятора + проверка доступности сервиса XML-RPC

        get '/reqxml' => sub {
            my $server_status = server_check();

            template 'reqxml.tt',
                {     'server_status' => '<div class="alert alert-success">'. $server_status. '</div>', };

        };
        ######### отправка на вычисление и отображение результатов
        post '/reqxml' => sub {
            my $arg      = body_parameters->get('arg');
            my $req_time = time()
                ; # время операции -как количество секунд, прошедших с начала эпохи(1970)
            my $user = session('username');

            my $db  = connect_db();
            my $sql = 'SELECT id, token, lim FROM user WHERE user=?';
            my $sth = $db->prepare($sql) or die $db->errstr;
            $sth->execute($user) or die $sth->errstr;
            my ( $id, $token, $rey );
            $sth->bind_col( 1, \$id,    undef );
            $sth->bind_col( 2, \$token, undef );
            $sth->bind_col( 3, \$rey,   undef );
            while ( $sth->fetch ) { }
            $sql
                = 'SELECT  COUNT (*) FROM calc WHERE user_id=? AND calc_time >=?';
            $sth = $db->prepare($sql) or die $db->errstr;
            $sth->execute( $id, $req_time - 60 ) or die $sth->errstr;
            my @calc_arr   = $sth->fetchrow_array();
            my $calc_count = $calc_arr[0];

            if ( $calc_count < $rey ) {


                my $server_url = 'http://127.0.0.1:6000/RPC2';
                my $server     = Frontier::Client->new(url => $server_url) or die "Не могу выполнить : $!";
                $server->{'rq'}->header('Authorization' => 'Basic dG9rZW46enlTNTJTZERIMlBtaG1EWQ==');

              

              # my $req = HTTP::Request->new(GET => "$server_url" );                       
              #    $req->authorization_basic('token', $token);                                  
              # my $result = $server->request($req);



                 my $result = $server->call( 'sample.calc', $arg ) or die "Не могу выполнить : $!";

                $sql= 'insert into calc (user_id, token, calc_time) values (?,?,?)';
                $sth = $db->prepare($sql) or die $db->errstr;
                $sth->execute( $id, $token, $req_time ) or die $sth->errstr;

                template 'reqxml.tt', {
                    'res' => $result,

                };

            }

            else {

                template 'reqxml.tt', {
                    'res' =>
                        'у Вас вышел лимит на запросы к серверу',
                };
            }
        };
        ################################################################################################

        sub get_rey {

            my $db  = connect_db();
            my $sql = 'SELECT rey FROM rey';
            my $sth = $db->prepare($sql) or die $db->errstr;
            $sth->execute;
            my @rey_arr = $sth->fetchrow_array();
            my $rey     = $rey_arr[0];
            return $rey;
        }
        ################################################################################################
        sub connect_db {
            my $dbh = DBI->connect( "dbi:SQLite:dbname=" . "mywebapp" )
                or die $DBI::errstr;

            return $dbh;
        };
        ################################################################################################
        # ф-я проверки сесии под пользователем (!админ)
        ################################################################################################
        sub access_check {
            if ( !session('logged_in') ) {
                redirect '/';
            }
        }

        ################################################################################################
        # ф-я проверки доступности сервера XML-RPC
        ################################################################################################
        sub server_check {
            my $count = my $err = 0;
            while ( $count <= 8 ) {
                my $server_url = 'http://127.0.0.1:6000/RPC2';
                my $ua         = LWP::UserAgent->new;
                $ua->timeout(600);
                $ua->agent(
                    "Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.0; MyIE2)"
                );
                my $req = HTTP::Request->new( GET => $server_url );
                my $res = $ua->request($req);
                my $str = $res->status_line;

                if ( $str ne "403 Forbidden" ) {
                    $err++;
                }

                $count++;

            }
            my $out = '';
            if ( $err == 0 ) {
                $out
                    = "серевер готов к приему запросов";
            }
            elsif ( $err >= 1 and $err <= 7 ) {
                $out
                    = "серевер доступен, НО возможны сбои в работе";
            }
            elsif ( $err >= 8 ) {
                $out
                    = "серевер не доступен, обратитесь к администратору";
            }

            return $out;
        }

        # dance;
        1;
