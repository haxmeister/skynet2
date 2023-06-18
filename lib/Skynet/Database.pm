package Skynet::Database;
use v5.36;
use DBI;


sub new ($class, %params){
    my $self = \%params;
    bless $self,$class;
    $self->_init();
    return $self;
}



sub _init($self){
    exists ($self->{'username'}) or die "username argument not supplied to Skynet::Database::new but required!\n";
    exists ($self->{'password'}) or die "password argument not supplied to Skynet::Database::new but required!\n";

    # lets see if the skynet database exist on the database server, if not we will create it
    my @dsns = DBI->data_sources('MariaDB', {
        user     => $self->{username},
        password => $self->{password},
    });

    # iterate over the dsn list reported by the database and see if skynet exists there
    foreach my $dsn (@dsns){
        if ($dsn eq "DBI:MariaDB:skynet"){
            say "Found the skynet database at $dsn";
            $self->{dsn} = $dsn;
        }
    }

    if (! exists( $self->{dsn} ) ){
        # the skynet database was not found so we connect to mariadb and create one
        my $dbh = DBI->connect("DBI:MariaDB:", $self->{username}, $self->{password}) or die "cannot connect to db\n";
        $dbh->do("create database skynet") or die "Cannot create skynet database\n";
        $dbh->disconnect();
        $self->{dsn} = "DBI:MariaDB:skynet";
    }
    # now lets connect to our "DBI:MariaDB:skynet" properly and save the handle in $self->{'dbh'}
    $self->connect();

    # the necessary tables exists or we will create them so they are ready to be used
    $self->init_tables();

    say "Skynet Database initialization complete!";

}

sub connect($self){
    $self->{'dbh'} = DBI->connect_cached(
        $self->{dsn},
        $self->{username},
        $self->{password},
        {
            RaiseError => 1,
            AutoCommit => 1,
            mariadb_auto_reconnect => 1,
        },
    ) or die "Cannot connect to database $DBI::errstr \n";
}

sub init_tables($self){
    $self->create_users_table();
    $self->create_status_table();
    $self->create_channel_members_table();
    $self->create_roids_table();
}

sub create_users_table($self){
    my $create_table_query = "
            CREATE TABLE IF NOT EXISTS users (
                username VARCHAR(255) NOT NULL,
                password VARCHAR(255) NOT NULL,
                guild_abbr VARCHAR(255),
                perms VARCHAR(255),
                last_channel VARCHAR(255),
                PRIMARY KEY(username)
            )
        ";

    my $create_table_sth = $self->{dbh}->do($create_table_query);
    print "Initialized 'users' table.\n";
}

sub create_status_table($self){
   my $create_table_query = "
            CREATE TABLE IF NOT EXISTS status (
                char_name VARCHAR(255) NOT NULL,
                ts INT NOT NULL,
                exp_ts INT NOT NULL,
                added_by_guild VARCHAR(255),
                added_by_user VARCHAR(255),
                type VARCHAR(255),
                notes text,
                PRIMARY KEY (added_by_user, char_name)
            )
        ";

    my $create_table_sth = $self->{dbh}->do($create_table_query);
    print "Initialized 'status' table.\n";
}

sub create_channel_members_table($self){
   my $create_table_query = "
            CREATE TABLE IF NOT EXISTS channel_members (
                channel_name VARCHAR(255) NOT NULL,
                owner VARCHAR(255) NOT NULL,
                user VARCHAR(255) NOT NULL
            )
        ";

    my $create_table_sth = $self->{dbh}->do($create_table_query);
    print "Initialized 'channel_members' table.\n";
}

sub create_roids_table($self){
    my $create_table_query = "
            CREATE TABLE IF NOT EXISTS roids (
                sector INT NOT NULL,
                objectId INT NOT NULL,
                Aquean FLOAT,
                Silicate FLOAT,
                Carbonic FLOAT,
                Ferric FLOAT,
                Ishik FLOAT,
                VanAzek FLOAT,
                Xithricite FLOAT,
                Lanthanic FLOAT,
                Denic FLOAT,
                Pyronic FLOAT,
                Apicene FLOAT,
                Pentric FLOAT,
                Heliocene FLOAT,
                Sammic FLOAT,
                PRIMARY KEY(sector, objectid)
            )
        ";

    my $create_table_sth = $self->{dbh}->do($create_table_query);
    print "Initialized 'roids' table.\n";
}



1;
