#!/bin/bash
# backup the WordPress database in the current 
# directory tree to the specifed destination
# by Neil Johnson, neil@cadent.com

# error codes
E_WPDIRMISSING=1
E_WPDIRNOTFOUND=2
E_STORAGEDIRMISSING=3
E_NOSTORAGEDIR=4
E_BACKUPFAIL=5
E_BADWPCLI=6
current_dir=$(pwd)

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
    exit $E_WPDIRMISSING
fi

if [ ! -d  $wppath ]; then
    echo "ERROR: the specified WordPress directory,"
    echo "       $wppath"
    echo "       does not exist."
    showusage
    exit $E_WPDIRNOTFOUND
fi

if [ ! $backuppath ]; then
    echo "ERROR: path to backup directory missing."
    showusage
    exit $E_STORAGEDIRMISSING
fi

if [ ! -d  $backuppath ]; then
    echo "ERROR: the specified backup directory,"
    echo "       $backuppath"
    echo "       does not exist."
    showusage
    exit $E_NOSTORAGEDIR
fi

wpbase=$(basename $wppath)

echo "WP path:     $wppath"
echo "WP base:     $wpbase"
echo "Backup path: $backuppath"

# create file names
timestamp=$(date +%Y-%m-%d_%H-%M-%S)
backupfile="$backuppath/$wpbase-$timestamp.sql"
tarfile=$backupfile.tar.gz

# change to the working directory
cd $wppath
# test for a working installation of WP-CLI
wp cli version
if [ $? -gt 0 ] ; then
    cd $current_dir
    echo "ERROR: WP-CLI is not installed correctly."
    showusage
    exit $ E_BADWPCLI
fi

# create the backup file and capture the size
echo "Creating backup file: $backupfile ..."
wp db export $backupfile
if [ $? -eq 0 ] ; then
    backupsize=$(wc -c $backupfile | awk '{print $1}')
    echo "Backed up $backupsize bytes to $backupfile."
    # compress the backup, remove the original, caputure size
    echo "Compressing $backupfile ..."
    tar -czvf $tarfile $backupfile
    rm $backupfile
    tarsize=$(wc -c $tarfile | awk '{print $1}')
    echo "Compressed $backupsize bytes to $tarsize in file:"
    echo $tarfile
    # how much space did we save?
    savings=$(( $backupsize - $tarsize ))
    echo "Saved $savings bytes."
    cd $current_dir
else
    cd $current_dir
    echo "ERROR: the WordPress database export from"
    echo "       $wppath"
    echo "       failed."
    showusage
    exit $E_BACKUPFAIL
fi