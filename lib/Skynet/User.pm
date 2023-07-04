package Skynet::User;
use v5.36;
use parent qw( IO::Async::Stream );
use JSON;
use experimental 'try';
use Skynet::Commands;

my $pretty = JSON->new();
$pretty->pretty(1);


sub new ($class, %params){
    my $self = $class->SUPER::new(handle => $params{handle});
    $self->{userdata} = {
        'username'  => '',
        'logged_in' => 0,
        'dbh'       => $params{dbh},
        'alliance'  => '',
        'character' => {
            "factioncolor" => "",
            "guildname"    => "",
            "faction"      => "",
            "charname"     => "",
            "charid"       => "",
            "guildabbr"    => "",
        },
    };
    return $self;
}

sub on_read ($self, $buffref, $eof){
    while( $$buffref =~ s/^(.*)\r\n// ) {
        my $msg_txt = $1;
        say "Received a line: $msg_txt";
        my $msg_hash = '';
        try{
            $msg_hash = $pretty->decode($1);
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
        #$self->alliance->removeuser($self);

        say $self->username."logged off";
        $self->close_now;
    }

    return 0;
}


# Recieves a decoded message as a hash ref and dispatches
# to the proper method based on recognized "action" values
sub dispatch ($self, $hash){
    say $pretty->encode($hash);
    return unless exists $hash->{'action'};
    my $action = $hash->{'action'};
    say "dispatching $action";

}


sub write ($self, $hash){
    my $msg = encode_json $hash;
    $msg = $msg."\r\n";
    say "sending: $msg";
    $self->SUPER::write($msg);
}

# sets or gets the alliance of this user
sub alliance ($self, $alliance = ''){
    return $self->{userdata}{alliance} unless $alliance;
    $self->{userdata}{alliance} = $alliance;
}


1;
