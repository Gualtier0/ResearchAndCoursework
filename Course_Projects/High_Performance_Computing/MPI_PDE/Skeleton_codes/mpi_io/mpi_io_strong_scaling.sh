#!/bin/bash
#SBATCH --nodes=1
#SBATCH --ntasks=4
#SBATCH --time=00:10:00
#SBATCH --output=scaling_%j.out
#SBATCH --error=scaling_%j.err
#SBATCH --job-name=scaling_analysis

module load openmpi gcc
module load python py-pip
make clean
make 

# 64, 128, 256, 512, 1024
mpirun -np 4 mpi_io 64 100 0.005
python3 plot2.py