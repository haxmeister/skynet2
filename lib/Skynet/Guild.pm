package Skynet::Guild;
use v5.36;
use parent qw(Skynet::Notifier);

sub _init ($self, @params){
    $self->SUPER::_init( @params );
}

sub guild_broadcast ($self, $json_msg){
    foreach my $member ($self->children){
        my $stream = $member->children;
        $stream->write($json_msg);
    }
}


1;
