#!/bin/bash
# wpmultibackup.sh
# backup the databases for all of the WP sites in the web server directory
# by Neil Johnson, neil@cadent.com

# get the location of the script file a
CurrentDir=$(pwd)
ScriptPath="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# go to the script directory, should be contained in the web root
cd $ScriptPath
cd ..

# important directories
WebRoot=$(pwd)
BackupDir='sqlbackup'
ScriptDir='wpclish'
BackupPath="$WebRoot/$BackupDir/"
# this list includes default directories in a VVV installation
IgnoreThese=( $BackupDir $ScriptDir default phpcs wordpress-one wordpress-two )

# wpclibackup () {
#   # give our function paramaeters useful names
#   local targetdir=$1
#   local storagedir=$2
#   # create file names
#   local timestamp=$(date +%Y-%m-%d_%H-%M-%S)
#   local backupfile="$storagedir$targetdir-$timestamp.sql"
#   local tarfile=$backupfile.tar.gz
#   # create the backup file and capture the size
#   echo "Creating backup file: $backupfile ..."
#   wp db export $backupfile
#   local backupsize=$(wc -c $backupfile | awk '{print $1}')
#   echo "Backed up $backupsize bytes to $backupfile."
#   # compress the backup, remove the original, caputure size
#   echo "Compressing $backupfile ..."
#   tar -czvf $tarfile $backupfile
#   rm $backupfile
#   local tarsize=$(wc -c $tarfile | awk '{print $1}')
#   echo "Compressed $backupsize bytes to $tarsize in file:"
#   echo $tarfile
#   # how much space did we save?
#   local savings=$(( $backupsize - $tarsize ))
#   echo "Saved $savings bytes."
# }

cd $WebRoot
# set up counters
processedtotal=0
skippedtotal=0

# check for backup directory
if [ ! -d "$BackupPath" ]; then
  echo "Creating backup directory: $BackupDir"
  mkdir $BackupDir
fi

# if the backup directory doesn't exist, there's a problem!
if [ ! -d "$BackupPath" ]; then
  echo "ERROR: unable to create backup directory: $BackupDir"
  echo "Script $basename terminated."
  exit 1
fi

# find all the subdirectories in the WebRoot directory
for fname in * ; do
  # is it a directory?
  if [ -d "$fname" ]; then
    # assume we don't want to skip the directory
    skipdir=0
    printf "Found directory $fname ... "

    # for each of the directories to ignore
    for ignoredir in ${IgnoreThese[@]} ; do
      if [ $ignoredir = $fname ] ; then
        echo "skipped."   
        skipdir=1
        ((skippedtotal++))
        # if we got a match, we're done!
        break
      fi
    done
    
    if [ $skipdir -eq 0 ] ; then
      cd $fname
      currentwpdir=$(pwd)
      echo "Now processing WordPress site in $currentwpdir"
      # let's check the size of the db to see if we can use WP-CLI
      wp db size
      if [ $? -eq 0 ] ; then
        echo "Calculating WordPress database size ..."
        # back up the database before beginning maintenance
        $ScriptPath/wpclibackup.sh $fname $BackupPath
        # optimize and back up again
        wp db optimize
        wp db size
        $ScriptPath/wpclibackup.sh $fname $BackupPath
        # track total number of sites processed
        ((processedtotal++))
      else
        echo "Not a valid WordPress installation ... skipped."
        skipdir=2
        ((skippedtotal++))
      fi
      # back to WebRoot
      cd $WebRoot
    fi
  fi
done

echo "Processed $processedtotal and skipped $skippedtotal directories."
cd $CurrentDir