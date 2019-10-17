#!/bin/bash

# wpdbbackup.sh
# backup the databases for all of the WP sites in the web server directory

WEBROOT='/srv/www'

cd $WEBROOT
for i in * ; do
  if [ -d "$i" ]; then
    echo "$i"
  fi
done
