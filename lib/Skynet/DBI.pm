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
    my $sth = $self->dbh->prepare ("select * from users where username = ? and password = ?" );
    $sth->execute($hash->{username}, $hash->{password});
    my $row = $sth->fetchrow_hashref();
    $sth->finish();
    return $row;
}

sub add_user($self, $hash){
    my $sth = $self->dbh->prepare("INSERT INTO users (username, password) values   (?,?)");
    $sth->execute($hash->{username}, $hash->{password});
    $sth->finish();
}

sub get_alliance($self, $tag){
    my $sth = $self->dbh->prepare ("select * from alliances where alliance_tag = ?" );
    $sth->execute($tag);
    my $row = $sth->fetchrow_hashref();
    $sth->finish();
    return $row;
}

sub add_alliance($self, $tag, $user){
    my $sth = $self->dbh->prepare("INSERT INTO alliances (alliance_tag, commander) values   (?,?)");
    $sth->execute($tag, $user->{userdata}{username});
    $sth->finish();
}

sub change_commander($self, $tag, $new_commander){
    say "changing commander of $tag to $new_commander";
    my $sth = $self->dbh->prepare ("UPDATE alliances SET commander = ? WHERE alliance_tag = ? ");
    $sth->execute($new_commander->{userdata}{username}, $tag);
    $sth->finish();
}

sub check_name ($self, $hash){
    my $sth = $self->dbh->prepare ("select username, password from users where username = ?" );
    $sth->execute($hash->{username});
    my $row = $sth->fetchrow_hashref();
    $sth->finish();
    return $row;
}

sub add_invite ($self, $hash){
    my $sth = $self->dbh->prepare("SELECT username, alliance FROM invites WHERE username=? and charname=? and alliance=?");
    $sth->execute($hash->{username}, $hash->{charname}, $hash->{alliance});
    my $found = $sth->fetchrow_hashref();
    $sth->finish();

    if ($found){
        return 0;
    }

    $sth = $self->dbh->prepare("INSERT INTO invites (username, charname, alliance) values   (?,?,?)");
    $sth->execute($hash->{username}, $hash->{charname}, $hash->{alliance});
    $sth->finish();
    return 1;
}

sub get_invite ($self, $hash){
    my $sth = $self->dbh->prepare ("select charname, username, alliance from invites where charname = ? and username = ? and alliance = ?" );
    $sth->execute($hash->{charname}, $hash->{username}, $hash->{alliance});
    my $row = $sth->fetchrow_hashref();
    $sth->finish();
    return $row;
}

sub delete_invite($self, $hash){
    my $sth = $self->dbh->prepare ("DELETE FROM invites where charname = ? and alliance = ?" );
    $sth->execute($hash->{charname}, $hash->{alliance});
    $sth->finish();
}

sub set_alliance($self, $user){
    my $alliance = $user->alliance();
    my $username = $user->{userdata}{username};
    my $sth = $self->dbh->prepare ("UPDATE users SET alliance_tag = ? WHERE username = ? ");
    $sth->execute($alliance, $username);
    $sth->finish();
}



1;
