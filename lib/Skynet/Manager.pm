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


}

sub db ($self, $db=''){
    if (! $db){
        return $self->{'db'};
    }else{
        $self->{'db'} = $db;
    }
}



1;
