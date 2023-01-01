package Skynet::User;
use v5.36;

use Carp;
use parent qw(Skynet::Notifier);
use JSON;
use experimental 'try';
use Data::Dumper;

sub _init ($self, @params){
    $self->SUPER::_init( @params );

    $self->{'charName'} = '',
    $self->{'userName'} = '',
    $self->{'loggedIn'} = 0,
    $self->{'guild'}    = '',
    $self->{'allowed'}  = {
        'seespots' => 0,    # can see spots
        'seechat'  => 0,    # can see alliance chat
        'manuser'  => 0,    # can add/remove users
        'manwarr'  => 0,    # can add/remove warranty time
        'manstat'  => 0,    # can change kos, ally, status
        'seestat'  => 0,    # can see kos, ally, status
        'seewarr'  => 0,    # can see active warranties
        'addbot'   => 0,    # can add a bot user
        'commander'=> 0,    # is guild commander
    }
};

sub _msg_received ($self, $json_msg){
    #say "received: $json_msg";
    my $msg_ref;

    try{
        $msg_ref = from_json($json_msg);
    }
    catch ($e){
        my $username;
        if ($self->{userName}){
            $username = $self->{userName};
        }else{
            $username = "unlogged user";
        }
        print STDERR "Bad message from: ".$self->{userName}."\n";
        print STDERR "Could not decode the JSON text\n";
    }

    # good messages go to be dispatched
    if ($msg_ref){
        say $msg_ref->{action}." received";
    }

    # bad messages stop here by returning
    return;
}

sub guild_broadcast ($self, $json_msg){
    $self->parent->broadcast($json_msg);
}


sub playerseen ($self, $msg_ref){
    $self->guild_broadcast( to_json ( $msg_ref ));
}
1;
