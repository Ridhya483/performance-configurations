# Graph plotting utilities for run_daos
This directory contains a Jupyter Notebook '**run_daos Graph Plotter.ipynb**' that can be used to create the the graphs / plots of performance figures obtained from the run_daos script framework (.csv files)

# Pre-requisites
* Python 3 with pip and jupyter-notebook
* Libraries: pandas, matplotlib

# Inputs to the plotter
* .csv files from the run_daos script framework
	* File names of the form: testout_**\<API\>**_Node-**\<num_nodes\>**.csv
		* Example: **testout_POSIX_Node-3.csv**
		
# Outputs from the plotter
* 2 **.PNG** files - 1 each for Read and Write
	* These contain 1 graph/subplot per **xfersize** found in the .csv; in each subplot, **performance** is plotted against **number of clients/node**
	* Example files:
		* ![Read performance - 3 Nodes - 3 APIs](https://github.com/d-nayak/run_daos/blob/main/plotter/Read_DFS-3N_POSIX-3N_MPIIO-3N.png)
		* ![Write performance - 3 Nodes - 3 APIs](https://github.com/d-nayak/run_daos/blob/main/plotter/Write_DFS-3N_POSIX-3N_MPIIO-3N.png)
		