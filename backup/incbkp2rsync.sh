#!/bin/bash
##
#
# This script will take cPanel incremental backups, tar every user into their
# own tar file and send it to an external server using rsync and keys
#
# Notes:
# 1. Choose how many process you want to run at the same time.
# 2. This script will not handle space in your remote storage. You have to lookup often to avoid issues.
# 3. If you interrupt the script, the processes will remain running in background, so you will have to kill them manually.
# 4. You have to create your keys and tell script where to find your private-key.
# 5. This script assumes you are root and will connect to your remote storage as root.
#
##

# Variables
remote_host="backup.myserver.com"
remote_dir="/home/mybackup"
key="/root/.ssh/mybackupprivatekey"
today=`date +%F`

# How many processes: 1, 2 or 5
proc=2

# Text Coloring
black()   { printf '\033[0m'; }
bgreen()  { printf '\033[1;32m'; }
bblue()   { printf '\033[1;34m'; }
byellow() { printf '\033[1;33m'; }
bcyan()   { printf '\033[1;36m'; }

# Main routine
do_routine(){
  echo "[$user] `bblue`starting`black`"
  echo "[$user] `bcyan`compacting`black`"; tar -cf $user.tar $user
  echo "[$user] `bgreen`sending`black`"; rsync --partial -aue "ssh -i $key" $user.tar root@$remote_host:$remote_dir/$today/
  echo "[$user] `byellow`removing`black`"; rm -f $user.tar;
  echo "[$user] `bgreen`done`black`"
}

# Removing any backups from previous run
cd /backup/incremental/accounts
echo "Removing any backups from previous run..."
rm -fv *.tar

# Starting to list each folder in /backup/incremental/accounts and run the do_routine function
case $proc in
  1)
    ls | while read user; do do_routine; done
  ;;
  2)
    ls -d [a-m]* | while read user; do do_routine; done &
    ls -d [n-z]* | while read user; do do_routine; done &
    ls -d [0-9]* | while read user; do do_routine; done
  ;;
  5)
    ls -d [a-e]* | while read user; do do_routine; done &
    ls -d [f-j]* | while read user; do do_routine; done &
    ls -d [k-o]* | while read user; do do_routine; done &
    ls -d [p-t]* | while read user; do do_routine; done &
    ls -d [u-z]* | while read user; do do_routine; done &
    ls -d [0-9]* | while read user; do do_routine; done
  ;;
esac
