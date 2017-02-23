#!/bin/bash
#=========================================================================================
# Bash Script
#
# NAME: check_uptime.sh
# AUTHOR:  Tant, Alek - SmartAlek Solutions
# DATE  : 2015.06.15
#
# PURPOSE: Returns uptime of machine.
#
# CHANGE LOG:
#
# NOTES:
#   This version will warn if the machine has an uptime of less than 1 day
#

uptime=`uptime | awk '{print $2,$3,$4,$5}'`
uptime1=${uptime%,}
dayshours=${uptime1%%:*}' Hours, '
minutes=${uptime1##*:}' Minutes'

days=`echo $uptime | awk '{print $2}'`

if [[ $days -eq 0 ]]
then
	echo "WARNING - System Uptime -" $dayshours$minutes
	exit 1
else
	echo "System Uptime -" $dayshours$minutes
	exit 0
fi
