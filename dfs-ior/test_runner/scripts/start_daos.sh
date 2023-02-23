#!/usr/bin/bash
source functions.sh

check_if_daos_running
if [ $? -eq 0 ]
then
	echo "DAOS is already running!"
	exit
fi

setup_daos_device_binding

daos_clean_up
create_daos_rundirs

# DAOS yml stuff
clean_up_daos_ymls
setup_daos_ymls

start_daos_svr
start_daos_agt

display_daos_storage
format_daos_storage

display_daos_system_status

create_daos_pool
create_daos_cont

list_daos_pools
list_daos_cont
