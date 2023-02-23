#!/usr/bin/bash

source functions.sh

check_if_daos_running
if [ $? -eq 0 ]
then
	remove_posix_mount
	mkdir -p ${DFUSE_MOUNT_NAME}
	dfuse -m ${DFUSE_MOUNT_NAME} --disable-caching --pool ${DAOS_POOL} --cont ${DAOS_CONT}
	do_posix_mount
else
	echo "DAOS not running! Start DAOS first!"
fi

