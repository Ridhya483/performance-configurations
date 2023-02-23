#!/usr/bin/bash

CFG_DIR=../config
TMPL_DIR=../templates
source ${CFG_DIR}/daos.cfg

function replace_vars ()
{
    perl -e 'while (<STDIN>) { foreach $key (keys %ENV) { s/[#][{]${key}[}]/$ENV{$key}/g; } print; }'
}

function clean_up_daos_ymls ()
{
        if [ ! -d ${DAOS_YML_PATH} ]
        then
                echo "Couldn't locate ${DAOS_YML_PATH} - cannot continue!"
                exit
        fi
	# clean up existing ymls
	for i in "${DAOS_YMLS[@]}"
	do
		rm -rf ${DAOS_YML_PATH}/$i
	done
}
		
function setup_daos_ymls ()
{
        if [ ! -d ${DAOS_YML_PATH} ]
        then
                echo "Couldn't locate ${DAOS_YML_PATH} - cannot continue!"
                exit
        fi
        # create new ymls
	echo "============ Setting up DAOS yml files ============"
        for i in "${DAOS_YMLS[@]}"
        do
		echo -n "$i "
		TMPL_FILE=${TMPL_DIR}/$i.in
                replace_vars < ${TMPL_FILE} > ${DAOS_YML_PATH}/$i 
        done
	echo ""
}

function setup_daos_device_binding ()
{
	x=$(HUGEMEM=8192 $DAOS_PATH/build/external/release/spdk/scripts/setup.sh status | grep ${DAOS_DEVICE_BDF})
	binding=$(echo $x | awk '{print $6}')
	if [ "$binding" != ${DAOS_DEVICE_BINDING} ]
	then
		x=$(HUGEMEM=8192 $DAOS_PATH/build/external/release/spdk/scripts/setup.sh)
	else
		echo "Device ${DAOS_DEVICE_BDF} bound to ${DAOS_DEVICE_BINDING}!"
	fi
}

function daos_clean_up ()
{
	x=$(mount | grep ${DAOS_SCM_MOUNT})
	if [ ! -z "$x" ]
	then
		echo "Found SCM mount! Removing..."
		umount ${DAOS_SCM_MOUNT}
		rm -rf ${DAOS_SCM_MOUNT}
	else
		echo "No SCM mount found."
	fi
	rm -rf ${DAOS_RUN_DIR_SVR}
	rm -rf ${DAOS_RUN_DIR_AGT}
}

function create_daos_rundirs ()
{
	mkdir -p ${DAOS_RUN_DIR_SVR}
	mkdir -p ${DAOS_RUN_DIR_AGT}
}

function start_daos_svr ()
{
	echo "============= Starting DAOS server =============="
	daos_server start &
	sleep 10
}

function start_daos_agt ()
{
	echo "============= Starting DAOS agent ==============="
	daos_agent start &
	sleep 5
}

function display_daos_storage ()
{
	echo "================= DAOS storage =================="
	dmg storage scan
	sleep 2
}

function format_daos_storage ()
{
	echo "========== Formatting DAOS storage ==============="
	dmg storage format
	sleep 1
}

function display_daos_system_status ()
{
	echo "============= DAOS system status ================="
	dmg system query -v
	sleep 1
}

function create_daos_pool ()
{
	echo "========= Creating DAOS pool: ${DAOS_POOL} ==========="
	dmg pool create --size ${DAOS_POOL_SIZE} ${DAOS_POOL}
	sleep 1
}

function create_daos_cont ()
{
	echo "========= Creating DAOS cont: ${DAOS_CONT} ==========="
	daos container create ${DAOS_POOL} ${DAOS_CONT} --type ${DAOS_CONT_TYPE}
	sleep 1
}

function list_daos_pools ()
{
	echo "============== DAOS pools =============="
	dmg pool list
	sleep 1
}

function list_daos_cont ()
{
	echo "============= DAOS Container(s) ================"
	daos container query ${DAOS_POOL} ${DAOS_CONT}
	sleep 1
}
	
function remove_posix_mount ()
{
	echo "=========== Checking POSIX mount status ============="
	STR=$(mount | grep ${DFUSE_MOUNT_NAME})
	if [ ! -z "$STR" ]
	then
		echo "${DFUSE_MOUNT_NAME} appears to be mounted! Removing the mount..."
		fusermount3 -u ${DFUSE_MOUNT_NAME}
		rm -rf ${DFUSE_MOUNT_NAME}
	else
		echo "No POSIX mounts found!"
	fi
}

function do_posix_mount ()
{
	STR=$(mount | grep ${DFUSE_MOUNT_NAME})
	if [ ! -z "$STR" ]
	then
		echo "POSIX mount ${DFUSE_MOUNT_NAME} ready!"
	fi
}

function check_if_daos_running ()
{
	proc_server="daos_server" # includes a daos_server helper
	proc_agent="daos_agent"
	proc_engine="daos_engine"

	num_daos_procs=0

	echo "======== Checking DAOS run status ========"
	daos_procs=$(ps -aef | grep daos | awk '{print $8}') # treat as an array!
	for proc in $daos_procs
	do
		case $proc in
			*"$proc_server"*)
				echo -n ".server."
				num_daos_procs=$((num_daos_procs+1))
				;;
			*"$proc_agent"*)
				echo -n ".agent."
				num_daos_procs=$((num_daos_procs+1))
				;;
			*"$proc_engine"*)
				echo -n ".engine."
				num_daos_procs=$((num_daos_procs+1))
				;;
		esac
	done
	if [ "$num_daos_procs" == "4" ]
	then
		echo -e "\tDAOS is running!"
		return 0
	else
		echo -e "\tDAOS is not running!"
		return 1
	fi
}
									
