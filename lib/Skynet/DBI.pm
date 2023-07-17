package Skynet::DBI;
use v5.36;
use Skynet::Database;
use JSON;
my $json = JSON->new->pretty(1);

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
        # lets fix the alliance value to be quoted for the db properly
        if ($key eq 'alliance') { $roid->{$key} = "\"$roid->{$key}\""}
        push @keys, $key;
        push @values, $roid->{$key};
    }

    my $query = "REPLACE INTO roids (".join(',', @keys).") VALUES (".join(',', @values).")";
    my $result = $self->dbh->do($query);
}

sub get_user ($self, $hash){
    my $sth = $self->dbh->prepare ("select username, password from users where username = ? and password = ?" );
    $sth->execute($hash->{username}, $hash->{password});
    my $row = $sth->fetchrow_hashref();
    $sth->finish();
    return $row;
}

sub get_alliance($self, $tag){
    my $sth = $self->dbh->prepare ("select * from alliances where tag = ?" );
    $sth->execute($tag);
    my $row = $sth->fetchrow_hashref();
    $sth->finish();
    return $row;
}

sub check_name ($self, $hash){
    my $sth = $self->dbh->prepare ("select username, password from users where username = ?" );
    $sth->execute($hash->{username});
    my $row = $sth->fetchrow_hashref();
    $sth->finish();
    return $row;
}

sub add_user($self, $hash){
    my $sth = $self->dbh->prepare("INSERT INTO users (username, password) values   (?,?)");
    $sth->execute($hash->{username}, $hash->{password});
    $sth->finish();
}

sub add_invite ($self, $hash){
    my $sth = $self->dbh->prepare("INSERT INTO invites (username, alliance) values   (?,?)");
    $sth->execute($hash->{username}, $hash->{alliance});
    $sth->finish();
}

sub get_invite ($self, $hash){
    my $sth = $self->dbh->prepare ("select username, alliance from invites where username = ? and alliance = ?" );
    $sth->execute($hash->{username}, $hash->{alliance});
    my $row = $sth->fetchrow_hashref();
    $sth->finish();
    return $row;
}

sub delete_invite($self, $hash){
    my $query = q{DELETE FROM invites WHERE alliance = ? and username = ?};
    my $result = $self->dbh->do($query, $hash->{alliance}, $hash->{username});
    if ($result == 1){return 1}else{return 0}
}

sub set_alliance($self, $hash){
    my $query = "UPDATE users SET alliance_tag = ? WHERE username = ?";
    my $result = $self->dbh->do($query, $hash->{alliance}, $hash->{username});
    if ($result == 1){return 1}else{return 0}
}
1;
