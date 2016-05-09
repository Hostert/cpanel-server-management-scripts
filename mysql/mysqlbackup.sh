#!/bin/bash
#
# This script makes simple bzip2 backups and deletes older
#

# Delete files older than...
retention=3 # days

# Text Coloring
black()   { printf '\033[0m'; }
bgreen()  { printf '\033[1;32m'; }
bblue()   { printf '\033[1;34m'; }

if [ ! -e /backup/mysql ]; then
  mkdir /backup/mysql
fi

cd /backup/mysql/
echo "`bblue`Deleting older backup files`black`"
find -mtime +$retention -delete -print

mysql -Ns -e "show databases" | egrep -v 'cphulk|cptmpdb|eximstats|information_schema|performance_schema|mysql' | while read db; do

  echo -n "[$db] `bblue`starting`black`"
  mysqldump $db | bzip2 > $db.`date +%F`.sql.bz2
  echo "[$db] `bgreen`finished`black`"

done
