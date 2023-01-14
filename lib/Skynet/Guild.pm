package Skynet::Guild;
use v5.36;
use parent qw(IO::Async::Notifier);

sub _init ($self, @params){
    $self->SUPER::_init( @params );

    $self->{guild_data} = {
        'name'      => '',
        'abbr'      => '',
        'commander' => '', # charname
    };
}

sub alliance_broadcast ($self, $msg_ref){}

sub guild_broadcast ($self, $msg_ref){
    foreach my $user ($self->children){
        $user->send($msg_ref);
    }
}

sub name($self, $name=''){
    if (! $name){
        return $self->{'name'};
    }else{
        $self->{'name'} = $name;
    }
}


1;
