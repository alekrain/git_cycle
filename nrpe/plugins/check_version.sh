#!/bin/bash
#=========================================================================================
# Bash Script
#
# NAME: check_uptime.sh
# AUTHOR:  Tant, Alek - SmartAlek Solutions
# DATE  : 2015.06.15
#
# PURPOSE: Returns the version of the OS that is running
#
# CHANGE LOG:
#
# NOTES:
#   Tested to work with: CentOS, Fedora, Ubuntu, FreeBSD, Solaris
#


#CentOS
if [[ -f "/etc/centos-release" ]]
then
	version=`cat /etc/centos-release`

#Fedora
elif [[ -f "/etc/fedora-release" ]]
then
	version=`cat /etc/fedora-release`

#RedHat
elif [[	-f "/etc/redhat-release" ]]
then
	version=`cat /etc/redhat-release`

#Ubuntu
elif [[ -f "/etc/lsb-release" ]]
then
	version=`cat /etc/lsb-release | grep DESCRIPTION | sed s/DISTRIB_DESCRIPTION=//`

#FreeBSD
elif [[ -d "/usr/ports" ]]
then
	version=`uname -rs`

#Solaris
elif [[ -d "/usr/sunos" ]]
then
	version=`uname -rs`
fi


if [[ -z "$version" ]]
then
	version="Operating System Unknown"
fi

echo "$version"
exit 0
