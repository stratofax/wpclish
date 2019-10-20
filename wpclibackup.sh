#!/bin/bash
# backup the WordPress database in the current 
# directory tree to the specifed destination
# by Neil Johnson, neil@cadent.com

# error codes
WPDIRMISSING=1
NOWPDIR=2
STORAGEDIRMISSING=3
NOSTORAGEDIR=4
INVALIDWP=5
NOWPCLI=6
CURRENTDIR=$(pwd)

showusage() {
    echo "usage: $0 wpdir backupdir"
}

# give our function paramaeters useful names,
# strip trailing slashes
wppath=$(echo $1 | sed 's:/*$::')
backuppath=$(echo $2 | sed 's:/*$::')

# wppath=$(readlink -F $1)
# backuppath=$(readlink -F $2)

if [ ! $wppath ]; then
    echo "ERROR: path to WordPress installation missing."
    showusage
    exit $WPDIRMISSING
fi

if [ ! -d  $wppath ]; then
    echo "ERROR: the specified WordPress directory,"
    echo "       $wppath"
    echo "       does not exist."
    showusage
    exit $NOWPDIR
fi

if [ ! $backuppath ]; then
    echo "ERROR: path to backup directory missing."
    showusage
    exit $STORAGEDIRMISSING
fi

if [ ! -d  $backuppath ]; then
    echo "ERROR: the specified backup directory,"
    echo "       $backuppath"
    echo "       does not exist."
    showusage
    exit $NOSTORAGEDIR
fi

wpbase=$(basename $wppath)

echo "WP path:     $wppath"
echo "WP base:     $wpbase"
echo "Backup path: $backuppath"

# create file names
timestamp=$(date +%Y-%m-%d_%H-%M-%S)
backupfile="$backuppath/$wpbase-$timestamp.sql"
tarfile=$backupfile.tar.gz
cd $wppath
wp cli version
if [ $? -gt 0 ] ; then
    cd $CURRENTDIR
    echo "ERROR: WP-CLI is not installed correctly."
    showusage
    exit $ NOWPCLI
fi

# create the backup file and capture the size

echo "Creating backup file: $backupfile ..."
wp db export $backupfile
if [ $? -eq 0 ] ; then
    echo "execute!"
    # local backupsize=$(wc -c $backupfile | awk '{print $1}')
    # echo "Backed up $backupsize bytes to $backupfile."
    # # compress the backup, remove the original, caputure size
    # echo "Compressing $backupfile ..."
    # tar -czvf $tarfile $backupfile
    # rm $backupfile
    # local tarsize=$(wc -c $tarfile | awk '{print $1}')
    # echo "Compressed $backupsize bytes to $tarsize in file:"
    # echo $tarfile
    # # how much space did we save?
    # local savings=$(( $backupsize - $tarsize ))
    # echo "Saved $savings bytes."
    cd $CURRENTDIR
else
    cd $CURRENTDIR
    echo "ERROR: the specified WordPress directory,"
    echo "       $wppath"
    echo "      is not a valid WP-CLI installation."
    showusage
    exit $INVALIDWP
fi