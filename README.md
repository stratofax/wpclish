# wpclish
WP-CLI bash scripts to maintain WordPress installations. These scripts work on servers where your WordPress websites are all stored in the same "webroot" directory. If these scripts are installed correctly, they will calculate any required pathnames correctly.

A typical webroot directory looks like this:

* `/home/user/public_html`
* `/srv/www/`

Inside of the webroot directory, your server will host one or more website directories.

These scripts work with WordPress installations

## Requirements

* A web server with bash configured correctly
* A user account to run these scripts with read and write access to the webroot directory (ideally *not* "root")

## Installation 

1. Unzip or clone (using git) the `wpclish` directory (this repository) into your webroot directory. **Do not** place the directory inside a website subdirectory, as this poses a major security risk!
2. Run the scripts at the command line via SSH to test them on your system.
3. Once you've demonstrated that the scripts work you can also set up a cron job for each script.

## Script Summmaries

A brief description of each script.

### wpdbbackup.sh

This script backs up all of the sites found in the webroot directory. The script assumes you've placed this code repository in the webroot directory with the website directories. It will also create a `sqlbackup` directory to store the compressed backup files in the webroot directory.

The script will:

1. Check each directory inside the webroot directory.
2. Ignore any directories on the ignore list.
3. For the remaining directories, attempt to check the WordPress database.
4. If the check is successful, the script will backup and compress the WordPress database to the `sqlbackup` directory.
5. Then, the script will optimize the WordPress database and back up the optimized version.