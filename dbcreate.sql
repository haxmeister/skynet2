create table users(
    username varchar(255) NOT NULL UNIQUE,
    password varchar(255) NOT NULL,
    PRIMARY KEY (username)
);

create table characters(
    charname varchar(255) NOT NULL UNIQUE,
    username varchar(255) NOT NULL,
    guildabbr varchar(255) NOT NULL DEFAULT 'guildless',
    PRIMARY KEY (charname),
    FOREIGN KEY (username) REFERENCES users(username)
);

create table guilds(
    guildname varchar(255) NOT NULL UNIQUE,
    guildabbr varchar(255) NOT NULL UNIQUE,
    commander varchar(255) NOT NULL,
    PRIMARY KEY (guildabbr),
    FOREIGN KEY (commander) REFERENCES characters(charname)
);

create table guildpermissions(
    id int NOT NULL UNIQUE,
    guildabbr varchar(255) NOT NULL,
    charname varchar(255) NOT NULL,
    man_user int DEFAULT 0,
    man_warr int DEFAULT 0,
    man_stat int DEFAULT 0,
    see_spots int DEFAULT 0,
    see_chat int DEFAULT 0,
    see_stat int DEFAULT 0,
    see_warr int DEFAULT 0,
    PRIMARY KEY (id),
    FOREIGN KEY (guildabbr) REFERENCES guilds(guildabbr)
);

create table status(
    id int NOT NULL UNIQUE,
    name varchar(255) NOT NULL,
    type varchar(255) DEFAULT 'none',
    ts int,
    length int,
    guild varchar(255) NOT NULL,
    notes varchar(255),
    PRIMARY KEY (id),
    FOREIGN KEY (guild) REFERENCES guilds(guildabbr)
);

create table shares(
    id int NOT NULL UNIQUE,
    fromguild varchar(255),
    toguild varchar(255),
    fromchar varchar(255),
    tochar varchar(255),
    PRIMARY KEY (id)
);

create table messages(
    id int NOT NULL UNIQUE,
    tochar varchar(255) NOT NULL,
    message varchar(255) NOT NULL,
    PRIMARY KEY (id),
    FOREIGN KEY (tochar) REFERENCES characters(charname)
);

create table sectors(
    sectorid int NOT NULL UNIQUE,
    name varchar(255) NOT NULL UNIQUE,
    abbrname varchar(255) NOT NULL UNIQUE,
    system varchar(255) NOT NULL,
    PRIMARY KEY (sectorid)
);

create table asteroids(
    id int NOT NULL UNIQUE,
    sectorid int NOT NULL,
    objectid int NOT NULL UNIQUE,
    Aquean float,
    Silicate float,
    Carbonic float,
    Ferric float,
    Ishik float,
    VanAzek float,
    Xithricite float,
    Lanthanic float,
    Denic float,
    Pyronic float,
    Apicene float,
    Pentric float,
    Heliocene float,
    Sammic float,
    FOREIGN KEY (sectorid) REFERENCES sectors(sectorid),
    PRIMARY KEY (id)
);

create table localgoods(
    id int NOT NULL UNIQUE,
    sectorid int NOT NULL,
    name varchar(255),
    price FLOAT,
    PRIMARY KEY (id),
    FOREIGN KEY (sectorid) REFERENCES sectors(sectorid)
);
