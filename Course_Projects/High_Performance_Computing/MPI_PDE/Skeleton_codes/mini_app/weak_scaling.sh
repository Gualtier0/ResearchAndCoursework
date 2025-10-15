#!/bin/bash
#SBATCH --nodes=1
#SBATCH --ntasks=16
#SBATCH --time=01:00:00
#SBATCH --output=weak_scaling_%j.out
#SBATCH --error=weak_scaling_%j.err
#SBATCH --job-name=weak_scaling_analysis

module load openmpi gcc
##module load python py-pip
make clean
make 

NP=(1 2 4 8 16)
n1=(64 90 128 181 256) ###i precomputed those separatly
n2=(128 181 256 362 512)
n3=(256 362 512 724 1024)

for i in {0..4}
    do
    ind1=${NP[$i]}
    ind2=${n1[$i]}
    mpirun -np $ind1 main $ind2 100 0.005 | \
    grep -i "\#\#\#" >> weak_scaling_results1
done

for i in {0..4}
    do
    ind1=${NP[$i]}
    ind2=${n2[$i]}
    mpirun -np $ind1 main $ind2 100 0.005 | \
    grep -i "\#\#\#" >> weak_scaling_results2
done

for i in {0..4}
    do
    ind1=${NP[$i]}
    ind2=${n3[$i]}
    mpirun -np $ind1 main $ind2 100 0.005 | \
    grep -i "\#\#\#" >> weak_scaling_results3
done
##python3 plot.py