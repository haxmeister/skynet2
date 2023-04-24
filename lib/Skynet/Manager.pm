package Skynet::Manager;
use v5.36;
use parent qw(IO::Async::Notifier);
use Skynet::Guild;

sub _init ($self, @params){
    $self->SUPER::_init( @params );
    $self->{db} = '';
}

sub add_to_guild ($self, $user, $guild_name){
    foreach my $guild ($self->children){
        if ($guild->name() eq $guild_name){

            # check for players by same name in the guild
            # and disconnect any duplicates
            foreach my $connected_user ($guild->children()){
                say STDERR $connected_user->username()." seen already";
                if ($connected_user->username() eq $user->username()){
                    say STDERR "disconnecting duplicate: ".$connected_user->username();
                    $guild->remove_child($connected_user);

                }
            }

            $guild->add_child($user);
            say $user->username." added to $guild_name";
            return
        }
    }

    say "creating guild: ".$guild_name;
    my $newguild = Skynet::Guild->new();
    $self->add_child($newguild);
    $newguild->name($guild_name);
    $newguild->add_child($user);
    say $user->username." added to $guild_name";


}

sub db ($self, $db=''){
    if (! $db){
        return $self->{'db'};
    }else{
        $self->{'db'} = $db;
    }
}

sub guild_tick ($self){
    foreach my $guild ($self->children){
        $guild->tick();
    }

}


1;
