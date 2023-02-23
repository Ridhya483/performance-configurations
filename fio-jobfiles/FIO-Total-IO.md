# Fio Total IO

 - The total IO for each test using fio can be set using the `size` parameter. 
 - In case `runtime` is not provided in the jobfile, the `size` defines the total IO each job will be performing.
- This when multiplied with the `numjobs` gives the total IO performed for each endpoint/node.
- The `size` parameter is in GiB.   

> bs=128M
   size=20G
   iodepth=10
   numjobs=30

In this case , a `size` of 20G is provided in the jobfile. Each job will do 20GiB IOs. Also the `numjobs` in this case is 30 , so the total IO done is 20x30=600GiB / 644GB. 
Note that each node has its own jobfile. So the 644GiB IO is done for each node. Since Swindon is a 3 node setup , the total IO done with the above parameters is `size`x`numjobs`x`number of nodes` i.e 20x30x3=1800GiB/1932GB.



 
