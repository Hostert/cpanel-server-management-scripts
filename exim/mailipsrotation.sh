#!/bin/sh
#
# Rotate you server IPs in /etc/mailips
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
# 2. This script will run forever (while true), so if you modify reserved IPs, you
# have to kill it and run again.
#
##

# Set the time to wait until a new IP rotation. In seconds.
sleeptime=300 # 5 minutes

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
  echo $theone

  # Debug / Log
  #
  # echo "===========================
  # `date`
  # Mailips: `cat /etc/mailips`
  # ===========================" >> /root/mailips.log

  sleep $sleeptime
done
