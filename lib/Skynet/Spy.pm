use v5.36;
use JSON;

my $json = JSON->new->pretty(1);
package Skynet::Spy;

sub new($class){
    my $self = {
        updated => 0,
        list => {},
    };

    bless $self, $class;
    return $self;
}

sub report ($self){
    $self->clean();
    my $report = {
        action => 'playerseen',
        playerlist => $self->{list},
    };
    $self->{updated} = 0;
    return $report;
}

sub add ($self, $report){
    foreach my $sector (keys %{$report->{playerlist}} ){
        foreach my $player ( @{$report->{playerlist}{$sector}} ){

            # add a timestamp to each player in the report
            $player->{timestamp} = time();

            # remove player from other locations in the main list if there
            if( $self->remove_by_id($player->{id}) ){
                $self->{updated} = 1;
            }else{
               # say "ADDED: ".$player->{id};
            }
            $self->{updated} = 1;
        }

        # update the sector list
        $self->{list}{$sector} = $report->{playerlist}{$sector};

    }
}

sub clean ($self){
    my $now = time();
    my $new_list = {};
    foreach my $sector (keys %{$self->{list}} ){
        while (my $player = pop @{$self->{list}{$sector}}){
            if ( ($now - $player->{"timestamp"}) < 90 ){
                push @{$new_list->{$sector}}, $player;

            }else{
                $self->{updated} = 1;
                say "Timed out: ".$player->{name};
                next;
            }
        }
    }

    $self->{list} = $new_list;

}

sub ready ($self){
    return $self->{updated};
}

sub remove_by_id($self, $id){
    my $new_list = {};
    my $found = 0;
    foreach my $sector (keys %{$self->{list}} ){
        while (my $player = pop @{$self->{list}{$sector}}){
            push (@{$new_list->{$sector}}, $player) unless $player->{id} eq $id;
            $found = 1;
        }
    }
    $self->{list} = $new_list;
    return $found;
}

1;
