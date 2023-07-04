package Skynet::Server;

use v5.36;

use IO::Async::Loop;
use IO::Async::Listener;
use IO::Async::Timer::Periodic;
#use Skynet::User;
use Skynet::Database;

my $dbh;
my $loop = IO::Async::Loop->new();

$loop->add(
    IO::Async::Timer::Periodic->new(
        interval => 30,
        on_tick  => sub {
            say "tick";
        },
    )->start()
);


sub start ($config){
    $dbh = Skynet::Database::_init(
        'username' => $config->{database}{username},
        'password' => $config->{database}{password},
    );

    $loop->listen(
        service  => $config->{server}{port},
        socktype => 'stream',

        on_accept => sub{
            my (undef, $socket) = @_;
            my $newuser = Skynet::User->new(
                handle => $socket,
                dbh    => $dbh,
            );
            $loop->add($newuser);

            my $address = $socket->peerhost . ":" . $socket->peerport;
            say "new user connected at ".$address;
        },
    )->get;

    say "Listening on port ".$config->{server}{port};
    $loop->run;
}

1;
