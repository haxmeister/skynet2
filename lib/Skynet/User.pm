package Skynet::User;
use v5.36;

use Carp;
use JSON;
use experimental 'try';
use Data::Dumper;
my $pretty = JSON->new();
$pretty->pretty(1);

sub new ($class, $socket, $server){
    my $self = {
        'username'  => '',
        'logged_in' => 0,
        'socket'    => $socket,
        'stream'    => '',
        'server'    => $server,
        'last_channel' => '',
        'shares'    => {},

        'character' => {
            "factioncolor" => "",
            "guildname"    => "",
            "faction"      => "",
            "name"         => "",
            "charid"       => "",
            "guildabbr"    => "",
        },
    };

    bless $self, $class;

    $self->_init();
    return $self;
}

sub _init($self){
    $self->{'stream'} = IO::Async::Stream->new(
        handle  => $self->{'socket'},
        on_read => sub {
            my ( $stream, $buffref, $eof ) = @_;
            while( $$buffref =~ s/^(.*)\r\n// ) {
                my $msg_txt = $1;
                say "Received a line: $msg_txt";
                my $msg_hash = '';
                try{
                    $msg_hash = decode_json ($1);
                    if ($msg_hash){
                        $self->dispatch($msg_hash);
                    }else{
                        die;
                    }
                }
                catch ($e){
                    say $e;
                }

            }

            if( $eof ) {
                print "EOF; last partial line is $$buffref\n";
                $self->alliance->removeuser($self);
                $self->stream->close_when_empty;
                say $self->username."logged off";
            }

            return 0;
        }
    );

    $self->loop->add($self->{'stream'});
}

# Recieves a decoded message as a hash ref and dispatches
# to the proper method based on recognized "action" values
sub dispatch ($self, $hash){
    return unless exists $hash->{'action'};
    my $action = $hash->{'action'};

    if ( $self->is_valid_action($action) ){
        $self->$action($hash);
    }
}


sub send ($self, $hash){

    my $msg = encode_json $hash;
    $msg = $msg."\r\n";
    say "sending: $msg";
    $self->{'stream'}->write($msg);
}

sub login ($self, $hash){
    $self->{'username'}  = $hash->{'username'}; # assuming login for now

    if ( $self->is_valid_character( $hash->{'sender'} ) ){
        $self->character($hash->{'sender'});
        $self->{'logged_in'} = 1;
        say $self->{'username'}." logged in as ".$self->{'character'}{'charname'};
    }else{
        return 0; # do this is the character data isn't valid
    }
}

sub playerseen ($self, $hash){
    say"player seen by ".$self->character->{'name'};
}

sub chat($self, $msg_hash){
    say "chat received";
    #$msg_hash->{'room'} = $self->room->{'name'};
    #$self->alliance->broadcast($msg_hash);
}


########### Accessors, Setters, Getters ##########
sub stream ($self){
    return $self->{'stream'};
}

sub loop ($self){
    return $self->{'server'}->{'loop'};
}

sub username($self, $name = ''){
    if ( $name ){
        $self->{'username'} = $name;
    }else{
        return $self->{'username'};
    }
}
sub logged_in($self){
    return $self->{'logged_in'};
}
sub character ($self, $character = ''){
    if ($character){
        $self->{'character'} = $character;
    }else{
        return $self->{'character'};
    }
}

sub shares ($self){
    return $self->{'character'}{'shares'};
}

########### Utility methods ###########

sub is_valid_action ($self, $action){
    my %actions = (
        'login'      => '1',
        'playerseen' => '1',
        'chat'       => '1',
    );

    return exists $actions{$action};
}

sub is_valid_character ($self, $char){
    exists $char->{'factioncolor'} or return 0;
    exists $char->{'guildname'}    or return 0;
    exists $char->{'faction'}      or return 0;
    exists $char->{'charname'}     or return 0;
    exists $char->{'charid'}       or return 0;
    exists $char->{'guildabbr'}    or return 0;
    return 1;
}
1;
