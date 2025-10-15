#!/bin/bash -l
#SBATCH --nodes=1
#SBATCH --ntasks=16
#SBATCH --time=00:30:00
#SBATCH --output=py_scaling_%j.out
#SBATCH --error=py_scaling_%j.err
#SBATCH --job-name=py_scaling_analysis

conda activate project5_env
###dont run doesnt work!#######
for i in 3 5 9 17
    do
    for j in 50 100
        do
        mpiexec -n $i python hello.py 4001 4001 $j

#####results done by hand 
#### 3 50 13.492113
#### 5 50 7.996458
#### 9 50 4,910835
#### 17 50 3.868155
#### 3 100 12.454589
#### 5 100 7.485736
#### 9 100 4.545795
#### 17 100 3.535298
