package Skynet::Alliance;
use v5.36;
use parent qw( IO::Async::Notifier );
use IO::Async::Timer::Periodic;
use experimental 'try';
use Storable qw(dclone);
use Skynet::Roid;
use Skynet::Spy;
use JSON;
my $json = JSON->new->pretty(1);

sub new($class, $name){
    my $self = $class->SUPER::new(notifier_name => $name);

    $self->{spy} = Skynet::Spy->new();
    $self->add_child(
        IO::Async::Timer::Periodic->new(
            notifier_name => 'tick',
            interval => 2,
            on_tick  => sub {
                # prevent spy from broadcasting spots to lobby
                #if ($self->notifier_name() eq 'Lobby'){return}
                $self->{spy}->clean();
                if ($self->{spy}->ready()){
                    say "sending spy report to ".$self->notifier_name();
                    $self->broadcast( $self->{spy}->report() );
                }
            },
        )->start()
    );

    say "generated alliance $name";
    return $self;
}

sub broadcast($self, $hash){
    #say "broadcasting".$json->encode($hash);
    my @children = $self->children();
    foreach my $child (@children){
        next if $child->notifier_name() eq 'tick';
        $child->write($hash);
    }
}


sub scan($self, $report){
    my $roid = Skynet::Roid->new_from_report($report)->set_alliance($self->notifier_name());
    say "roid scan completed";
    $self->parent->dbi->add_roid($roid);
}

sub announce($self, $hash){}

sub string_broadcast($self, $string){

}

sub spy($self){ return $self->{spy} }

sub chat($self, $hash){
    $hash->{'channel'} = $self->notifier_name();

    # keep Lobby from broadcasting locations
    if ($self->notifier_name() eq 'Lobby'){
        $hash->{sender}{sectorabbr} = 'ANON';
        delete $hash->{sender}{sectorid};
        $hash->{sender}{sectorfactioncolor} = "00ff00";
    }
    $self->broadcast($hash);
}

# returns a list of members online
sub members_online($self){
    my @users;
    foreach my $child ($self->children()){
        if ($child->notifier_name() eq 'tick'){next;}
        push(@users, $child->{userdata}{character}{charname} );
    }
    return \@users;
}

# sets or gets the commander of this alliance
sub commander($self, $username = ''){
    return $self->{commander} unless $username;
    $self->{commander} = $username;
}
1;
