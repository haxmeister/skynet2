package Skynet::User;
use v5.36;

use Carp;
use parent qw(IO::Async::Stream);
use JSON;
use experimental 'try';
use Data::Dumper;

sub _init ($self, @params){
    $self->SUPER::_init( @params );
    $self->{json} = JSON->new;

    $self->{'userdata'} = {

        'username' => '',
        'logged_in' => 0,
        'guild'     => '',
        'allowed'   => {
            'man_user'  => 0,    # can add/remove users
            'man_warr'  => 0,    # can add/remove warranty time
            'man_stat'  => 0,    # can change kos, ally, status
            'see_spots' => 0,    # can see spots
            'see_chat'  => 0,    # can see alliance chat
            'see_stat'  => 0,    # can see kos, ally, status
            'see_warr'  => 0,    # can see active warranties
        },
        'character' => {
            "factioncolor" => "",
            "guildname"    => "",
            "faction"      => "",
            "charname"     => "",
            "charid"       => "",
            "guildabbr"    => "",
        },
    };
}

# when data from this user is available in the buffer
sub on_read( $self, $buffref, $eof ){
    if ($eof){

        say $self->{userdata}{username}." as ".$self->{userdata}{character}{charname}." has disconnected";
        return
    }
    my $msg_ref;

    while( $$buffref =~ s/^(.*)\r\n// ) {
        my $json_msg = $1;

        try{
            $msg_ref = from_json($json_msg);
            #$self->parent->_msg_received( $msg_ref );
            say "valid message received:";
            say $self->{json}->pretty->encode ($msg_ref);

        }
        catch ($e){
            say "bad message received: ";
            say $json_msg;
        }
    }

    $self->dispatch($msg_ref);
    say $self->{'read_handle'}->peerhost;
    # return 1 to run this function immediately again
    # return 0 to move the loop on to check the next
    return 0;
}

sub send ($self, $msg_ref){
    my $json_msg;
    my $EOL = "\r\n";
    $json_msg =to_json($msg_ref);
    $self->write( $json_msg.$EOL );
    say "sent: ".$json_msg.$EOL;

}

sub ip ( $self ){
    return $self->{'read_handle'}->peerhost;
}

sub port( $self ){
    return $self->{'read_handle'}->portport;
}

sub username ($self, $name=''){
    if (! $name){
        return $self->{'userdata'}{'username'};
    }else{
        $self->{'userdata'}{'username'} = $name;
        say "assigned name: $name";
    }
}

sub charname ($self, $name=''){
    if (! $name){
        return $self->{'userdata'}{'character'}{'charname'};
    }else{
        $self->{'userdata'}{'character'}{'charname'} = $name;
        say "assigned name: $name";
    }
}

sub dispatch ($self, $msg){
    exists $msg->{action} or return;

    my %dispatch = (
        'login' => 1,
        'playerseen' => 1,
        'chat' => 1,
    );

    if ( not exists ($dispatch{ $msg->{action} } ) ){
        $self->skynet_error("no such action available: ".$msg->{action});
        return;
    }

    my $action = $msg->{action};
    $self->$action($msg);
    return;
}

sub login ($self, $msg){
    if (not exists $msg->{sender}{charname}){
        $self->skynet_error("Cannot log in without charname")
        return;
    }

    $self->{userdata}{character} = $msg->{sender};

    say "logging in: ".$msg->{username}.", ".$msg->{password}." as ".$self->{userdata}{character}{charname};

}

sub playerseen ($self, $msg){
    delete $msg->{sender};
    $self->parent->player_list_update($msg);
}

sub chat ($self, $msg){
    $msg->{'skynet_guild'} = $self->parent->name();
    #TODO check structure for valid message
    $self->parent->guild_broadcast($msg);
}

sub skynet_error($self, $msg){
    my $error = {
        "action" => "error",
    }
    self->send($error);
}
1;
