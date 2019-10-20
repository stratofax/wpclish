#!/bin/bash
# wpmultibackup.sh
# backup the databases for all of the WP sites in the web server directory
# by Neil Johnson, neil@cadent.com

# get the location of the script file a
CURRENTDIR=$(pwd)
SCRIPTPATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# go to the script directory, should be contained in the web root
cd $SCRIPTPATH
cd ..

# important directories
WEBROOT=$(pwd)
BACKUPDIR='sqlbackup'
SCRIPTDIR='wpclish'
BACKUPPATH="$WEBROOT/$BACKUPDIR/"
# this list includes default directories in a VVV installation
IGNORETHESE=( $BACKUPDIR $SCRIPTDIR default phpcs wordpress-one wordpress-two )

wpclibackup () {
  # give our function paramaeters useful names
  local targetdir=$1
  local storagedir=$2
  # create file names
  local timestamp=$(date +%Y-%m-%d_%H-%M-%S)
  local backupfile="$storagedir$targetdir-$timestamp.sql"
  local tarfile=$backupfile.tar.gz
  # create the backup file and capture the size
  echo "Creating backup file: $backupfile ..."
  wp db export $backupfile
  local backupsize=$(wc -c $backupfile | awk '{print $1}')
  echo "Backed up $backupsize bytes to $backupfile."
  # compress the backup, remove the original, caputure size
  echo "Compressing $backupfile ..."
  tar -czvf $tarfile $backupfile
  rm $backupfile
  local tarsize=$(wc -c $tarfile | awk '{print $1}')
  echo "Compressed $backupsize bytes to $tarsize in file:"
  echo $tarfile
  # how much space did we save?
  local savings=$(( $backupsize - $tarsize ))
  echo "Saved $savings bytes."
}

cd $WEBROOT
# set up counters
processedtotal=0
skippedtotal=0

# check for backup directory
if [ ! -d "$BACKUPPATH" ]; then
  echo "Creating backup directory: $BACKUPDIR"
  mkdir $BACKUPDIR
fi

# if the backup directory doesn't exist, there's a problem!
if [ ! -d "$BACKUPPATH" ]; then
  echo "ERROR: unable to create backup directory: $BACKUPDIR"
  echo "Script $basename terminated."
  exit 1
fi

# find all the subdirectories in the WEBROOT directory
for fname in * ; do
  # is it a directory?
  if [ -d "$fname" ]; then
    # assume we don't want to skip the directory
    skipdir=0
    printf "Found directory $fname ... "

    # for each of the directories to ignore
    for ignoredir in ${IGNORETHESE[@]} ; do
      if [ $ignoredir = $fname ] ; then
        echo "skipped."   
        skipdir=1
        let "skippedtotal+=1" 
        # if we got a match, we're done!
        break
      fi
    done
    
    if [ $skipdir -eq 0 ] ; then
      cd $fname
      currentwpdir=$(pwd)
      echo "Now processing WordPress site in $currentwpdir"

      # if this db check doesn't work, we have a problem!
      wp db check
      if [ $? -eq 0 ] ; then
        echo "Calculating WordPress database size ..."
        wp db size
        # back up the database before beginning maintenance
        wpclibackup $fname $BACKUPPATH
        # optimize and back up again
        wp db optimize
        wp db size
        wpclibackup $fname $BACKUPPATH
        # track total number of sites processed
        let "processedtotal+=1"
      else
        echo "Not a valid WordPress installation ... skipped."
        skipdir=2
        let "skippedtotal+=1" 
      fi
      # back to webroot
      cd $WEBROOT
    fi
  fi
done

echo "Processed $processedtotal and skipped $skippedtotal directories."
cd $CURRENTDIR