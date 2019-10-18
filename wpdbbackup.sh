#!/bin/bash

# wpdbbackup.sh
# backup the databases for all of the WP sites in the web server directory

# local configuration
WEBROOT='/srv/www/'
BACKUPDIR='sqlbackup'
SCRIPTDIR='wpclish'
BACKUPPATH="$WEBROOT$BACKUPDIR/"
IGNORETHESE=( $BACKUPDIR $SCRIPTDIR default  phpcs wordpress-one  wordpress-two )

cd $WEBROOT
# set up counters
processedtotal=0
skippedtotal=0

# check for backup directory
if [ ! -d "$BACKUPPATH" ]; then
  echo "Creating backup directory: $BACKUPDIR"
  mkdir $BACKUPDIR
fi

# for each file in the in the WEBROOT directory
for fname in * ; do
  # is it a directory?
  if [ -d "$fname" ]; then
    # assume we don't want to skip the directory
    skipdir=0
    echo "Found directory $fname ..."
    # for each of the directories to ignore
    for ignoredir in ${IGNORETHESE[@]} ; do
      if [ $ignoredir = $fname ] ; then
        echo "Skipping directory $fname"   
        skipdir=1
        let "skippedtotal+=1" 
        break
      fi
    done
    if [ $skipdir -eq 0 ] ; then
      echo "Processing directory $fname ..."
      # enter the website directory
      cd $fname
      pwd
      # create file names
      timestamp=$(date +%Y-%m-%d_%H-%M-%S)
      backupfile="$BACKUPPATH$fname-$timestamp.sql"
      tarfile=$backupfile.tar.gz
      echo "Creating backup file: $backupfile ..."
      wp db export $backupfile
      backupsize=$(wc -c $backupfile | awk '{print $1}')
      echo "Backed up $backupsize bytes to $backupfile."
      echo "Compressing $backupfile ..."
      tar -czvf $tarfile $backupfile
      rm $backupfile
      tarsize=$(wc -c $tarfile | awk '{print $1}')
      echo "Compressed $backupsize bytes to $tarsize in file:"
      echo $tarfile
      savings=$(( $backupsize - $tarsize ))
      echo "Saved $savings bytes."
      let "processedtotal+=1"
      #back to webroot
      cd $WEBROOT
    fi
  fi
done
echo "Processed $processedtotal and skipped $skippedtotal directories."
