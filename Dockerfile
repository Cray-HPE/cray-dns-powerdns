FROM artifactory.algol60.net/docker.io/library/alpine:3 as base

ENV POWERDNS_VERSION="4.8.4" \
    LIGHTNINGSTREAM_VERSION="0.4.2" \
    BUILD_DEPS="g++ make postgresql-dev sqlite-dev curl boost-dev lmdb-dev go" \
    RUN_DEPS="bash libpq sqlite-libs libstdc++ libgcc postgresql-client sqlite lua-dev curl curl-dev boost-program_options jq lmdb boost-serialization inotify-tools" \
    POWERDNS_MODULES="bind gpgsql gsqlite3 lmdb"

# Build PowerDNS Authoritative Server and Lightningstream client.
FROM base AS build

RUN apk --update add $BUILD_DEPS $RUN_DEPS

RUN curl -sSL https://github.com/PowerDNS/lightningstream/archive/refs/tags/v$LIGHTNINGSTREAM_VERSION.tar.gz | tar xz -C /tmp/
WORKDIR /tmp/lightningstream-$LIGHTNINGSTREAM_VERSION
RUN sh -x ./build.sh

RUN curl -sSL https://downloads.powerdns.com/releases/pdns-$POWERDNS_VERSION.tar.bz2 | tar xj -C /tmp/
WORKDIR /tmp/pdns-$POWERDNS_VERSION

RUN ./configure --prefix="" --exec-prefix=/usr --sysconfdir=/etc/pdns --with-modules="$POWERDNS_MODULES"
RUN make
RUN DESTDIR="/pdnsbuild" make install-strip
RUN mkdir -p /pdnsbuild/etc/pdns/conf.d /pdnsbuild/etc/pdns/sql
RUN cp modules/gpgsqlbackend/*.sql modules/gsqlite3backend/*.sql /pdnsbuild/etc/pdns/sql/

# Build dnscontrol binary
FROM artifactory.algol60.net/docker.io/library/golang:1.21-alpine AS go-build

ENV DNSCONTROL_VERSION="v4.8.1"

RUN GOBIN=/tmp go install github.com/StackExchange/dnscontrol/v4@$DNSCONTROL_VERSION

# Assemble final image
FROM base

COPY --from=build /pdnsbuild /
COPY --from=build /tmp/lightningstream-$LIGHTNINGSTREAM_VERSION/bin/lightningstream /usr/local/bin/
COPY --from=go-build /tmp/dnscontrol /usr/local/bin
RUN apk add $RUN_DEPS && \
    addgroup -S pdns 2>/dev/null && \
    adduser -S -D -H -h /var/empty -s /bin/false -G pdns -g pdns pdns 2>/dev/null && \
    rm /var/cache/apk/* && \
    mkdir /var/run/pdns && \
    chown pdns:pdns /var/run/pdns


ENV AUTOCONF=mysql \
    AUTO_SCHEMA_MIGRATION="yes" \
    PGSQL_HOST="postgres" \
    PGSQL_PORT="5432" \
    PGSQL_USER="postgres" \
    PGSQL_PASS="postgres" \
    PGSQL_DB="pdns" \
    PGSQL_VERSION="4.7.0" \
    SQLITE_DB="pdns.sqlite3" \
    SQLITE_VERSION="4.3.1" \
    SCHEMA_VERSION_TABLE="_schema_version"

EXPOSE 5053/tcp 5053/udp 8081/tcp
ADD pdns.conf /etc/pdns/
ADD entrypoint.sh /bin/powerdns
RUN chown -R pdns:pdns /etc/pdns/
USER pdns
ENTRYPOINT ["powerdns"]
