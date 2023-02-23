#!/usr/bin/bash

source functions.sh

remove_posix_mount

check_if_daos_running
if [ $? -eq 0 ]
then
	echo "Shutting down DAOS..."
	pkill daos_server
	pkill daos_agent
	sleep 5
	daos_clean_up
	echo "DAOS shut down!"
else
	echo "Nothing to do!"
fi
