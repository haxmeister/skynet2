# Skynet2
Plugin server for Vendetta online

## Alliances
Skynet functions on the concept of alliances which is independant of guilds in the game. Each alliance on the server is provided with the same functionality independant of other alliances.

## Users
A user is a single set of login credentials on the skynet server. Each user can only be a member of a single alliance or no alliance at all.

## The lobby
The lobby is an automatically generated alliance that all users are added to when they first connect. It will provide a chat and asteroid database only at this time.

## Asteroid Database
The asteroid database contains all asteroids that have been scanned by skynet users, the sector it resides in, and all the ore percentages it contained on last scan. Each asteroid added to the database is marked for the alliance that added it, such that one alliance is not providing it's secret asteroid data to another alliance.

The only exception to this rule is asteroids added by users residing in the lobby. Any asteroids saved by a lobby member are available to other lobby members AS WELL AS all other alliances. They become public!

## Player spots
When a user sees another user in the same sector, that information is broadcasted to all other users in the same alliance unless you are in the lobby. The server will create a tick timer that manages a table of these player locations so that less bandwidth is used against the user client. The server will send a periodic update of all known locations to be displayed to the user. Each location has a timer so that the update will remove old out of date data.

## Alliance chat
Each alliance has an isolated alliance chat channel provided to them. The messages in the chat will be preceded by the alliance's abbr name. The login name of the user will be shown. This may or may not be the same as the character name in the game, though it is recommended that the character name be used and the user provide a separate set of credentials for each character on their account. This way you can have some characters that are in different alliances etc..

