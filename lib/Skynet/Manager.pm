package Skynet::Manager;
use v5.36;
use parent qw(Skynet::Notifier);
use Skynet::Guild;

sub _init ($self, @params){
    $self->SUPER::_init( @params );

    $self->add_child(
        Skynet::Guild->new(
            notifier_name => 'guildless'
        )
    );
}

sub add_to_guild ($self, $user, $guild_name){
    foreach my $guild ($self->children){
        if ($guild->notifier_name eq $guild_name){
            $guild->add_child($user);
            say "user added to $guild_name";
        }
    }
}


1;
