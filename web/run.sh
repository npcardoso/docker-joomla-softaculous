#!/bin/bash

set -e

CONFIG="$ROOT_DIR/configuration.php"

function replace_config_val() {
    local KEY=$1
    local VAL=$2
    local FILE=$3

    sed -i "s/\\\$$KEY *= *'[^']*'/\\\$$KEY = '$VAL'/" $FILE

}


if [ -n "$MYSQL_PORT_3306_TCP" ]; then
    if [ -z "$JOOMLA_DB_HOST" ]; then
        JOOMLA_DB_HOST='mysql'
    else
        echo >&2 "warning: both JOOMLA_DB_HOST and MYSQL_PORT_3306_TCP found"
        echo >&2 "  Connecting to JOOMLA_DB_HOST ($JOOMLA_DB_HOST)"
        echo >&2 "  instead of the linked mysql container"
    fi
fi

if [ -z "$JOOMLA_DB_HOST" ]; then
    echo >&2 "error: missing JOOMLA_DB_HOST and MYSQL_PORT_3306_TCP environment variables"
    echo >&2 "  Did you forget to --link some_mysql_container:mysql or set an external db"
    echo >&2 "  with -e JOOMLA_DB_HOST=hostname:port?"
    exit 1
fi

# If the DB user is 'root' then use the MySQL root password env var
: ${JOOMLA_DB_USER:=root}
if [ "$JOOMLA_DB_USER" = 'root' ]; then
    : ${JOOMLA_DB_PASSWORD:=$MYSQL_ENV_MYSQL_ROOT_PASSWORD}
fi
: ${JOOMLA_DB_NAME:=joomla}

if [ -z "$JOOMLA_DB_PASSWORD" ]; then
    echo >&2 "error: missing required JOOMLA_DB_PASSWORD environment variable"
    echo >&2 "  Did you forget to -e JOOMLA_DB_PASSWORD=... ?"
    echo >&2
    echo >&2 "  (Also of interest might be JOOMLA_DB_USER and JOOMLA_DB_NAME.)"
    exit 1
fi


# update configuration files
replace_config_val host "$JOOMLA_DB_HOST" "$CONFIG"
replace_config_val db "$JOOMLA_DB_NAME" "$CONFIG"
replace_config_val user "$JOOMLA_DB_USER" "$CONFIG"
replace_config_val password "$JOOMLA_DB_PASSWORD" "$CONFIG"
replace_config_val log_path "\/var\/www\/html\/public_html\/joomla\/joomla\/logs" "$CONFIG"
replace_config_val tmp_path "\/var\/www\/html\/public_html\/joomla\/joomla\/tmp" "$CONFIG"

chown www-data:www-data ${ROOT_DIR} -R

exec apache2-foreground
