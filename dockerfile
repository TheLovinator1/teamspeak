FROM alpine

ARG pkgver="3.13.6"
ARG source_x86_64="https://files.teamspeak-services.com/releases/server/${pkgver}/teamspeak3-server_linux_alpine-${pkgver}.tar.bz2"
ARG sha256sums_x86_64="f30a5366f12b0c5b00476652ebc06d9b5bc4754c4cb386c086758cceb620a8d0"

ENV TS3SERVER_LICENSE=accept

RUN apk add --no-cache ca-certificates libstdc++
RUN addgroup -g 1000 teamspeak && \
    adduser -u 1000 -Hh /var/lib/teamspeak3-server -G teamspeak -s /sbin/nologin -D teamspeak && \
    install -d -o teamspeak -g teamspeak -m 775 /var/log/teamspeak3-server /var/lib/teamspeak3-server /tmp/teamspeak
    
WORKDIR /tmp/teamspeak

ADD teamspeak3-server.ini /tmp/teamspeak

RUN apk add --no-cache tar && \
    wget "${source_x86_64}" && \ 
    echo "${sha256sums_x86_64}  teamspeak3-server_linux_alpine-${pkgver}.tar.bz2" | sha256sum -c - && \
    tar -xf "teamspeak3-server_linux_alpine-${pkgver}.tar.bz2" --strip-components=1 -C /tmp/teamspeak && \
    rm "teamspeak3-server_linux_alpine-${pkgver}.tar.bz2" && \
    \
    install -Dm 644 teamspeak3-server.ini -t "/etc" && \
    install -Dm 644 tsdns/tsdns_settings.ini.sample "/etc/tsdns_settings.ini" && \
    install -Dm 755 ts3server -t "/usr/bin" && \
    install -Dm 755 tsdns/tsdnsserver -t "/usr/bin" && \
    install -Dm 644 *.so -t "/usr/lib" && \
    install -Dm 644 LICENSE -t "/usr/share/licenses/${pkgname}" && \
    install -d "/usr/share/doc/teamspeak3-server" "/usr/share/teamspeak3-server" && \
    \ 
    cp -a doc "/usr/share/doc/teamspeak3-server" && \
    cp -a serverquerydocs "/usr/share/doc/teamspeak3-server" && \
    cp -a sql "/usr/share/teamspeak3-server" && \
    \
    find "/usr/share/teamspeak3-server" -type d -exec chmod 755 {} \; && \
    find "/usr/share/teamspeak3-server" -type f -exec chmod 644 {} \; && \
    find "/usr/share/doc/teamspeak3-server" -type d -exec chmod 755 {} \; && \
    find "/usr/share/doc/teamspeak3-server" -type f -exec chmod 644 {} \;   && \
    \
    ldconfig /usr/lib  && \
    apk del tar && \
    rm -rf /tmp/teamspeak

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

CMD ["ts3server", "inifile=/etc/teamspeak3-server.ini"]
