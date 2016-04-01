#!/bin/bash

set -e

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

if [[ -z "$SQL_DUMP_FILE" ]]; then
        echo >&2 "error: missing required SQL_DUMP_FILE environment variable"
        echo >&2 "  Did you forget to -e SQL_DUMP_FILE=... ?"
        exit 1
fi


BACKUP_FILE_ABS_PATH="/backup/$BACKUP_FILE"
if [[ ! -e "$BACKUP_FILE_ABS_PATH" ]]; then
        echo >&2 "error: BACKUP_FILE ($BACKUP_FILE_ABS_PATH) does not exist"
        exit 1
fi




function replace_config_val() {
    local KEY=$1
    local VAL=$2
    local FILE=$3

    sed -i "s/\\\$$KEY *= *'[^']*'/\\\$$KEY = '$VAL'/" $FILE

}

ROOT_DIR='/var/www/html'
CONFIG='configuration.php'
CERTIFICATE_DEST='/etc/apache2/ssl/'
CERTIFICATE_NAME='certificate'
PLACEHOLDER='.placeholder'

cd $ROOT_DIR

if [[ ! -e "$PLACEHOLDER" ]]; then
    echo "!!! Restoring Files !!!"

    # remove existing joomla instalation
    rm * -rf

    # add backup file
    tar -zxf "$BACKUP_FILE_ABS_PATH"

    # chmod extracted data
    chown www-data:www-data . -R




    replace_config_val host "$JOOMLA_DB_HOST" "$CONFIG"
    replace_config_val db "$JOOMLA_DB_NAME" "$CONFIG"
    replace_config_val user "$JOOMLA_DB_USER" "$CONFIG"
    replace_config_val password "$JOOMLA_DB_PASSWORD" "$CONFIG"
    replace_config_val log_path "\/var\/www\/html\/public_html\/joomla\/joomla\/logs" "$CONFIG"
    replace_config_val tmp_path "\/var\/www\/html\/public_html\/joomla\/joomla\/tmp" "$CONFIG"


    SQL_FILE_ABS_PATH=`readlink -m "./$SQL_DUMP_FILE"`
    if [[ ! -e "$SQL_FILE_ABS_PATH" ]]; then
            echo >&2 "error: SQL_DUMP_FILE ($SQL_FILE_ABS_PATH) does not exist!"
            exit 1
    fi

    echo "!!! Restoring DB !!!"
    php /bootstrap/makedb.php "$JOOMLA_DB_HOST" "$JOOMLA_DB_USER" "$JOOMLA_DB_PASSWORD" "$JOOMLA_DB_NAME" "$SQL_FILE_ABS_PATH"


    echo "!!! Configuring Apache !!!"
    cd /etc/apache2/mods-enabled

    ln -s ../mods-available/ssl.* . || true
    ln -s ../mods-available/socache_shmcb.* . || true

    cp /bootstrap/apache2.conf /etc/apache2/ -f

    mkdir "$CERTIFICATE_DEST"  || true
    cd "$CERTIFICATE_DEST"

    if  [[ -z "$SSL_CERTIFICATE_FILE" ]]; then
        echo "!!! Generating SSL Certificate !!!"
        /bootstrap/generate_certificate.sh certificate
    else
        cp "$SSL_CERTIFICATE_FILE" .
    fi
    chmod 600 $CERTIFICATE_DEST -R

    touch "$PLACEHOLDER"

fi

exec apache2-foreground
