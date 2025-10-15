#!/bin/bash
#SBATCH --nodes=1
#SBATCH --ntasks=16
#SBATCH --time=01:00:00
#SBATCH --output=scaling_%j.out
#SBATCH --error=scaling_%j.err
#SBATCH --job-name=scaling_analysis

module load openmpi gcc ##comment this and the plot.py call to run the test
module load python py-pip
make clean
make 

for i in 64 128 256 512 1024
    do
    for j in 1 2 4 8 16
        do
        mpirun -np $j main $i 100 0.005 | \
        grep -i "\#\#\#" >> strong_scaling_results
    done
done
python3 plot.py