source functions.sh

#set -x

export DAOS_API=${DAOS_TEST_APIS[0]} # 0-POSIX, 1-DFS
export TEST_OUTPUT_DIR="./outputs"
export TEST_OUTPUT_CSV="${TEST_OUTPUT_DIR}/testout_${DAOS_API}_Node-1.csv"
TEST_OUTPUT_FILE=""

# 1: mpirun np
# 2: API
# 3: blocksize
# 4: xfersize
function run_test_cmd ()
{
	TEST_OUTPUT_FILE="${TEST_OUTPUT_DIR}/testout_$2_Node-1_Clnt-$1_T-$4_B-$3.json"

	if [ "$2" == "POSIX" ]
	then
		MPIRUN_CMD=$(${DAOS_TEST_MPIRUN} --host ${DAOS_ACCESS_POINTS}:${DAOS_TEST_MPIRUN_HOST_CORES_MAX} \
		     -np $1 --mca opal_common_ucx_opal_mem_hooks 1 --allow-run-as-root ${DAOS_TEST_IOR} -a $2 \
		     -b $3 -t $4 -v -W -w -r -R -s 1 -i 1 -o ${DFUSE_MOUNT_NAME}/${DAOS_TEST_POSIX_TESTFILE} -F \
		     -O summaryFile=${TEST_OUTPUT_FILE} -O summaryFormat=JSON 2>/dev/null)
	else
		MPIRUN_CMD=$(${DAOS_TEST_MPIRUN} --host ${DAOS_ACCESS_POINTS}:${DAOS_TEST_MPIRUN_HOST_CORES_MAX} \
		     -np $1 --mca opal_common_ucx_opal_mem_hooks 1 --allow-run-as-root ${DAOS_TEST_IOR} -a $2 \
		     -b $3 -t $4 -v -W -w -r -R -s 1 -i 1 --dfs.pool=${DAOS_POOL} --dfs.cont=${DAOS_CONT} \
		     -o ${DAOS_TEST_DFS_TESTFILE} -F -O summaryFile=${TEST_OUTPUT_FILE} \
		     -O summaryFormat=JSON 2>/dev/null)
	fi

}

function correct_test_output ()
{
	TMP_FILE=$(mktemp)
	uniq $1 > ${TMP_FILE}
	mv -f ${TMP_FILE} $1
	rm -rf ${TMP_FILE}
}
	
function parse_test_output () {

        NODES=$(jq '.tests[0].Options.nodes' $1)
        TASKS=$(jq '.tests[0].Options.tasks' $1)
        CLIENTS_PER_NODE=$(jq '.tests[0].Options["clients per node"]' $1)

	#XFERSIZE=$(jq '.tests[0].Parameters.transferSize' $1)
	#BLOCKSIZE=$(jq '.tests[0].Parameters.blockSize' $1)

	# get these from command line now
	BLOCKSIZE=$(jq '."Command line"' $1 | awk '$4 == "-b" { print $5}')
	XFERSIZE=$(jq '."Command line"' $1 | awk '$6 == "-t" { print $7}')

        M_WR_MiB=$(jq '.summary[0].bwMeanMIB' $1)
        M_RD_MiB=$(jq '.summary[1].bwMeanMIB' $1)

	M_WR_MB=$(echo "$M_WR_MiB*1.049" | bc)
	M_RD_MB=$(echo "$M_RD_MiB*1.049" | bc)

	MEAN_WRITE=${M_WR_MB%.*}
	MEAN_READ=${M_RD_MB%.*}

	echo -e "$NODES\t$TASKS\t$CLIENTS_PER_NODE\t$XFERSIZE\t\t$BLOCKSIZE\t\t$MEAN_WRITE\t$MEAN_READ"
	echo -e "$NODES,$TASKS,$CLIENTS_PER_NODE,$XFERSIZE,$BLOCKSIZE,$MEAN_WRITE,$MEAN_READ" >> ${TEST_OUTPUT_CSV}

}

echo "Running IO test --- API=${DAOS_API} ---- "
rm -rf ${TEST_OUTPUT_CSV}
if [ ! -d ${TEST_OUTPUT_DIR} ]
then
		mkdir -p ${TEST_OUTPUT_DIR}
else
		rm -rf ${TEST_OUTPUT_DIR}/*.json
fi

if [ "${DAOS_API}" == "POSIX" ]
then
	./posix_mount.sh
else
	remove_posix_mount
fi
	
echo -e "nodes\ttasks\tclients\txfersize\tblocksize\twrite\tread"
echo -e "nodes,tasks,clients,xfersize,blocksize,write,read" >> ${TEST_OUTPUT_CSV}

for (( i = 0; i < ${#DAOS_TEST_XFERSIZES[@]}; i++ ))
do
	xfersize=${DAOS_TEST_XFERSIZES[i]}
	blocksize=${DAOS_TEST_BLKSIZES[i]}
	for (( np = $DAOS_TEST_MPIRUN_NP_MIN ; np <= $DAOS_TEST_MPIRUN_NP_MAX ; np++ ))
	do
		run_test_cmd $np ${DAOS_API} $blocksize $xfersize
		correct_test_output ${TEST_OUTPUT_FILE}
		parse_test_output ${TEST_OUTPUT_FILE}
	done
done



