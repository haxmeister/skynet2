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
    };
    foreach my $key (keys(%args)){
        if (exists $self->{$key}){

            $self->{$key} = $args{$key};
        }
    }

    bless $self, $class;
    return $self;
}

1;
