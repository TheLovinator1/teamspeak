FROM archlinux

# Accept the license agreement. You should probably read it before you accept it.
# Can also create an empty file called .ts3server_license_accepted in working directory.
ENV TS3SERVER_LICENSE=accept

# When we install teamspeak3-server dynamic libraries are copied to /usr/lib.
ENV LD_LIBRARY_PATH="/usr/lib/:/usr/lib/mariadb/:$LD_LIBRARY_PATH"

# Add mirrors for Sweden. You can add your own mirrors to the mirrorlist file. Should probably use reflector.
ADD mirrorlist /etc/pacman.d/mirrorlist

# NOTE: For Security Reasons, archlinux image strips the pacman lsign key.
# This is because the same key would be spread to all containers of the same
# image, allowing for malicious actors to inject packages (via, for example,
# a man-in-the-middle).
RUN gpg --refresh-keys && pacman-key --init && pacman-key --populate archlinux

# Set locale. Needed for some programs.
# https://wiki.archlinux.org/title/locale
RUN echo "en_US.UTF-8 UTF-8" > "/etc/locale.gen" && locale-gen && echo "LANG=en_US.UTF-8" > "/etc/locale.conf"

# Create a new user with id 1000 and name "lovinator".
# Home folder is /var/lib/teamspeak3-server where the data for the Teamspeak server is stored.
# https://linux.die.net/man/8/useradd
# https://linux.die.net/man/8/groupadd
RUN groupadd --gid 1000 --system lovinator && \
    useradd --system --uid 1000 --gid 1000 --comment "TeamSpeak3 Server daemon" lovinator

# Update the system.
RUN pacman -Syu --noconfirm

# Install Teamspeak3 Server
# https://archlinux.org/packages/community/x86_64/teamspeak3-server/
RUN pacman -S teamspeak3-server --noconfirm

# Create data folder and log folder and set permissions.
# https://linux.die.net/man/1/install
RUN install --directory /var/lib/teamspeak3-server --owner=lovinator --group=lovinator && \
    install --directory /var/log/teamspeak3-server/ --owner=lovinator --group=lovinator

# Remove cache. TODO: add more cleanup. Should we remove pacman?
RUN rm -rf /var/cache/*

# Data is stored in /var/lib/teamspeak3-server
# Logs are stored in /var/log/teamspeak3-server
VOLUME ["/var/lib/teamspeak3-server", "/var/log/teamspeak3-server"]
WORKDIR /var/lib/teamspeak3-server

# 9987  (Required)  Voice 
# 30033 (Required)  Filetransfer 
# 10011             ServerQuery (raw)
# 10022             ServerQuery (SSH)
# 10080             WebQuery (http)
# 10443             WebQuery (https)
# 41144             TSDNS
EXPOSE 9987/udp
EXPOSE 30033/tcp 
EXPOSE 10011/tcp
EXPOSE 10022/tcp
EXPOSE 10080/tcp
EXPOSE 10443/tcp
EXPOSE 41144/tcp

# Don't run the server as root.
USER lovinator

# Start the server with our ini file. You need to uncomment the volume 
# in docker-compose.yml if you want to modify the ini file.
CMD ["/usr/bin/ts3server", "inifile=/etc/teamspeak3-server.ini"]
