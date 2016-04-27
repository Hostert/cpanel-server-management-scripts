#!/bin/sh
#
# Rotate you server IPs in /etc/mailips.
# https://documentation.cpanel.net/display/CKB/How+to+Configure+Exim%2527s+Outgoing+IP+Address#HowtoConfigureExim'sOutgoingIPAddress-The/etc/mailipsfile
#
# Notes:
# 1. This script assumes you have /etc/ips filled with your server IPs.
# The file looks like this:
#
# 192.168.100.200:255.255.255.0:192.168.100.255
# 192.168.100.201:255.255.255.0:192.168.100.255
# 192.168.100.202:255.255.255.0:192.168.100.255
#
# If your server don't have this file, create it manually.
#
# 2. If you don't want this script to use all your IPs, you should add those IPs
# to #excluded file.
#
# 3. This script will run forever (while true), so if you modify reserved IPs,
# you will have to kill it and run again.
#
# 4. This script will update /etc/mailips and put a new global outgoing IP. If
# you have customizations, this will not work for you.
#
# Don't worry if you read this after you ran the script. I made a backup of your
# customizations to /etc/mailips.bkp
# You can thank me later ;)
##

# Set the time to wait until a new IP rotation. In seconds.
sleeptime=300 # 5 minutes

# Backing up any customizations
cp -nv /etc/mailips{,.bkp}

# Check if we have a file containing reserved/excluded IPs
excluded="/root/mailipsrotation.excluded"
if [ ! -e "$excluded" ]; then
  touch $excluded
fi

# Generate the array of IPs we will use to rotate
included=(
  `cat /var/cpanel/mainip | grep -v -f $excluded`
  `awk -F: {'print $1'} /etc/ips | grep -v -f $excluded`
)
numips=`echo ${#included[@]}`

while true; do
  theone=`shuf -i 1-$numips -n 1`
  echo "*: $theone" > /etc/mailips
  echo "`date` -> $theone"

  # Debug / Log
  #
  # echo "===========================
  # `date`
  # Mailips: `cat /etc/mailips`
  # ===========================" >> /root/mailips.log

  sleep $sleeptime
done
