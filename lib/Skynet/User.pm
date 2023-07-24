package Skynet::User;
use v5.36;
use parent qw( IO::Async::Stream );
use JSON;
use experimental 'try';

my $pretty = JSON->new();
$pretty->pretty(1);


sub new ($class, %params){
    my $self = $class->SUPER::new(handle => $params{handle});
    $self->{userdata} = {
        'username'  => '',
        'logged_in' => 0,
        'alliance'  => 'Lobby',
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
        #say "Received a line: $msg_txt";
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

        say $self->{userdata}{username}."logged off";
        $self->close_now;
    }

    return 0;
}


# Recieves a decoded message as a hash ref and dispatches
# to the proper method based on recognized "action" values
sub dispatch ($self, $hash){
    #say $pretty->encode($hash);
    return unless exists $hash->{'action'};
    my $action = $hash->{'action'};
    my %actions = (
        'chat'       => sub { $self->parent->chat($hash)     },
        'scan'       => sub { $self->parent->scan($hash)     },
        'playerseen' => sub { $self->parent->spy->add($hash) },
        'login'      => sub { $self->login($hash)            },
        'register'   => sub { $self->register($hash)         },
        'invite'     => sub { $self->invite($hash)           },
        'join'       => sub { $self->join_alliance($hash)    },
        'newalliance'=> sub { $self->new_alliance($hash)     },
    );
    if ( exists($actions{$action}) ){
        $actions{$action}->($hash);
    }else{ return; }

    say "User dispatching $action";
}

# encodes a hash and sends it to this user
sub write ($self, $hash){
    my $msg = encode_json $hash;
    $msg = $msg."\r\n";
    say "sending: ".$hash->{action};
    $self->SUPER::write($msg);
}

# returns the alliance of this user
sub alliance ($self, $alliance = ''){
    if($alliance){
        $self->{userdata}{alliance} = $alliance;
        return $self->{userdata}{alliance};
    }else{
        return $self->{userdata}{alliance};
    }
}

# sends a skynetmsg to this user
sub skynetmsg($self, $text){
    my $msg = {
        action => 'skynetmsg',
        text   => $text,
    };
    $self->write($msg);
}

# sends a skynetmsg to this user
sub skyneterrormsg($self, $text){
    my $msg = {
        action => 'skyneterrormsg',
        text   => $text,
    };
    $self->write($msg);
}

sub login($self, $hash){
    my $userdata = $self->dbi->get_user($hash);
    if ($userdata){
        $self->{userdata}{username}  = $userdata->{username};
        $self->{userdata}{logged_in} = 1;
        $self->{userdata}{alliance}  = $userdata->{alliance_tag};
        $self->skynetmsg("Login successful!");
        $self->manager->assign_user($self);
    }else{
        $self->skyneterrormsg("Username and password combo not found on server!");
    }
}

sub register($self, $hash){
    unless ($hash->{username} and $hash->{password}) {
        $self->skyneterrormsg("Registration failed, no valid username or password provided");
        return;
    }

    if( $self->dbi->check_name($hash) ){
        $self->skyneterrormsg("This username is already taken");
        return;
    }

    my $result = $self->dbi->add_user($hash);
    if ($result eq 1){
        $self->skynetmsg("Registration successful username = ".$hash->{username}.", password = ".$hash->{password});
        $self->skynetmsg("Don't forget to log in with your new username and password!'");
        $self->{userdata}{username} = $hash->{username};
        $self->{userdata}{logged_in} = 1;
    }else{}
}

sub invite($self, $hash){
    $hash->{alliance} = $self->parent->notifier_name();

    if($self->alliance() eq 'Lobby'){
        $self->skyneterrormsg("You cannot invite someone to the Lobby");
        return;
    }

    unless ($self->parent->commander() eq $self->{userdata}{username}){
        $self->skyneterrormsg("Only ".$self->parent->commander()." may invite people to ".$self->parent->notifier_name());
        return;
    }

    $self->dbi->add_invite($hash);
}

sub join_alliance($self, $hash){
    $hash->{username} = $self->{userdata}{username};
    say $pretty->encode($hash);

    # check to see if invited
    if($self->dbi->get_invite($hash)){
        # attempt to set user's alliance in the database
        if( $self->dbi->set_alliance($hash)){

            # delete the invite
            $self->dbi->delete_invite($hash);

            # set this user instance to it's new alliance
            $self->alliance($hash->{alliance});

            # move this user to the newly joined alliance's channel
            $self->manager->assign_user($self);
        }else{
            # must be a problem and can't set the user's alliance in the database
            $self->skyneterrormsg("Cannot add you to the alliance at this time");
        }
    }else{
        # we didn't find an invite for this user to that alliance
        $self->skyneterrormsg("You have not been invited to ".$hash->{alliance});
    }
}

sub new_alliance($self, $hash){
    say $pretty->encode($hash);
    return unless $hash->{newalliancetag};
    if (! $self->{userdata}{logged_in}){
        $self->skyneterrormsg("You must be logged in to create an alliance.");
        return;
    }

    my $results = $self->dbi->get_alliance($hash->{newalliancetag});
    say $pretty->encode($results);
    if($results){
        $self->skyneterrormsg("Alliance tag ".$hash->{newalliancetag}." is already taken");
        return;
    }

    # add alliance to database with myself as commander
    $self->dbi->add_alliance($hash->{newalliancetag}, $self);

    #check that is was successfully added
    my $new_results = $self->dbi->get_alliance($hash->{newalliancetag});
    if($new_results){
        $self->skynetmsg("Alliance tag ".$hash->{newalliancetag}." has been added to the database");
        $self->alliance($hash->{newalliancetag});
        $self->dbi->set_alliance($self);
        $self->manager->add_alliance($hash->{newalliancetag});
        $self->manager->assign_user($self);
    }else{

    }
}

sub dbi($self){
    return $self->parent->parent->dbi();
}

sub manager($self){
    return $self->parent->parent();
}
1;
