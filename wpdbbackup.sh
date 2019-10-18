#!/bin/bash

# wpdbbackup.sh
# backup the databases for all of the WP sites in the web server directory

# local configuration
WEBROOT='/srv/www'
IGNORETHESE=( default  phpcs  wordpress-one  wordpress-two  wpclish )

cd $WEBROOT

# for each file in the in the WEBROOT directory
for fname in * ; do
  # is it a directory?
  if [ -d "$fname" ]; then
    # assume we don't want to skip the directory
    skipdir=0
    echo "Found directory $fname"
    # for each of the directories to ignore
    for ignoredir in ${IGNORETHESE[@]} ; do
      echo "Evaluating directory $fname against $ignoredir"
      if [ $ignoredir = $fname ] ; then
        echo "Skipping directory $fname"   
        skipdir=1
        break
      fi
    done
    if [ $skipdir -eq 0 ] ; then
      echo "Process directory $fname"
      timestamp=$(date +%Y-%m-%d_%H-%M-%S)
      echo "$fname-$timestamp.sql"
    fi
  fi
done
