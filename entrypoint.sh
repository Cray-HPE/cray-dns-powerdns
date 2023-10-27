#!/bin/bash
set -e

[[ -z "$TRACE" ]] || set -x

# --help, --version
[ "$1" = "--help" ] || [ "$1" = "--version" ] && exec pdns_server $1

# treat everything except -- as exec cmd
[ "${1:0:2}" != "--" ] && exec "$@"

# Setup the API key configuration.
echo "api-key=$API_KEY" > /etc/pdns/conf.d/01-api-key.conf

# Add backward compatibility
#AUTOCONF=false

# Set credentials to be imported into pdns.conf
case "$AUTOCONF" in
  postgres)
    export PDNS_LOAD_MODULES=$PDNS_LOAD_MODULES,libgpgsqlbackend.so
    export PDNS_LAUNCH=gpgsql
    export PDNS_GPGSQL_HOST=${PDNS_GPGSQL_HOST:-$PGSQL_HOST}
    export PDNS_GPGSQL_PORT=${PDNS_GPGSQL_PORT:-$PGSQL_PORT}
    export PDNS_GPGSQL_USER=${PDNS_GPGSQL_USER:-$PGSQL_USER}
    export PDNS_GPGSQL_PASSWORD=${PDNS_GPGSQL_PASSWORD:-$PGSQL_PASS}
    export PDNS_GPGSQL_DBNAME=${PDNS_GPGSQL_DBNAME:-$PGSQL_DB}
    export PDNS_GPGSQL_DNSSEC=${PDNS_GPGSQL_DNSSEC:-$PGSQL_DNSSEC}
    export PGPASSWORD=$PDNS_GPGSQL_PASSWORD
  ;;
  lmdb)
    export PDNS_LAUNCH=lmdb
    export PDNS_LMDB_FILENAME=/lmdb/lmdb
    export PDNS_LMDB_SHARDS=1
    export PDNS_LMDB_RANDOM_IDS=yes
    export PDNS_LMDB_FLAG_DELETED=yes
    export PDNS_LMDB_MAP_SIZE=1000
    export PDNS_ZONE_CACHE_REFRESH_INTERVAL=0
    export PDNS_ZONE_METADATA_CACHE_TTL=0
  ;;
  sqlite)
    export PDNS_LOAD_MODULES=$PDNS_LOAD_MODULES,libgsqlite3backend.so
    export PDNS_LAUNCH=gsqlite3
    export PDNS_GSQLITE3_DATABASE=${PDNS_GSQLITE3_DATABASE:-$SQLITE_DB}
    export PDNS_GSQLITE3_PRAGMA_SYNCHRONOUS=${PDNS_GSQLITE3_PRAGMA_SYNCHRONOUS:-$SQLITE_PRAGMA_SYNCHRONOUS}
    export PDNS_GSQLITE3_PRAGMA_FOREIGN_KEYS=${PDNS_GSQLITE3_PRAGMA_FOREIGN_KEYS:-$SQLITE_PRAGMA_FOREIGN_KEYS}
    export PDNS_GSQLITE3_DNSSEC=${PDNS_GSQLITE3_DNSSEC:-$DNSSEC}
  ;;
esac

PGSQLCMD="psql --host=$PGSQL_HOST --username=$PGSQL_USER $PGSQL_DB"
SQLITECMD="sqlite3 $PDNS_GSQLITE3_DATABASE"

# wait for Database come ready
isDBup () {
  case "$PDNS_LAUNCH" in
    gpgsql)
      echo "SELECT 1" | $PGSQLCMD 1>/dev/null
      echo $?
    ;;
    *)
      echo 0
    ;;
  esac
}

RETRY=10
until [ `isDBup` -eq 0 ] || [ $RETRY -le 0 ] ; do
  echo "Waiting for database to come up"
  sleep 5
  RETRY=$(expr $RETRY - 1)
done
if [ $RETRY -le 0 ]; then
  if [[ "$PGSQL_HOST" ]]; then
    >&2 echo Error: Could not connect to Database on $PGSQL_HOST:$PGSQL_PORT
    exit 1
  fi
fi

# init database and migrate database if necessary
case "$PDNS_LAUNCH" in
  gpgsql)
    if [[ -z "$(echo "SELECT 1 FROM pg_database WHERE datname = '$PGSQL_DB'" | $PGSQLCMD -t)" ]]; then
      echo "CREATE DATABASE $PGSQL_DB;" | $PGSQLCMD
    fi
    if [[ -z "$(printf '\dt' | $PGSQLCMD -qAt)" ]]; then
      echo Initializing Database
      cat /etc/pdns/sql/schema.pgsql.sql | $PGSQLCMD
      INITIAL_DB_VERSION=$PGSQL_VERSION
    fi
    if [ "$AUTO_SCHEMA_MIGRATION" == "yes" ]; then
      # init version database if necessary
      if [[ -z "$(echo "SELECT to_regclass('public.$SCHEMA_VERSION_TABLE');" | $PGSQLCMD -qAt)" ]]; then
        [ -z "$INITIAL_DB_VERSION" ] && >&2 echo "Error: INITIAL_DB_VERSION is required when you use AUTO_SCHEMA_MIGRATION for the first time" && exit 1
        echo "CREATE TABLE $SCHEMA_VERSION_TABLE (id SERIAL PRIMARY KEY, version VARCHAR(255) DEFAULT NULL)" | $PGSQLCMD
        echo "INSERT INTO $SCHEMA_VERSION_TABLE (version) VALUES ('$INITIAL_DB_VERSION');" | $PGSQLCMD
        echo "Initialized schema version to $INITIAL_DB_VERSION"
      fi
      # do the database upgrade
      while true; do
        current="$(echo "SELECT version FROM $SCHEMA_VERSION_TABLE ORDER BY id DESC LIMIT 1;" | $PGSQLCMD -qAt)"
        if [ "$current" != "$PGSQL_VERSION" ]; then
          filename=/etc/pdns/sql/${current}_to_*_schema.pgsql.sql
          echo "Applying Update $(basename $filename)"
          $PGSQLCMD < $filename
          current=$(basename $filename | sed -n 's/^[0-9.]\+_to_\([0-9.]\+\)_.*$/\1/p')
          echo "INSERT INTO $SCHEMA_VERSION_TABLE (version) VALUES ('$current');" | $PGSQLCMD
        else
          break
        fi
      done
    fi
  ;;
  gsqlite3)
    if [[ ! -f "$PDNS_GSQLITE3_DATABASE" ]]; then
      install -D -d -o pdns -g pdns -m 0755 $(dirname $PDNS_GSQLITE3_DATABASE)
      cat /etc/pdns/sql/schema.sqlite3.sql | $SQLITECMD
      chown pdns:pdns $PDNS_GSQLITE3_DATABASE
      INITIAL_DB_VERSION=$SQLITE_VERSION
    fi
    if [ "$AUTO_SCHEMA_MIGRATION" == "yes" ]; then
      # init version database if necessary
      if [[ "$(echo "SELECT count(*) FROM sqlite_master WHERE type='table' AND name='$SCHEMA_VERSION_TABLE';" | $SQLITECMD)" -eq 0 ]]; then
        [ -z "$INITIAL_DB_VERSION" ] && >&2 echo "Error: INITIAL_DB_VERSION is required when you use AUTO_SCHEMA_MIGRATION for the first time" && exit 1
        echo "CREATE TABLE $SCHEMA_VERSION_TABLE (id INTEGER PRIMARY KEY, version VARCHAR(255) NOT NULL)" | $SQLITECMD
        echo "INSERT INTO $SCHEMA_VERSION_TABLE (version) VALUES ('$INITIAL_DB_VERSION');" | $SQLITECMD
        echo "Initialized schema version to $INITIAL_DB_VERSION"
      fi
      # do the database upgrade
      while true; do
        current="$(echo "SELECT version FROM $SCHEMA_VERSION_TABLE ORDER BY id DESC LIMIT 1;" | $SQLITECMD)"
        if [ "$current" != "$SQLITE_VERSION" ]; then
          filename=/etc/pdns/sql/${current}_to_*_schema.sqlite3.sql
          echo "Applying Update $(basename $filename)"
          $SQLITECMD < $filename
          current=$(basename $filename | sed -n 's/^[0-9.]\+_to_\([0-9.]\+\)_.*$/\1/p')
          echo "INSERT INTO $SCHEMA_VERSION_TABLE (version) VALUES ('$current');" | $SQLITECMD
        else
          break
        fi
      done

    fi
  ;;
esac

# convert all environment variables prefixed with PDNS_ into pdns config directives
PDNS_LOAD_MODULES="$(echo $PDNS_LOAD_MODULES | sed 's/^,//')"
printenv | grep ^PDNS_ | cut -f2- -d_ | while read var; do
  val="${var#*=}"
  var="${var%%=*}"
  var="$(echo $var | sed -e 's/_/-/g' | tr '[:upper:]' '[:lower:]')"
  [[ -z "$TRACE" ]] || echo "$var=$val"
  (grep -qE "^[# ]*$var=.*" /etc/pdns/conf.d/03-db-creds.conf && sed -r -i "s#^[# ]*$var=.*#$var=$val#g" /etc/pdns/conf.d/03-db-creds.conf) || echo "$var=$val" >> /etc/pdns/conf.d/03-db-creds.conf
done

# environment hygiene
for var in $(printenv | cut -f1 -d= | grep -v -e HOME -e USER -e PATH ); do unset $var; done
export TZ=UTC LANG=C LC_ALL=C

# prepare graceful shutdown
trap "pdns_control quit" SIGHUP SIGINT SIGTERM

# run the server
pdns_server "$@" &

wait
