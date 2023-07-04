package Skynet::DBI;
use v5.36;
use Skynet::Database;

my $dbh =

sub new($class, $config){
    my $self = {
        dbh => Skynet::Database::_init(
                    'username' => $config->{database}{username},
                    'password' => $config->{database}{password},
                ),
    };

    bless $self, $class;
    return $self;
}

sub dbh($self){
    return $self->{dbh};
}

sub add_roid($self, $roid){
    my @keys ;
    my @values ;
    foreach my $key (keys(%{$roid})){
        push @keys, $key;
        push @values, $roid->{$key};
    }
    my $query = "REPLACE INTO roids (".join(',', @keys).") VALUES (".join(',', @values).")";
    my $result = $self->dbh->do($query);
}

1;
