# TeamSpeak3 Server

TeamSpeak is proprietary Voice over IP software that allows computer users to speak on a chat channel with fellow computer users, much like a telephone conference call.

## Docker

This Docker image is using the [Arch Linux](https://hub.docker.com/_/archlinux/) as base image. The TeamSpeak server runs as a user with the id `1000`.
If you possess a license file please copy it to the data volumes root. (`/var/lib/teamspeak3-server/licensekey.dat` in container).

## Requirements

SSE2 capable CPU. Only 64-bit support, no ARM.

## First startup

With the first startup TeamSpeak creates the SQLite database at `/var/lib/teamspeak3-server/ts3server.sqlitedb` and starts logging its standard output in files in: `/var/log/teamspeak3-server/`. TeamSpeak also creates the first ServerQuery administration account (the superuser) and the first virtual server including a privilege key for the server administrator of this virtual server. The privilege key is only displayed once on standard output. Alternatively, you can navigate to the logs volume and read the output log directly. (This is a persistent file and will still have the first startup output here even if you have restarted the server):

## Starting Teamspeak with disabled IPv6 stack

- Uncomment `- /absolute/path/to/file.ini:/etc/teamspeak3-server.ini` in docker-compose.yml
- Download [teamspeak3-server.ini](https://github.com/archlinux/svntogit-community/blob/packages/teamspeak3-server/trunk/teamspeak3-server.ini) and add the path to the file to the docker-compose.yml file.
- Change `query_ip=0.0.0.0, ::` to `query_ip=0.0.0.0`

## Ports

| Port  | Description       | Required |
| ----- | ----------------- | -------- |
| 9987  | Voice             | Yes      |
| 30033 | File transfer     | Yes      |
| 10011 | ServerQuery (raw) | No       |
| 10022 | ServerQuery (SSH) | No       |
| 10080 | WebQuery (http)   | No       |
| 10443 | WebQuery (https)  | No       |
| 41144 | TSDNS             | No       |

TeamSpeak 3 servers will communicate with the following addresses:

| Domain                    | Protocol | Local Port (Server)         | Remote Port | Notes                             |
| ------------------------- | -------- | --------------------------- | ----------- | --------------------------------- |
| accounting.teamspeak.com  | TCP      | 1024-65535 (random by OS)   | 2008        | TeamSpeak 3 Server versions 3.0.x |
| accounting2.teamspeak.com | TCP      | 1024-65535 (random by OS)   | 443         | TeamSpeak 3 Server versions 3.1.x |
| ts3services.teamspeak.com | TCP      | 1024-65535 (random by OS)   | 443         | TeamSpeak 3 Server versions 3.1.x |
| weblist.teamspeak.com     | UDP      | 2011-2110 (first available) | 2010        | all server versions               |

If you need to use a proxy to connect to the TeamSpeak 3 Server, you can add the following to the `/etc/teamspeak3-server.ini` file:

    http_proxy=my.proxy.example:1234
    http_proxy=192.0.2.1:1234
    http_proxy=[2001:DB8::4321:5678:9ABC]:1234

The proxy provided must not require authentication, as that is not supported by the TeamSpeak 3 server.

## Files

The following files and folders need to copied if you want to retain the respective information. Don't forget to use an persistent volume for the data volume.:

| File                   | Description                                                                                                                                  |
| ---------------------- | -------------------------------------------------------------------------------------------------------------------------------------------- |
| licensekey.dat         | This file contains your license.                                                                                                             |
| query_ip_allowlist.txt | Whitelisted IPs for the query interface                                                                                                      |
| query_ip_denylist.txt  | Blacklisted IPs for the query interface                                                                                                      |
| files/\*               | Any Icons, Avatars and files that were uploaded to the server. Be sure to copy the entire folder including any subfolders and files inside.  |
| ts3server.sqlitedb     | The database. This file is the most important one and contains all the information about the server, users, permissions, channels and groups |

## Need help?

- Email: [tlovinator@gmail.com](mailto:tlovinator@gmail.com)
- Discord: TheLovinator#9276
- Steam: [TheLovinator](https://steamcommunity.com/id/TheLovinator/)
- Send an issue: [docker-arch-teamspeak/issues](https://github.com/TheLovinator1/docker-arch-teamspeak/issues)
