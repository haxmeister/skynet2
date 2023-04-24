package Skynet::Guild;
use v5.36;
use parent qw(IO::Async::Notifier);
use IO::Async::Timer::Periodic;

sub _init ($self, @params){
    $self->SUPER::_init( @params );

    $self->{guild_data} = {
        'name'      => '',
        'abbr'      => '',
        'commander' => '', # charname
        'seen_list' => {},
        'sector_timers' => {},
    };

    $self->{'last_seen_send'} => time(),
    $self->{'seen_list'}{'action'} = 'playerseen';
}

sub guild_broadcast ($self, $msg_ref){
    foreach my $user ($self->children){
        $user->send($msg_ref);
        $self->guild_log( "sending msg to: ".$user->username());
    }
}

sub name($self, $name=''){
    if (! $name){
        return $self->{guild_data}{'name'};
    }else{
        $self->{guild_data}{'name'} = $name;
    }
}

sub player_list_update($self, $new_data){
    foreach my $sector (keys %{$new_data->{'playerlist'}}) {
        next unless $new_data->{'playerlist'}{$sector}[0];
        $self->{'seen_list'}{'action'} = 'playerseen';
        $self->{'seen_list'}{'playerlist'}{$sector} = $new_data->{'playerlist'}{$sector};
        $self->{'sector_timers'}{$sector} = time();
        $self->guild_log( "Timer reset for $sector");
    }

    $self->clean_and_send_playerseen();
}

sub clean_and_send_playerseen($self){
    foreach my $sector( keys %{$self->{'seen_list'}{'playerlist'}} ){
        if ( (time() - $self->{'sector_timers'}{$sector}) > 30 ){
            delete $self->{'seen_list'}{'playerlist'}{$sector};
            $self->guild_log( "$sector timed out");
        }
    }

    $self->{'last_seen_send'} = time();
    $self->guild_broadcast($self->{'seen_list'});
}

sub tick ($self){
    if ( (time() - $self->{'last_seen_send'}) > 30){
        $self->guild_log( "Ticked update");
        $self->clean_and_send_playerseen();
    }else{
        $self->guild_log( "Ticked skipped");
    }
}

sub guild_log ($self, $msg){
    say $self->name()." ".$msg;
}
1;
