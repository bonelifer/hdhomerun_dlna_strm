#!/bin/bash

# Uses hdhomerun_config to scan for channels and then creates .strm files with links to the DLNA stream 
# in ~/Videos/Live TV for KODI streaming

## Run this command first:
##     hdhomerun_config discover

## Take the output from that and fill in the config.conf file accordingly(example output):
##    hdhomerun device 1015CA70 found at 192.168.1.121
##    hdhomerun device 1034DD9B found at 192.168.1.129
##    hdhomerun device 1042A03E found at 192.168.1.119
## 
##    Replace the default "CONFIGURETHIS" text with your HDHomeRun's deviceid and 
##    deviceip. Where 1042A03E is DEVICEID and  192.168.1.119 is DEVICEIP
##

# Based on work by JoshBulger at https://github.com/JoshBulger/HDHomeRun

## Set of functions to allow us to warn user to read directions and configure the script
warn () {
    echo -e "\n$@" >&2
}
die () {
    rc=$1
    shift
    warn "$@"
    exit $rc
}


# Check if directory exists, if not then create it
if [ ! -d "~/Videos/Live\ TV" ]; then
	mkdir -p ~/Videos/Live\ TV
fi

## BEFORE RUNNING YOU MUST FILE IN THIS CONFIG FILE FOR YOUR HDHomeRUN 
## DEVICEID and DEVICE IP. STORE THEM IN "config.conf" before running
## THE "homeruntv.sh" script
##
HDHRFILE="config.conf"

if grep -q CONFIGURETHIS "$HDHRFILE"; then
   die 127 "Please read the directions at the top of the script \nand \e[31mconfigure\e[0m the \e[31mconfig.conf\e[0m file.\n"
 fi

DEVICEID="$( grep "DEVICEID=" $HDHRFILE | sed s/.*DEVICEID=/\/ )"
DEVICEIP="$( grep "DEVICEIP=" $HDHRFILE | sed s/.*DEVICEIP=/\/ )"


# Device Specific Details
device=$DEVICEID
IP=$DEVICEIP
PORT=5004

# Scan channels directly into while loop - pull relevant data and create strm file
hdhomerun_config $device scan 1 | grep -vEi 'tsid|lock|none' | while read output
	do
		if [[ "$output" == "SCANNING"* ]]; then
			scan=$(echo $output | awk '{print $2}')
		fi
		if [[ "$output" == "PROGRAM"* ]]; then
			prog=$(echo $output | awk '{print $2}')
			file=$(echo $output | cut -d':' -f2)
			# Create .strm file
			channelNum=$(echo $file | cut -d" " -f1)

			echo http://$IP:$PORT/auto/v$channelNum > ~/Videos/Live\ TV/"${file/\ /}".strm		
		fi
	done
exit 0
