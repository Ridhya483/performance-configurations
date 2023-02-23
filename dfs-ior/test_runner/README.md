
# test runner framework for run_daos
This directory contains a bash script framework for running IOR/MPI-IO based test runs on a system/cluster running DAOS

# Pre-requisites (per node of the DAOS cluster)
* DAOS installed prefereably in ${DAOS_PATH}
* IOR installed and accesible in the path (with DFS, POSIX, MPI-IO support as needed)
* MPIRUN installed and accessible in the path

# Inputs 
* Inputs are controlled through bash export variables in config/daos.cfg
	
# Running the tests
* Modify the parameters as needed in config/daos.cfg
* Change CWD to scripts
``
  $ cd scripts
  ``
* Issue a command to start DAOS:
``
  $ ./start_daos.sh
``
* Modify run_test.sh as needed (API, paramters like xfersize, blocksize, etc.
 ``
 $ ./run_test.sh
 ``
  
# Outputs from the plotter
* The test run cycles through given combinations of API, xfersize, blocksize, etc
* It issues IOR commands via mpirun framework
* It collects results from IOR runs in json formatted files
* It parses the json output (per test run) and create a .csv file for succinct Read, Write output
* The .csv file so produced is an input to the **plotter**