package Skynet::Server;

use v5.36;

use IO::Async::Loop;
use IO::Async::Listener;
use IO::Async::Timer::Periodic;

use Skynet::User;
use Skynet::Database;

sub new ($class, $config){
    my $self = {
        'config' => $config,
        'loop' => IO::Async::Loop->new,
        'users' => {},
        'guilds' =>{},
        'alliances' =>{},
        'ticker' => '',
        'listener' => '' ,
    };

    bless $self, $class;

    $self->_init();
    return $self;
}

sub _init($self){

    $self->{'ticker'} = IO::Async::Timer::Periodic->new(
        interval => 30,
        on_tick  => sub {
            say "tick";
        },
    );

    $self->{'listener'} = IO::Async::Listener->new(
        on_accept => sub{
            my (undef, $socket) = @_;
            my $newuser = Skynet::User->new($socket, $self);

            my $address = $socket->peerhost . ":" . $socket->peerport;

            say "new user connected at ".$address;
            $newuser->username($address);

            # adduser to user list
            $self->{users}{$newuser} = $newuser;

        },
    );

    $self->{'loop'}->add( $self->{'listener'} );
    $self->{'ticker'}->start();
    $self->{'loop'}->add( $self->{'ticker'} );
    $self->{'db'} = Skynet::Database->new(
        'username' => $self->{config}->{database}{username},
        'password' => $self->{config}->{database}{password},
    );

}

sub listen ($self){
    my $port = $self->{config}->{server}{port};
    $self->{'listener'}->listen(
        service  => $port,
        socktype => 'stream',
    )->get;

    say "Listening on port ".$port;
    $self->{'loop'}->run;
}

sub add_user($self, $user){
    $self->{users}{$user} = $user;
}

sub rem_user($self, $user){
    if (exists($self->{users}{$user}) ){
        delete $self->{users}{$user};
    }
}

sub get_user_by_username($self, $name){
    foreach my $user (keys(%{ $self->{users} })){
        if ($user->username() eq $name){
            return $user;
        }
    }
    return 0;
}

1;
