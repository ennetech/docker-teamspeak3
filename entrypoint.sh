#!/usr/bin/env bash
cd /ts3

mc config host add srv $S3_SERVER $S3_USER $S3_PASSWORD
BUCKET_SERVICE=srv/$S3_BUCKET

DB_FILE=$BUCKET_SERVICE/ts3server.sqlitedb
LIC_FILE=$BUCKET_SERVICE/licensekey.dat
ID_FILE=$BUCKET_SERVICE/serverkey.dat
FILES_DIR=$BUCKET_SERVICE/files


echo "Checking for databse backup"
mc stat $DB_FILE
if [ "$?" -eq 0 ];then
    echo "we have a remote backup"
    mc cp $DB_FILE /ts3/ts3server.sqlitedb
fi

mc stat $LIC_FILE
if [ "$?" -eq 0 ];then
    echo "we have a remote license"
    mc cp $LIC_FILE /ts3/licensekey.dat
fi

mc stat $ID_FILE
if [ "$?" -eq 0 ];then
    echo "we have a remote identification"
    mc cp $ID_FILE /ts3/serverkey.dat
fi

mc stat $FILES_DIR
if [ "$?" -eq 0 ];then
    echo "we have a remote files backup"
    mc cp -r $FILES_DIR /ts3
fi

_daemon() {
  while true; do
    sleep $BACKUP_INTERVAL
    echo "Daemon here..."
    echo "Snapshot"
    HHH="$(date +"%Y%m%d_%H%M%S")-$(hostname)"
    mc cp -r /ts3/files $BUCKET_SERVICE/$HHH
    mc cp /ts3/ts3server.sqlitedb $BUCKET_SERVICE/$HHH/ts3server.sqlitedb
    echo "... daemon done"
  done
}

_daemon &

./ts3server start

echo "Snapshot"
HHH="$(date +"%Y%m%d_%H%M%S")-$(hostname)"
mc cp -r /ts3/files $BUCKET_SERVICE/$HHH
mc cp /ts3/ts3server.sqlitedb $BUCKET_SERVICE/$HHH/ts3server.sqlitedb

echo "Backing up files"
mc cp -r /ts3/files $BUCKET_SERVICE

echo "Backing up database"
mc cp /ts3/ts3server.sqlitedb $BUCKET_SERVICE/ts3server.sqlitedb