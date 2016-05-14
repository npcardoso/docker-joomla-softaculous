#!/bin/bash

set -e

SQL_DUMP_FILE=softsql.sql

BASE_DIR=`dirname $0`
BASE_DIR=`readlink -m $BASE_DIR`

BACKUP_DIR="backup"
WEB_DIR=$BASE_DIR/"web"
WEB_BACKUP_DIR=$WEB_DIR/$BACKUP_DIR

DB_DIR=$BASE_DIR/"db"
DB_BACKUP_DIR=$DB_DIR/$BACKUP_DIR

BACKUP_FILE=`readlink -m "$1"`

if [[ $# != 1 ]]; then
    echo "Usage: $0 <backup.tar.gz>"
    exit 1
fi


function recreate_dir() {
    rm $1 -rfv
    mkdir $1
}

recreate_dir "$WEB_BACKUP_DIR"
recreate_dir "$DB_BACKUP_DIR"

cd $WEB_BACKUP_DIR

tar -zxvf $BACKUP_FILE

mv $SQL_DUMP_FILE $DB_BACKUP_DIR/dump.sql

cd $BASE_DIR

docker-compose build
