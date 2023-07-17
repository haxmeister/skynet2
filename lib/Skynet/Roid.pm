package Skynet::Roid;
use v5.36;
sub new($class, %args){
    my $self = {
        sector     => 0,
        objectId   => 0,
        Aquean     => 0,
        Silicate   => 0,
        Carbonic   => 0,
        Ferric     => 0,
        Ishik      => 0,
        VanAzek    => 0,
        Xithricite => 0,
        Lanthanic  => 0,
        Denic      => 0,
        Pyronic    => 0,
        Apicene    => 0,
        Pentric    => 0,
        Heliocene  => 0,
        Sammic     => 0,
        alliance   => 'Lobby',
    };
    foreach my $key (keys(%args)){
        if (exists $self->{$key}){

            $self->{$key} = $args{$key};
        }
    }

    bless $self, $class;
    return $self;
}

sub new_from_report ($class, $report){
    my @data = split("\n", $report->{data}->{data});

    my %ores = (
        sector   => $report->{sender}{sectorid},
        objectId => $report->{data}{objectid},
    );

    foreach my $item(@data){
        if ($item =~ /^Temp/){next;}
        if ($item =~ /^Minerals/){next;}
        $item =~ s/\%//g;
        $item =~ s/Ore//g;
        $item =~ s/ //g;
        my ($ore, $percent) =  split(":",$item);
        $ores{$ore} = $percent;
    }
    my $self = Skynet::Roid->new(%ores);
    return $self;
}

sub set_alliance ($self, $alliance){
    $self->{alliance} = $alliance;
    return $self;
}

1;
