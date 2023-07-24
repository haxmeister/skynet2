package Skynet::Database;
use v5.36;
use DBI;


my $dsn = "DBI:MariaDB:skynet";
my $dbh;
my $username;
my $password;

sub _init(%params){
    $username = $params{'username'} or die "username argument not supplied to Skynet::Database::new but required!\n";
    $password = $params{'password'} or die "password argument not supplied to Skynet::Database::new but required!\n";

    # lets see if the skynet database exist on the database server, if not we will create it
    my @dsns = DBI->data_sources('MariaDB', {
        user     => $username,
        password => $password,
    });

    # iterate over the dsn list reported by the database and see if skynet exists there
    foreach my $found_dsn (@dsns){
        if ($found_dsn eq "DBI:MariaDB:skynet"){
            say "Found the skynet database at $found_dsn";
            $dsn = $found_dsn;
        }
    }

    if (! $dsn){
        # the skynet database was not found so we connect to mariadb and create one
        $dbh = DBI->connect("DBI:MariaDB:", $username, $password) or die "cannot connect to db\n";
        $dbh->do("create database skynet") or die "Cannot create skynet database\n";
        $dbh->disconnect();
    }
    # now lets connect to our "DBI:MariaDB:skynet" properly and save the handle in $self->{'dbh'}
    db_connect();

    # the necessary tables exists or we will create them so they are ready to be used
    init_tables();

    say "Skynet Database initialization complete!";
    return $dbh;
}

sub db_connect {
    $dbh = DBI->connect_cached(
        $dsn,
        $username,
        $password,
        {
            #RaiseError => 1,
            AutoCommit => 1,
            mariadb_auto_reconnect => 1,
        },
    ) or die "Cannot connect to database $DBI::errstr \n";
}

sub init_tables {
    create_users_table();
    create_alliances_table();
    create_roids_table();
    create_invites_table();
}

sub create_users_table {
    my $create_table_query = "
            CREATE TABLE IF NOT EXISTS users (
                username VARCHAR(255) NOT NULL,
                password VARCHAR(255) NOT NULL,
                alliance_tag VARCHAR(255) DEFAULT 'Lobby',
                PRIMARY KEY(username)
            )
        ";

    my $create_table_sth = $dbh->do($create_table_query);
    print "Initialized 'users' table.\n";
}

sub create_alliances_table {
    my $create_table_query = "
            CREATE TABLE IF NOT EXISTS alliances (
                alliance_tag VARCHAR(255) NOT NULL,
                name VARCHAR(255),
                commander VARCHAR(255) NOT NULL,
                color VARCHAR(255),
                about TEXT,
                PRIMARY KEY(alliance_tag)
            )
        ";

    my $create_table_sth = $dbh->do($create_table_query);
    print "Initialized 'alliances' table.\n";
}

sub create_roids_table {
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
                alliance VARCHAR(255) DEFAULT 'Lobby',
                PRIMARY KEY(sector, objectid, alliance)
            )
        ";

    my $create_table_sth = $dbh->do($create_table_query);
    print "Initialized 'roids' table.\n";
}
sub create_invites_table {
    my $create_table_query = "
            CREATE TABLE IF NOT EXISTS invites (
                username VARCHAR(255) NOT NULL,
                alliance VARCHAR(255) NOT NULL,
                PRIMARY KEY(username, alliance)
            )
        ";

    my $create_table_sth = $dbh->do($create_table_query);
    print "Initialized 'invites' table.\n";
}
1;
