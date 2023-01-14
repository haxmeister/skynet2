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

    $self->{'user_data'} = {
        'char_name' => '',
        'user_name' => '',
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
        }
    };

};

# when data from this user is available in the buffer
sub on_read( $self, $buffref, $eof ){
    if ($eof){

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

    say $self->{'read_handle'}->peerhost;
    # return 1 to run this function immediately again
    # return 0 to move the loop on to check the next
    return 0;
}

sub send ($self, $msg_ref){
    my $json_msg;
    my $EOL = "\r\n";
    try{
        $json_msg =to_json($msg_ref);
    }
    catch ($e){
        say STDERR "Failed to convert message to json: ".$e;
    }

    $self->write( $json_msg.$EOL );

}

sub ip ( $self ){
    return $self->{'read_handle'}->peerhost;
}

sub port( $self ){
    return $self->{'read_handle'}->portport;
}

sub username ($self, $name=''){
    if (! $name){
        return $self->{'user_data'}{'user_name'};
    }else{
        $self->{'user_data'}{'user_name'} = $name;
    }
}
1;
